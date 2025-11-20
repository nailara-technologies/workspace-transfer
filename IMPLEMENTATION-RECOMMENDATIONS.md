# Skinnable Content Plugin with Menu Awareness - Implementation Guide

## Status Summary

All core template processing, skinning, menu generation, and content serving features are **ALREADY IMPLEMENTED**. The system is production-ready and functional. Below are recommendations for enhancing it with additional features for your skinnable content plugin.

---

## What You Get "For Free" (Already Implemented)

### Foundation Tier
- Recursive template processing with 8-level depth limiting
- Meta variable substitution (`<{varname}>`)
- Command execution with timeout protection (`<[command:args]>`)
- Performance metrics and caching (30-minute TTL)

### Content Serving Tier
- File loading from `/data/web/{vhost}/{path}`
- Index file resolution (txt > md > html)
- Directory listing generation as fallback
- Content type detection
- Title extraction from headings or filename

### Menu & Navigation Tier
- Hierarchical menu generation from filesystem structure
- Active path highlighting (CSS classes: active, current)
- Recursive submenu expansion (depth: 3 by default)
- Directory-aware menu items with clickable links
- Lazy expansion (only expands active path)

### Skinning Tier
- 4-level cascade: user > device > dark mode > default
- Device detection (mobile/tablet/desktop from User-Agent)
- Time-based dark mode (20:00-07:59)
- User preference override
- Metadata support (name, version, author, description)
- Skin caching for performance

### Directory Scanning Tier
- Recursive traversal
- File type detection (txt, md, html)
- Numeric prefix handling (01_name, 02_name, etc.)
- File stats gathering (size, modification time)
- Duplicate name resolution (directories preferred)

---

## Recommended Enhancements for Your Plugin

### Phase 1: High-Impact Features (Immediate)

#### 1. Breadcrumb Navigation
**Requirement:** Users need to understand their position and navigate up
**Implementation:**
```perl
# Create web.breadcrumbs module
# Input: current_path, base_url
# Output: HTML breadcrumb trail
# Example: Home > Section > Subsection > Current Page

# Can derive from:
# - current_path (split on '/')
# - menu tree (already available via plugin.web.menu.tree)
```

**Effort:** Low (1-2 hours)
**Files to Create:** 1 new module
**Dependencies:** Existing web.scan_directory

#### 2. Template Command Registry
**Requirement:** Operators need to discover available commands without reading code
**Implementation:**
```perl
# Create web.cmd.commands module (list available commands)
# Create web.commands.registry (introspection)
# Scan $code{} namespace for web.* modules
# Extract documentation from comments
# Build registry with: name, description, parameters, examples
```

**Effort:** Medium (3-4 hours)
**Files to Create:** 2-3 modules
**Dependencies:** Existing command execution framework

#### 3. Enhanced Menu Customization
**Requirement:** Menu items beyond filesystem with custom ordering
**Implementation:**
```perl
# Extend menu.yaml support:
# - label: Custom Menu Label
#   path: /custom/path          # allows external paths
#   order: 10
#   icon: icon-name
#   hidden: false
#   children:
#     - label: Submenu Item
#       path: /sub/path

# Update plugin.web.menu.tree to:
# 1. Read menu.yaml at each level
# 2. Support custom links
# 3. Merge filesystem items with menu.yaml definitions
# 4. Apply custom ordering
```

**Effort:** Medium (3-4 hours)
**Files to Modify:** plugin.web.menu.tree
**Dependencies:** YAML::Tiny (already loaded)

#### 4. Cache Invalidation on Content Change
**Requirement:** Stale content shouldn't be served when files change
**Implementation:**
```perl
# Create web.cache.invalidate module
# Track file modification times
# On cache hit, verify file hasn't changed
# Auto-invalidate if mtime > cache time
# Add hook points for manual cache clear

# Add to web.render_skinned_content:
# - Check file mtime vs cache mtime
# - Invalidate if file is newer
```

**Effort:** Low (2-3 hours)
**Files to Modify:** web.render_skinned_content
**Files to Create:** 1 new module

#### 5. Position-Aware Menu Highlighting
**Requirement:** Better indication of where user is in hierarchy
**Implementation:**
```perl
# Enhance plugin.web.menu.tree:
# - Add data-depth attribute to menu items
# - Add CSS class for depth level (depth-1, depth-2, etc.)
# - Include current position path in output
# - Add visual breadcrumb in menu HTML

# Output example:
# <nav class="web-menu-tree" data-current-path="section/subsection">
#   <ul class="menu-level-0">
#     <li class="menu-item active depth-0">
#       <a href="/section">Section</a>
#       <ul class="menu-level-1 submenu depth-1">
#         <li class="menu-item current depth-1">
#           <a href="/section/subsection">Subsection</a>
#         </li>
#       </ul>
#     </li>
#   </ul>
# </nav>
```

**Effort:** Low (1-2 hours)
**Files to Modify:** plugin.web.menu.tree
**Dependencies:** None

---

### Phase 2: Medium-Impact Features (1-2 week sprint)

#### 6. Access Control Integration
**Requirement:** Per-page permissions for multi-user sites
**Implementation:**
```perl
# Create web.acl module (Access Control List)
# Read permissions from /data/web/{vhost}/.acl or metadata
# Check user role/permissions before rendering
# Filter menu items by permission
# Return 403 Forbidden for unauthorized access

# Integration points:
# - Modify web.render_skinned_content to check permissions
# - Modify plugin.web.menu.tree to filter by permission
# - Add permission checking module
```

**Effort:** Medium (4-6 hours)
**Files to Create:** 2-3 modules
**Dependencies:** Requires auth/permission system integration

#### 7. Skin Asset Injection
**Requirement:** CSS/JS files from skin injected into final HTML
**Implementation:**
```perl
# Create web.skin.assets module
# Scan skin directory for:
# - CSS files in /css/ subdirectory
# - JavaScript files in /js/ subdirectory
# Generate <link> and <script> tags
# Inject into <{content}> placeholder in skin template

# Update web.render_skinned_content to:
# 1. Resolve skin via web.skin_resolver
# 2. Call web.skin.assets for asset list
# 3. Add to meta_vars before template processing
# 4. Skin template references: <{skin_css}> and <{skin_js}>

# Example in skin template:
# <head>
#   <{skin_css}>
# </head>
# <body>
#   <{content}>
#   <{skin_js}>
# </body>
```

**Effort:** Medium (4-5 hours)
**Files to Create:** 1-2 modules
**Files to Modify:** web.render_skinned_content
**Dependencies:** web.skin_resolver (already exists)

#### 8. Content Versioning & Draft Workflow
**Requirement:** Publish/unpublish workflow, version history
**Implementation:**
```perl
# Create web.content.versions module
# Track multiple versions of each file
# Maintain .versions/ directory with version metadata
# Support draft/published states

# File structure:
# /data/web/vhost/page.md           (published version)
# /data/web/vhost/.versions/
#   page.md.001.draft              (draft backup)
#   page.md.001.published          (published backup with metadata)
#   page.md.001.metadata.yaml      (version metadata)

# Extend web.render_skinned_content to:
# 1. Check for draft state
# 2. Require permission to view draft
# 3. Show version indicator
# 4. Include revision info in meta
```

**Effort:** Medium-High (6-8 hours)
**Files to Create:** 2-3 modules
**Files to Modify:** web.render_skinned_content
**Dependencies:** New (version storage system)

---

### Phase 3: Advanced Features (Polish & Optimization)

#### 9. Menu State Persistence
**Requirement:** Remember expanded/collapsed menu state across sessions
**Implementation:**
```perl
# Add to menu HTML:
# - data-item-id attributes for JavaScript targeting
# - data-collapsed attribute for state tracking
# - JavaScript to save state to localStorage/cookie
# Load state from meta variables in skin template

# Update plugin.web.menu.tree to accept:
# - collapsed_items list (from user preferences)
# - Generate proper data attributes
# - Provide CSS hooks for styling (collapsed class)
```

**Effort:** Low-Medium (2-3 hours)
**Files to Modify:** plugin.web.menu.tree
**Dependencies:** Client-side JavaScript (provide template)

#### 10. Publication Scheduling
**Requirement:** Schedule content to go live at specific date/time
**Implementation:**
```perl
# Create web.content.schedule module
# Read publish_at, expires_at from file metadata
# Check timestamps during rendering
# Return 404 or "Coming Soon" if not yet published
# Auto-unpublish if expiration reached

# Metadata format in .metadata.yaml:
# publish_at: 2025-11-25 10:00:00
# expires_at: 2026-01-01 00:00:00
```

**Effort:** Medium (4-5 hours)
**Files to Create:** 1-2 modules
**Files to Modify:** web.render_skinned_content
**Dependencies:** Timestamp parsing

#### 11. Content Search/Index
**Requirement:** Full-text search across all content
**Implementation:**
```perl
# Create web.search.index module
# Scan /data/web/ and build search index
# Support multiple formats (txt, md, html)
# Create web.cmd.search for CLI search
# Create plugin.web.search.form for search UI
# Return ranked results with snippet preview
```

**Effort:** High (8-10 hours)
**Files to Create:** 3-4 modules
**Dependencies:** Search library (DB_File, etc.)

#### 12. Analytics & Usage Tracking
**Requirement:** Track page views, popular content, user paths
**Implementation:**
```perl
# Create web.analytics module
# Log: timestamp, path, vhost, session, user_agent
# Aggregate: views per page, top pages, referrers
# Create web.cmd.analytics for reports
# Generate metrics JSON for visualization

# Store in: /var/log/web-analytics/ or database
```

**Effort:** Medium-High (6-8 hours)
**Files to Create:** 2-3 modules
**Dependencies:** Logging framework

---

## Integration Architecture Recommendation

```
┌──────────────────────────────────────────────────────────┐
│              HTTP Request (from browser)                  │
└────────────────┬─────────────────────────────────────────┘
                 │
                 ▼
┌──────────────────────────────────────────────────────────┐
│   httpd zenka (handles HTTP protocol)                    │
│   Calls via IPC: web.process_template_ipc               │
└────────────────┬─────────────────────────────────────────┘
                 │ IPC call with base32r encoding
                 ▼
┌──────────────────────────────────────────────────────────┐
│   Protocol-7 web zenka (content processing)              │
│                                                           │
│   1. web.render_skinned_content (entry point)           │
│      ├─ web.scan_directory (discover files)            │
│      ├─ web.process_template_recursive (render)         │
│      │  └─ web.execute_template_command (exec)         │
│      ├─ web.skin_resolver (resolve skin)               │
│      │  └─ [NEW] web.skin.assets (get CSS/JS)          │
│      ├─ plugin.web.menu.tree (generate menu)           │
│      │  └─ [NEW] web.breadcrumbs (add breadcrumbs)     │
│      └─ [NEW] web.acl (check permissions)              │
│                                                           │
│   2. Supporting systems:                                │
│      ├─ web.cache (with invalidation)                  │
│      ├─ web.assets.registry (track resources)          │
│      ├─ [NEW] web.content.versions (versioning)        │
│      ├─ [NEW] web.content.schedule (scheduling)        │
│      └─ [NEW] web.analytics (tracking)                 │
│                                                           │
│   3. Operator commands:                                 │
│      ├─ web.cmd.process-template                       │
│      ├─ web.cmd.skin                                   │
│      ├─ [NEW] web.cmd.commands (introspection)         │
│      ├─ [NEW] web.cmd.cache (management)               │
│      ├─ [NEW] web.cmd.versions (version mgmt)          │
│      └─ [NEW] web.cmd.analytics (reports)              │
│                                                           │
└────────────────┬─────────────────────────────────────────┘
                 │ IPC response with rendered HTML
                 ▼
┌──────────────────────────────────────────────────────────┐
│   httpd zenka (sends HTTP response to browser)          │
└──────────────────────────────────────────────────────────┘
```

---

## Recommended Implementation Order

### Sprint 1 (Week 1-2): Foundation
1. Add breadcrumb generation (quick win)
2. Implement template command registry
3. Enhance menu customization (menu.yaml)
4. Add cache invalidation

**Deliverable:** Enhanced content system ready for custom skinnable sites

### Sprint 2 (Week 3-4): Security & Features
5. Implement access control (ACL)
6. Add skin asset injection
7. Position-aware menu highlighting

**Deliverable:** Multi-user capable with fine-grained control

### Sprint 3 (Week 5+): Polish
8. Content versioning
9. Publication scheduling
10. Menu state persistence
11. Search/analytics (as time permits)

**Deliverable:** Enterprise-grade content management features

---

## Estimated Effort Summary

| Feature | Effort | Priority | Sprint |
|---------|--------|----------|--------|
| Breadcrumbs | 1-2h | HIGH | 1 |
| Command Registry | 3-4h | HIGH | 1 |
| Menu Customization | 3-4h | HIGH | 1 |
| Cache Invalidation | 2-3h | HIGH | 1 |
| Position-Aware Menu | 1-2h | HIGH | 2 |
| Access Control | 4-6h | HIGH | 2 |
| Skin Asset Injection | 4-5h | HIGH | 2 |
| Content Versioning | 6-8h | MEDIUM | 3 |
| Publish Scheduling | 4-5h | MEDIUM | 3 |
| Menu Persistence | 2-3h | MEDIUM | 3 |
| Search | 8-10h | MEDIUM | 3 |
| Analytics | 6-8h | LOW | 3 |
| **TOTAL** | **47-62h** | — | — |

---

## Code Quality Notes

The existing web module system shows excellent code quality:

✓ Consistent naming conventions (web.* namespace)
✓ Proper error handling with graceful degradation
✓ Comprehensive logging at multiple levels
✓ Performance metrics built-in
✓ Security considerations (path traversal prevention, etc.)
✓ Modular design with clear separation of concerns
✓ IPC integration for multi-process communication

**Recommendation:** Follow these patterns when implementing new features.

---

## Testing Strategy

For each new feature:

1. **Unit tests** - Test individual modules
2. **Integration tests** - Test with existing web system
3. **Manual tests** - Test through web interface
4. **Performance tests** - Measure impact on rendering time
5. **Security tests** - Verify path traversal, XSS, etc. are prevented

---

## Documentation Requirements

Create documentation for:
- Template command syntax and available commands
- Skin creation guide (structure, metadata.yaml, assets)
- Menu configuration (menu.yaml format)
- Content file formats and metadata
- Access control configuration
- Configuration reference (all web.cfg.* options)
- Operator command reference
- Troubleshooting guide

---

## Conclusion

The Protocol-7 web module system provides a **solid, production-ready foundation** for a skinnable content management system. All core features are implemented. The recommended enhancements will add enterprise-grade capabilities while maintaining code quality and performance.

The modular architecture makes incremental feature addition straightforward, allowing you to prioritize based on your specific needs.

**Estimated Total Development Time: 50-65 hours for all recommended features**

---

**Analysis Date:** 2025-11-20
**Modules Analyzed:** 18 core web modules + 2 plugin modules
**Total Code Base:** ~5,800 lines
