# Protocol-7 Web Modules Analysis - Document Index

## Overview
Complete analysis of the Protocol-7 web module system for understanding template parsing, skinning, menu generation, and content serving features.

**Analysis Date:** November 20, 2025
**Modules Analyzed:** 18 core web modules + 2 plugin modules
**Total Code:** ~5,800 lines

---

## Documents Included

### 1. **IMPLEMENTATION-RECOMMENDATIONS.md** (PRIMARY)
**Purpose:** Strategic implementation guide for extending the system

**Contents:**
- Status summary: What's already implemented
- 12 recommended features with implementation guides
- 3-sprint development plan
- Effort estimates (50-65 hours total)
- Integration architecture diagram
- Code quality assessment
- Testing and documentation strategy

**Audience:** Project managers, architects, senior developers

**Key Sections:**
- Phase 1: High-impact features (breadcrumbs, command registry, menu customization, cache invalidation)
- Phase 2: Medium-impact features (access control, skin assets, versioning)
- Phase 3: Advanced features (scheduling, search, analytics)

---

### 2. **web-modules-analysis.md** (DETAILED REFERENCE)
**Purpose:** Comprehensive technical reference for all web modules

**Contents:**
- Detailed documentation of 16 core modules
- Module-by-module breakdown with:
  - Purpose and description
  - Processing steps
  - Parameters and return structures
  - Configuration options
  - Error handling
  - Integration points
- 2 plugin modules (menu, directory listing)
- Asset management system (4 modules)
- Feature implementation checklist
- Gaps analysis (missing features by priority)

**Audience:** Developers, technical architects, code reviewers

**Sections:**
1. web.init_code - Initialization & configuration
2. web.process_template_recursive - Core parsing engine
3. web.execute_template_command - Command execution
4. web.render_skinned_content - Content serving pipeline
5. web.scan_directory - Directory discovery
6. plugin.web.menu.tree - Menu generation
7. plugin.web.content.dirlist - Directory listing
8. web.skin_resolver - Skin/theme resolution
9. web.cmd.* - Operator commands
10. web.process_template_ipc - IPC integration
11. web.assets.* - Asset management (4 modules)

---

### 3. **web-modules-summary.txt** (QUICK REFERENCE)
**Purpose:** Executive summary with quick-lookup tables

**Contents:**
- 9-tier module organization (Foundation through Asset Management)
- What's fully implemented (checklist)
- Key gaps for skinnable content plugin
- Configuration defaults table
- Command patterns reference
- Integration notes

**Audience:** Quick lookup, presentations, onboarding

**Highlights:**
- 20+ implemented features ✓
- 16 identified enhancement opportunities
- Configuration reference table
- Integration point summary

---

## Key Findings Summary

### Fully Implemented Features
- Recursive template parsing (8-level depth limit)
- Meta variable substitution (<{varname}>)
- Command extraction and execution (<[command:args]>)
- Nested command support
- Content file serving from /data/web/{vhost}/
- Index file resolution (txt > md > html)
- Directory listing generation
- Hierarchical menu generation
- Active path highlighting in menus
- Skin cascade resolution (user > device > dark > default)
- Device detection (mobile/tablet/desktop)
- Time-based dark mode (20:00-07:59)
- Directory scanning with file type detection
- Numeric prefix ordering (01_, 02_, etc.)
- Asset registry system
- Performance metrics tracking
- Template caching (30-minute TTL)
- IPC integration with httpd

### High-Priority Enhancements Needed
1. Breadcrumb generation
2. Template command registry
3. Enhanced menu customization
4. Cache invalidation on content change
5. Position-aware menu highlighting
6. Access control integration
7. Skin asset injection (CSS/JS)
8. Content versioning & draft workflow

---

## Module Map

### Core Processing Modules (Foundation)
```
web.init_code
├── Configuration initialization
├── Pattern definitions
└── Metrics setup

web.process_template_recursive
├── Meta variable substitution
├── Command extraction
├── Nested command handling
├── Command execution
├── Result substitution
└── Recursive processing

web.execute_template_command
├── Command validation
├── Module lookup
├── Timeout protection
└── Result handling
```

### Content Serving Modules (Pipeline)
```
web.render_skinned_content
├── Path handling & validation
├── Index file resolution
├── Directory listing fallback
├── Content loading
├── Type detection
├── Meta preparation
├── Recursive processing
├── Skin wrapping
├── Menu generation
└── Title extraction
```

### Navigation Modules (UI)
```
web.scan_directory
├── Directory traversal
├── File type detection
├── Numeric prefix handling
├── File stats gathering
└── Sorting

plugin.web.menu.tree
├── Menu generation
├── Active path highlighting
├── Recursive submenu expansion
└── CSS class application

plugin.web.content.dirlist
├── Table generation
├── File type icons
├── Size formatting
└── Date formatting
```

### Skinning Modules (Themes)
```
web.skin_resolver
├── Cascade priority
├── Device detection
├── Dark mode detection
├── Skin validation
├── Caching
└── Metadata loading
```

### Command Modules (Operators)
```
web.cmd.process-template
├── Manual processing
├── File validation
├── Metrics tracking
└── Content return

web.cmd.skin
├── resolve - Skin resolution
├── list - Available skins
└── info - Skin details
```

### IPC Integration
```
web.process_template_ipc
├── Parameter decoding
├── Recursive processing
├── Result encoding
└── IPC response
```

### Asset Management
```
web.assets.registry
├── Asset tracking
└── Statistics

web.assets.register
├── Asset registration
└── Automatic updates

web.assets.load_registry
├── YAML loading
├── Parsing
└── Statistics update

web.assets.by_status
└── Query by status
```

---

## Configuration Reference

| Setting | Default | Variable | Configurable |
|---------|---------|----------|--------------|
| Content base | /data/web | web.cfg.base_dir | Yes |
| Skins dir | /var/httpd/skins | web.cfg.skins_dir | Yes |
| Max recursion | 8 levels | web.cfg.recursion_depth_max | Yes |
| Command timeout | 15 seconds | web.cfg.command_timeout | Yes |
| Cache enabled | Yes | web.cfg.cache_enabled | Yes |
| Cache TTL | 1800s (30min) | web.cfg.cache_ttl | Yes |
| Max template | 5 MB | web.cfg.template_max_size | Yes |
| Parallel cmds | 16 max | web.cfg.parallel_commands_max | Yes |
| Menu depth | 3 levels | (in plugin.web.menu.tree) | Function param |

---

## Command Syntax Reference

### Template Commands
```
<[module.path:arg1:arg2:...arg_n]>
```

Example:
```
<[web.scan_directory:/data/web:section/subsection]>
```

### Meta Variables
```
<{variable_name}>
```

Example:
```
<{title}>
<{content}>
<{menu}>
<{skin_css}>
```

### Nested Commands
```
<[outer_module:<[inner_module:args]>]>
```

### Command Placeholders (Internal)
```
<<COMMAND:template_id_cmd_001>>
```

---

## Integration Points

### Inbound Integrations
- IPC from httpd zenka: `web.process_template_ipc`
- Operator commands: `web.cmd.*`
- Content requests: `web.render_skinned_content`

### Outbound Dependencies
- `base.parser.pattern_split` - Command parsing
- `file.slurp` - File loading
- `chk-sum.elf.vax-BASE32` - Checksums
- `YAML::Tiny` - Registry loading
- `JSON::XS` - Meta variable encoding
- `Crypt::Misc` - Base32r encoding/decoding

### Plugin Interfaces
- `plugin.web.menu.tree` - Menu generation
- `plugin.web.content.dirlist` - Directory listing

---

## Recommended Reading Order

1. **Start here:** web-modules-summary.txt (5-10 min read)
   - Get overview of what exists
   - Understand tier architecture
   - Review quick reference tables

2. **For planning:** IMPLEMENTATION-RECOMMENDATIONS.md (20-30 min read)
   - Understand what's missing
   - Review enhancement options
   - Plan sprints and effort

3. **For development:** web-modules-analysis.md (60-90 min detailed read)
   - Deep dive on each module
   - Understand processing flows
   - Review parameters and returns
   - Study error handling

---

## How to Use These Documents

### For Project Planning
1. Read IMPLEMENTATION-RECOMMENDATIONS.md
2. Review effort estimates and priority levels
3. Plan sprints using the 3-sprint template
4. Estimate team capacity and timeline

### For Feature Development
1. Review relevant section in web-modules-analysis.md
2. Understand existing patterns and conventions
3. Check integration points
4. Follow code quality patterns from analysis
5. Use suggested implementation approaches from RECOMMENDATIONS.md

### For Code Review
1. Ensure new features follow module naming conventions
2. Verify proper error handling (see analysis for patterns)
3. Check for logging at appropriate levels
4. Verify integration points are correct
5. Ensure performance metrics are tracked

### For Documentation
1. Review "Documentation Requirements" in RECOMMENDATIONS.md
2. Use module documentation format from analysis as template
3. Include parameter tables and return structures
4. Provide integration point examples
5. Include command syntax examples

### For Debugging
1. Consult web-modules-summary.txt for quick module location
2. Review specific module section in analysis for:
   - Processing steps
   - Error handling
   - Logging points
3. Check integration points for upstream/downstream issues
4. Review configuration defaults

---

## Statistics

| Metric | Count |
|--------|-------|
| Core web modules | 16 |
| Plugin modules | 2 |
| Total modules analyzed | 18 |
| Total lines of code | ~5,800 |
| Implemented features | 20+ |
| Recommended enhancements | 12 |
| Configuration options | 8 |
| External dependencies | 5 |
| Integration points | 8 |
| CSS classes in menus | 6 |
| Skin cascade levels | 4 |
| Max recursion depth | 8 |
| Command timeout | 15s |
| Cache TTL | 1800s |
| Max template size | 5MB |

---

## Quick Links

### By Purpose
- **Content Serving:** web.render_skinned_content
- **Menu Generation:** plugin.web.menu.tree
- **Template Parsing:** web.process_template_recursive
- **Skinning:** web.skin_resolver
- **File Discovery:** web.scan_directory
- **Directory Listing:** plugin.web.content.dirlist
- **Command Execution:** web.execute_template_command
- **IPC Integration:** web.process_template_ipc
- **Asset Management:** web.assets.* (4 modules)

### By Development Phase
- **Phase 1 High-Priority:** Breadcrumbs, Command Registry, Menu Customization
- **Phase 2 Medium-Priority:** Access Control, Skin Assets, Versioning
- **Phase 3 Polish:** Scheduling, Search, Analytics

---

**Total Documentation:** 3 comprehensive documents
**Total Pages:** ~50 pages equivalent
**Ready for:** Development, architecture decisions, sprint planning, code review

