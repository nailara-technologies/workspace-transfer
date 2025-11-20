# Protocol-7 Web Modules: Comprehensive Analysis

## Overview
The Protocol-7 web module system implements a sophisticated template-based content serving architecture with support for skinning, menu generation, directory scanning, and recursive template processing. Total: ~5,800 lines across all web modules.

---

## Core Foundation Module

### 1. **web.init_code**
**Purpose:** Initialization of the web content processing zenka engine

**Configuration Established:**
- Content directory: `/data/web` (configurable via `<web.cfg.base_dir>`)
- Skins directory: `/var/httpd/skins` (via `<web.cfg.skins_dir>`)
- Default skin: `default.tmpl`
- Max recursion depth: 8 levels (prevents infinite loops)
- Command timeout: 15 seconds
- Cache enabled: Yes (TTL: 1800 seconds / 30 minutes)
- Max template size: 5MB
- Parallel commands: max 16 concurrent

**Patterns Defined:**
- **Command pattern:** `<[command.name:param1:param2]>` - matches nested commands
- **Meta variable pattern:** `<{variable_name}>` - substitution variables

**State Management:**
- Active template tracking hash
- Template cache (persistent during session)
- Pending commands queue
- Performance metrics collection

**Metrics Tracked:**
- Templates processed count
- Cache hits/misses
- Commands executed/nested
- Avg processing time (ms)
- Recursion depth violations

---

## Template Processing Pipeline

### 2. **web.process_template_recursive**
**Purpose:** Core recursive template processing engine

**Processing Steps:**
1. **Meta variable substitution** - Replace `<{var_name}>` with values from meta hash
2. **Command extraction** - Parse `<[...]>` patterns into identified commands
3. **Nested command recursion** - Process commands containing nested commands first
4. **Command execution** - Execute all extracted commands in order
5. **Result substitution** - Replace `<<COMMAND:id>>` placeholders with results
6. **Recursive check** - If new commands appear after substitution, recurse again

**Key Features:**
- Depth tracking to prevent infinite recursion (max 8 levels)
- Support for nested command structures: `<[outer:<[inner]>]>`
- Command placeholder system to allow out-of-order processing
- Array ref handling from base.parser.pattern_split

**Parameters:**
```perl
{
  content     => template_string,
  meta        => { var_name => value, ... },
  depth       => current_recursion_depth,
  template_id => unique_identifier,
  session_id  => session_identifier
}
```

**Returns:**
```perl
{
  status  => 'success' or 'error',
  content => processed_html,
  depth   => final_depth,
  message => error_description
}
```

---

### 3. **web.execute_template_command**
**Purpose:** Execute individual template commands with timeout protection

**Command Format:** `module.path:arg1:arg2:...`

**Processing:**
- Validates command format (alphanumeric, dots, dashes, underscores only)
- Checks if module exists in `$code{}` namespace
- Executes with 15-second timeout (configurable)
- Handles both scalar and hash responses
- Extracts `content` key from hash responses
- Wraps command execution in eval block with SIGALRM timeout

**Error Handling:**
- Timeout errors logged at level 1
- Module not found returns `<!-- command not found: module -->`
- Execution errors wrapped as HTML comments
- Invalid formats rejected with validation error

**Pending Command Tracking:**
- Tracks command execution in `<web.commands.pending>`
- Records command_name, template_id, status, timestamp
- Cleaned up after execution

---

## Content Serving & Rendering

### 4. **web.render_skinned_content**
**Purpose:** Load, process, and wrap content in skin templates

**Workflow:**
1. **Path handling** - Clean up and validate content path (no `..` traversal)
2. **Directory detection** - Check for index files (txt, md, html)
3. **Fallback listing** - Generate directory listing if no index found
4. **Content loading** - Read file from `/data/web/{vhost}/{content_path}`
5. **Type detection** - Determine content type from extension
6. **Meta preparation** - Build meta variables for template processing
7. **Recursive processing** - Process content template recursively
8. **Skin wrapping** - Load skin template and inject processed content
9. **Menu generation** - Generate navigation menu for current path
10. **Title extraction** - Extract from H1/H2 tags or derive from filename

**Parameters:**
```perl
{
  path       => 'content/path',
  session_id => session_id,
  vhost      => 'domain.com',
  skin       => 'dark',           # optional
  base_dir   => '/data/web',      # optional
  skin_dir   => '/var/httpd'      # optional
}
```

**Return Structure:**
```perl
{
  status       => 'success' or 'error',
  content      => rendered_html,
  content_type => 'text/html',
  title        => extracted_or_derived_title,
  no_skin      => 1 or undef,     # if skin failed
  is_dirlist   => 1 or undef      # if generated listing
}
```

**Index File Resolution (Priority):**
1. `index.txt`
2. `index.md`
3. `index.html`
4. Auto-generate directory listing

---

## Content Discovery & Navigation

### 5. **web.scan_directory**
**Purpose:** Scan directory structure for content files

**Features:**
- Recursive directory traversal
- File type detection (txt, md, html)
- Directory vs file distinction
- Numeric prefix handling (e.g., `01_` for ordering)
- Duplicate name resolution (prefers directories)
- File stats gathering (size, mtime)

**Filtering:**
- Skips hidden files (starting with `.`)
- Skips backups (`~` suffix)
- Skips `.git` directories
- Skips `DEADJOE` editor files
- Optionally shows all files vs just content files

**Sorting:**
1. Directories first
2. By sort_prefix (numeric)
3. By display_name (alphabetically)

**Item Structure Returned:**
```perl
{
  name          => 'original_filename',
  display_name  => 'formatted_for_ui',
  sort_prefix   => 01,                 # if numeric prefix
  path          => 'relative/path',
  full_path     => '/absolute/path',
  type          => 'dir' or 'file',
  content_type  => 'txt' or 'md' or 'html' or '',
  size          => bytes,
  mtime         => unix_timestamp,
  is_index      => 0 or 1
}
```

**Return:**
```perl
{
  status       => 'success' or 'error',
  path         => full_path,
  current_path => relative_path,
  items        => [ { item_structure }, ... ],
  count        => number_of_items
}
```

---

### 6. **plugin.web.menu.tree**
**Purpose:** Generate hierarchical navigation menu from directory structure

**Features:**
- Recursive submenu generation up to specified depth (default: 3)
- Active path highlighting (CSS classes: `active`, `current`)
- Directory-aware menu items
- Index file awareness
- Parent path tracking for navigation breadcrumbs

**Processing:**
- Scans root directory using `web.scan_directory`
- Identifies currently active section
- Recursively expands only the active path's directories
- Generates semantic HTML with proper nesting

**CSS Classes Applied:**
```
menu-item       - all items
active          - item is in current path
current         - exact current page
has-children    - directory with contents
menu-level-N    - nesting level (0, 1, 2, etc.)
submenu         - submenu list
submenu-item    - item in submenu
```

**HTML Structure:**
```html
<nav class="web-menu-tree">
  <ul class="menu-level-0">
    <li class="menu-item active has-children">
      <a href="/section" class="menu-link active">
        <strong>Section Name</strong>
      </a>
      <ul class="menu-level-1 submenu">
        <li class="menu-item submenu-item active">
          <a href="/section/page" class="menu-link active">Page</a>
        </li>
      </ul>
    </li>
  </ul>
</nav>
```

---

### 7. **plugin.web.content.dirlist**
**Purpose:** Generate HTML directory listing table

**Features:**
- File type icons (📁, 📄, 📎)
- Formatted file sizes (B, KB, MB, GB, TB)
- Date/time formatting
- Optional checksum display
- CSS-styled table for directory browsing

**Columns:**
- Name (with clickable links)
- Type (Directory/File/Format type)
- Size (formatted, N/A for directories)
- Modified (YYYY-MM-DD HH:MM format)
- Checksum (optional, uses elf.vax-BASE32)

**Table Structure:**
```html
<div class="dirlist-container">
  <table class="dirlist" border="0" cellpadding="4" cellspacing="0">
    <thead>
      <tr>
        <th class="dirlist-name">Name</th>
        <th class="dirlist-type">Type</th>
        <th class="dirlist-size">Size</th>
        <th class="dirlist-modified">Modified</th>
      </tr>
    </thead>
    <tbody>
      <tr class="dirlist-row dirlist-dir">
        <td><a href="/dir/" class="dirlist-link dir-link">📁 Directory</a></td>
        ...
      </tr>
    </tbody>
  </table>
</div>
```

---

## Skin & Theme Resolution

### 8. **web.skin_resolver**
**Purpose:** Resolve skins through cascade priority system

**Cascade Priority (checked in order):**
1. User-selected skin (from preferences)
2. Mobile device skin (auto-detected from User-Agent)
3. Dark mode skin (time-based or preference-based)
4. Default fallback

**Device Detection (from User-Agent):**
```perl
'mobile'  => /mobile|iphone|android|blackberry|opera mini/i
'tablet'  => /tablet|ipad|android/i
'desktop' => default
```

**Dark Mode Detection:**
- Time-based: Hours 20-23 and 00-07 (8pm-7:59am)
- Preference override: `dark_mode => true/false`

**Validation:**
- Skin names: alphanumeric, dash, underscore only
- Invalid characters rejected with warning

**Caching:**
- Cache key: `$vhost:skin=$name:dark_mode=$bool:...`
- Persistent during session
- Speeds up resolution for repeated requests

**Metadata Support:**
- Reads `metadata.yaml` from skin directory
- Extracts: name, version, author, description
- Partial YAML parsing for these fields

**Return Structure:**
```perl
{
  skin_name   => 'resolved_skin',
  skin_root   => '/var/httpd/_global_templates/skins/dark',
  cascade     => ['dark', 'default'],  # order checked
  metadata    => { name => '...', version => '...' },
  device_type => 'desktop' or 'tablet' or 'mobile'
}
```

---

## Command Handlers

### 9. **web.cmd.skin**
**Purpose:** Operator command for skin management

**Subcommands:**

**resolve** - Resolve skin for vhost
```
skin resolve <vhost> [skin=name] [dark_mode=true/false]
```
Returns: skin name, path, device type, cascade order

**list** - List available skins
```
skin list <vhost>
```
Lists all directories in skins root

**info** - Show skin details
```
skin info <vhost> <skin-name>
```
Lists files and directories in skin

---

### 10. **web.cmd.process-template**
**Purpose:** Manual template processing from operator CLI

**Usage:**
```
process-template <template-path> [meta-var=value ...]
```

**Processing:**
- Validates file exists and is readable
- Checks max size (5MB default)
- Generates unique template ID
- Tracks active template processing
- Measures elapsed time
- Updates performance metrics
- Returns processed content

**Returns:** Exit code 5 (TRUE + SIZE) with content, or 0 with error message

---

### 11. **web.cmd.content**
**Purpose:** Handle web template content requests

**Status:** STUB - Not yet implemented
Returns: `{ mode => false, data => 'command not implemented yet' }`

---

## IPC Integration

### 12. **web.process_template_ipc**
**Purpose:** IPC handler for template processing from httpd zenka

**Parameter Format:** `template_id:template_content_b32r:meta_vars_b32r:session_id`

**Encoding:**
- Template content: base32r encoded (avoids colon conflicts)
- Meta variables: base32r encoded JSON

**Processing:**
- Decodes base32r encoded inputs
- Parses JSON meta variables
- Processes template recursively
- Handles array vs scalar return types
- Dereferences scalar refs from pattern_split

**Returns:**
```perl
{
  mode => 'size',   # success - sends content back via IPC
  data => rendered_html
}
# or
{
  mode => 'false',  # error
  data => error_message
}
```

**Logging:** Extensive debug logging (levels 0-2) for troubleshooting IPC communication

---

## Asset Management System

### 13. **web.assets.registry**
**Purpose:** Central registry for template assets

**Data Structure:**
```perl
<web.assets.registry> = {
  '/path/to/asset' => {
    asset_path     => '/path/to/asset',
    template       => 'template_name',
    source_path    => '/source/location',
    status         => 'present' or 'missing' or 'copied',
    last_validated => unix_timestamp,
    discovered_at  => unix_timestamp
  },
  ...
}
```

**Statistics:**
```perl
<web.assets.stats> = {
  total_assets      => number,
  templates_scanned => number,
  last_scan_time    => unix_timestamp,
  assets_present    => count,
  assets_missing    => count,
  assets_copied     => count
}
```

---

### 14. **web.assets.register**
**Purpose:** Register individual assets in registry

**Parameters (named):**
```perl
{
  asset_path  => '/path/to/asset',     # required
  template    => 'template_name',      # required
  source_path => '/source/path',       # optional
  status      => 'present'|'missing'|'copied'  # default: 'unknown'
}
```

**Operation:**
- Adds/updates asset entry
- Records validation timestamp
- Updates total asset count
- Preserves discovery timestamp

---

### 15. **web.assets.load_registry**
**Purpose:** Load pre-generated asset registry from YAML file

**Registry File:** `$PROJECT_ROOT/var/httpd/static/.asset-registry.yaml`

**Process:**
1. Checks if registry file exists
2. Parses YAML using YAML::Tiny
3. Loads statistics
4. Loads asset entries
5. Counts assets by status
6. Updates stats counters

**Requires:** Validator to have previously generated `.asset-registry.yaml`

---

### 16. **web.assets.by_status**
**Purpose:** Query assets by current status

**Parameters:** `$status` (string)

**Valid Statuses:**
- `present` - asset exists at expected location
- `missing` - asset referenced but not found
- `copied` - asset successfully copied to destination

**Returns:** Array of asset entries matching status

---

## Summary of Implemented Features

### Template Processing ✓
- [x] Recursive template parsing with depth limiting (max 8 levels)
- [x] Command extraction and execution: `<[command:args]>`
- [x] Meta variable substitution: `<{varname}>`
- [x] Nested command support
- [x] Timeout protection (15 seconds per command)
- [x] Performance metrics tracking

### Skin/Theme System ✓
- [x] Cascade-based skin resolution
- [x] Device detection (mobile/tablet/desktop)
- [x] Time-based dark mode
- [x] User preference override
- [x] Skin caching
- [x] Metadata support

### Menu & Navigation ✓
- [x] Hierarchical menu generation from filesystem
- [x] Active path highlighting
- [x] Recursive submenu expansion
- [x] Directory-aware menu items
- [x] Menu path awareness for highlighting

### Content Serving ✓
- [x] File type detection (txt, md, html)
- [x] Index file resolution (priority: txt > md > html)
- [x] Directory listing fallback
- [x] Content template processing
- [x] Skin wrapping integration
- [x] Title extraction

### Directory Scanning ✓
- [x] Recursive directory traversal
- [x] File type filtering
- [x] Numeric prefix handling (01_name)
- [x] Directory/file distinction
- [x] Sorting by type, prefix, name
- [x] File stats gathering (size, mtime)

### Asset Registry ✓
- [x] Central asset tracking
- [x] YAML registry loading
- [x] Status tracking (present/missing/copied)
- [x] Asset discovery timestamps
- [x] Statistics collection

---

## Potential Missing Features for Skinnable Content Plugin

### 1. **Menu Position Awareness**
**Status:** PARTIAL
- Menu highlights active path but doesn't track position depth
- Missing: Breadcrumb generation from current path
- Missing: "Up" navigation to parent directories
- Missing: Current position indicator in nested menus

### 2. **Template Command Registration System**
**Status:** MISSING
- Commands are discovered dynamically from `$code{}` namespace
- Missing: Registry of available commands
- Missing: Command help/documentation system
- Missing: Command parameter validation schemas

### 3. **Skin Asset Management**
**Status:** PARTIAL
- Asset registry exists but discovery mechanism unclear
- Missing: CSS/JS asset injection into skins
- Missing: Asset path rewriting
- Missing: Asset dependency resolution

### 4. **Menu Customization**
**Status:** LIMITED
- Menu generated purely from filesystem
- Missing: Custom menu order (partial via menu.yaml)
- Missing: Menu item icons (referenced in code but not implemented)
- Missing: Menu item visibility controls (partial via hidden flag)
- Missing: Custom links outside filesystem structure

### 5. **Template Caching**
**Status:** BASIC
- TTL-based cache exists (1800 seconds)
- Missing: Cache invalidation triggers
- Missing: Cache key strategy for vhost/content combinations
- Missing: Cache statistics visibility

### 6. **Error Handling & Recovery**
**Status:** BASIC
- Depth limits prevent infinite recursion
- Missing: Graceful degradation for missing includes
- Missing: Error recovery strategies
- Missing: User-facing error pages vs debug output

### 7. **Content Versioning**
**Status:** MISSING
- No content version control
- Missing: Draft/published workflow
- Missing: Content history tracking
- Missing: Rollback capability

### 8. **Access Control**
**Status:** NOT IMPLEMENTED
- No per-page access control
- No authentication integration
- No permission checking on content access
- No role-based menu filtering

### 9. **Content Publishing Pipeline**
**Status:** MISSING
- No workflow states
- No scheduling
- No approval process
- No publication date handling

### 10. **Advanced Menu Features**
**Status:** LIMITED
- Missing: Breadcrumb generation (derivable from current_path)
- Missing: Menu search/filter
- Missing: Collapsed/expanded state persistence
- Missing: Dynamic menu item generation from command results

---

## Configuration Locations

| Component | Default Path | Configurable |
|-----------|--------------|--------------|
| Content | `/data/web` | Yes: `<web.cfg.base_dir>` |
| Skins | `/var/httpd/skins` | Yes: `<web.cfg.skins_dir>` |
| Template Max Size | 5MB | Yes: `<web.cfg.template_max_size>` |
| Command Timeout | 15s | Yes: `<web.cfg.command_timeout>` |
| Cache TTL | 1800s | Yes: `<web.cfg.cache_ttl>` |
| Max Recursion | 8 levels | Yes: `<web.cfg.recursion_depth_max>` |
| Asset Registry | `var/httpd/static/.asset-registry.yaml` | Via PROJECT_ROOT env var |

---

## Performance Characteristics

**Metrics Collected:**
- Templates processed
- Commands executed
- Nested command count
- Recursion depth violations
- Average processing time (ms)
- Cache hit/miss ratio

**Caching Strategy:**
- TTL: 30 minutes
- Key: vhost + content path hash
- Invalidation: Time-based only

**Optimization Opportunities:**
1. Content-based cache invalidation
2. Parallel command execution (framework supports up to 16)
3. Asset preloading
4. Menu caching with invalidation
5. Skin template pre-compilation

---

## Integration Points

**Inbound:**
- IPC from httpd zenka: `web.process_template_ipc`
- Operator commands: `web.cmd.*`
- Content requests: `web.render_skinned_content`

**Outbound:**
- Calls to `base.parser.pattern_split` for command parsing
- Calls to `file.slurp` for file loading
- Calls to `chk-sum.elf.vax-BASE32` for checksums
- Calls to YAML::Tiny for registry loading
- Calls to JSON::XS for meta variable encoding

**Plugin Interfaces:**
- `plugin.web.menu.tree` - Menu generation
- `plugin.web.content.dirlist` - Directory listing

