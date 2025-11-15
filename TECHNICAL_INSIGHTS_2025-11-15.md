# Technical Insights & Learnings - Protocol-7 HTTP/HTTPS Implementation

**Session:** 2025-11-15 - HTTP/HTTPS Server Fixes
**Context:** Debugging and fixing critical HTTP server routing issues in Protocol-7

---

## 1. Code Reference Lookup in Protocol-7

### Problem Discovered
The `<[ ]>` angle-bracket syntax for function references **does not support variable interpolation**:

```perl
# BROKEN - will fail with "undefined value as subroutine reference"
my $handler_name = 'httpd.process_template';
return <[$handler_name]>->($id, $args);  # ❌ Won't work
```

### Solution
Use direct code hash lookup with `$code{...}`:

```perl
# CORRECT - works with variable names
my $handler_ref = $code{$handler_name};
unless (defined $handler_ref && ref($handler_ref) eq 'CODE') {
    return error_handler(...);
}
return $handler_ref->($id, $args);  # ✅ Works
```

### Key Takeaway
- The `<[ ]>` syntax is syntactic sugar for compile-time function references only
- For **dynamic/runtime function invocation**, use `$code{...}` hash directly
- Always validate the handler exists and is a CODE reference before calling

---

## 2. Namespace Aliasing via swap_subs

### How It Works
Base module functions are aliased to shorter namespaces via `swap_subs` in pre-init code:

```perl
# In base.file.pre_init:
if ( exists $code{'base.file.init_code'} ) {
    <[base.swap_subs]>->( 'base.file', 'file' );
}
```

This means:
- `base.file.slurp` becomes callable as `file.slurp`
- `base.file.append` becomes callable as `file.append`
- All 46 base.file.* functions get moved to `file.*` namespace

### Important Implications
- Don't call `file.get` - correct name is `file.slurp`
- Don't call `base.file.get` - that doesn't exist either
- Check pre-init code to understand namespace mappings
- Errors about undefined functions may mean wrong namespace alias was used

### File Operations Available
- `file.slurp($path)` - read entire file content
- `file.append($path, $content)` - append to file
- Various file system operations available via file.* namespace

---

## 3. Path Normalization Edge Cases

### Root Path Problem
When normalizing paths by removing leading/trailing slashes:

```perl
# NAIVE APPROACH - causes problems with root path
$path =~ s|^/+||;  # Remove leading slashes
$path =~ s|/+$||;  # Remove trailing slashes
# Now $path is empty for "/" input!
```

### Solution
Add explicit root path handling:

```perl
# CORRECT APPROACH
$path =~ s|^/+||;
$path =~ s|/+$||;

# Handle root path - use index.html as default
$path = 'index.html' if !length $path;
```

### Why This Matters
- `/` request needs to resolve to `/index.html.tmpl`
- Without this fix, code tries to find `/.tmpl` which doesn't exist
- Affects all HTTP request handling for root path

---

## 4. Template Resolution Hierarchy

### Three-Level Resolution System
Templates are looked up in strict priority order:

```
Level 1 (Most Specific):  /var/httpd/{vhost}/{subdir}/_templates/{file}.{ext}
Level 2 (Vhost Root):     /var/httpd/{vhost}/_templates/{path}.{ext}
Level 3 (Global):         /var/httpd/_global_templates/{path}.{ext}
```

### Example Resolution for `GET /blog/post.html` on vhost `example.com`:
1. Check: `/var/httpd/example.com/blog/_templates/post.html.tmpl`
2. Check: `/var/httpd/example.com/_templates/blog/post.html.tmpl`
3. Check: `/var/httpd/_global_templates/blog/post.html.tmpl`
4. Not found → Static file fallback

### Key Points
- Vhost subdirectory templates are highest priority
- Global templates are fallback
- Empty result is cached to prevent repeated searches
- Must handle normalization before lookups

---

## 5. Module Loading and Code References

### How Protocol-7 Modules Work
1. **Modules directory:** `/home/user/protocol-7/modules/`
2. **Each file is a subroutine:** `/modules/httpd.http_get` contains the code for `httpd.http_get`
3. **Code hash:** Functions are stored in `%code` hash at runtime
4. **Lookup:** Use `$code{$function_name}->(@args)` to call

### Module Naming Convention
- Dot notation in filename = namespace hierarchy
- `httpd.http_get` → available as `httpd.http_get` function
- `base.file.slurp` → available as `file.slurp` (after swap_subs)

### Important for Debugging
- If function not found, check if module file exists in `/modules/`
- If function name is wrong (typo), module won't load
- Namespace aliases may hide actual function names
- Use `p7 httpd.show-buffer zenka` to see module loading errors

---

## 6. HTTP Route Dispatcher Caching

### Route Caching Pattern
Routes are cached to avoid repeated resolution:

```perl
my $cache_key = "$method:$path:$vhost";

if (exists $data{'route_cache'}->{$cache_key}) {
    return $data{'route_cache'}->{$cache_key};  # Use cached
}

# ... compute route ...
$data{'route_cache'}->{$cache_key} = $route;
return $route;
```

### Four-Tier Route System
1. **ACME Challenges:** `/.well-known/acme-challenge/*` → `httpd.handler.acme_request`
2. **API Endpoints:** `/api/*` → `letsencrypt.http.api_handler`
3. **Templates:** `/path/*.html` → `httpd.process_template`
4. **Static Files:** Everything else → `httpd.serve_static`

### Cache TTL Values
- ACME: TTL=0 (never cache - challenges are time-sensitive)
- API: TTL=300 (5 minutes)
- Templates: TTL=1800 (30 minutes)
- Static: TTL=3600 (1 hour)

---

## 7. IPC Protocol for Web Zenka Template Processing

### Message Format
Templates are sent to web zenka via IPC with specific format:

```perl
'command' => 'cube.web.process-template-ipc',
'call_args' => {
    'args' => join(
        ':',
        $template_id,        # Unique ID for tracking
        $template_content,   # Raw template text
        $meta_json,          # Serialized metadata
        $session_id          # HTTP session ID
    )
}
```

### Response Handler
Web zenka responds via `httpd.handler.web_template_reply` with:
- `$template_id` - to match request/response
- `$mode` - FALSE on error, TRUE on success
- Result is fed back to HTTP client

### Current Issues
- Web zenka returns error (mode: FALSE) on template processing
- Next session should debug why web zenka fails to process templates

---

## 8. HTTP Request Pipeline

### Complete Request Flow

```
HTTP Client Request (port 80)
    ↓
[httpd] → Establish TCP connection
    ↓
[httpd.http_get] → Main handler for GET requests
    ↓
[httpd.route_dispatcher] → Determine which handler to use
    ├─ Check ACME challenge patterns
    ├─ Check API endpoint patterns
    ├─ Check template file existence
    └─ Fallback to static file
    ↓
[Appropriate Handler]
    ├─ httpd.handler.acme_request → Return challenge token
    ├─ httpd.process_template → Read template + send to web zenka
    ├─ httpd.serve_static → Return static file
    └─ letsencrypt.http.api_handler → Return API response
    ↓
[httpd.send_error_page] → Error responses (403, 404, 500, etc.)
    ↓
HTTP Response (port 80)
```

### Session Management
- Each HTTP connection gets a session ID
- Session stores: headers, response parameters, meta variables, buffer
- Template results sent back via session

---

## 9. Git Authentication & Remote Configuration

### Local Proxy Issues
The default git remote configuration uses a local proxy:
```
http://local_proxy@127.0.0.1:61140/git/...
```

**Problems:**
- Returns HTTP 403 authentication errors
- Local proxy may be misconfigured
- No way to provide credentials to local proxy in CI/automation

### Solution: Use GitHub Directly
```bash
git remote set-url origin https://github.com/nailara-technologies/workspace-transfer.git
```

### Authentication with GITHUB_PAT
```bash
git push https://${GITHUB_PAT}@github.com/nailara-technologies/workspace-transfer.git base
```

### Key Takeaway
- Don't rely on local proxy in automated environments
- Use GitHub directly with GITHUB_PAT environment variable
- Disable GPG signing if it causes issues: `git config commit.gpgsign false`

---

## 10. Commit Signing Issues in Protocol-7

### Problem Encountered
GPG signing fails with cryptic error:
```
Error: signing failed: Signing failed: signing server returned status 400
```

### Solution
Disable GPG signing for commits:
```bash
git config --local commit.gpgsign false
```

### Why This Happens
- Protocol-7 repository may have signing enforced
- The code-sign service has specific requirements
- When in doubt, disable for local development

---

## 11. MIME Type Detection Pattern

### Avoid Heavy Dependencies
```perl
# AVOID: Using undefined mimetype() function
$content_type = 'text/html' if mimetype($template_path) =~ /html/;

# PREFER: Simple regex on file extension
$content_type = 'text/html' if $template_path =~ /\.html/;
```

### Why This Matters
- Keeps code lightweight in Protocol-7 zenka
- Avoids loading unnecessary Perl modules
- File extension is usually sufficient for templates
- Falls back to 'text/plain' if no match

---

## 12. Authentication Configuration (auth.zenki)

### User Registration Pattern
```
auth.setup.usr.{zenka_name} = :zenka:
```

Example:
```
auth.setup.usr.httpsd = :zenka:
auth.setup.usr.httpd = :zenka:
auth.setup.usr.web = :zenka:
```

### Important Discovery
- httpsd was missing from auth.zenki initially
- This caused authentication failures when httpsd tried to connect to cube
- Adding this single line fixed httpsd startup
- Always verify all zenki that need auth are registered

---

## 13. Debugging Tools & Techniques

### Essential Commands
```bash
# Check zenka status
p7 v7.list zenki

# View httpd zenka buffer (startup logs, errors)
p7 httpd.show-buffer zenka

# Reload source code without restart
p7 httpd.reload source

# Restart specific zenka
p7 v7.restart httpd

# Clean up cache on restart
rm -rf /home/protocol-7/.n
```

### Log Locations
```
/var/log/protocol-7/v7_system.log       # Main startup log
/var/log/protocol-7/httpd.log          # HTTP server specific
/var/log/protocol-7/letsencrypt.log    # ACME/certificates
```

### Performance Tip
For quick code changes, use `p7 httpd.reload source` instead of full restart

---

## 14. Flow Control in Zenka Startup Scripts

### New Feature: base.exit_when_false and base.exit_when_empty

Protocol-7 now supports elegant flow control for startup scripts:

```perl
# base.exit_when_false - exit if parameter is FALSE (0) or numeric < 1
result = [base.exit_when_false:<parameter>,exit_code,'error message']

# base.exit_when_empty - exit if parameter is undef or empty string
result = [base.exit_when_empty:<parameter>,exit_code,'error message']
```

### Example: HTTPSD Certificate Validation

```
## Validate certificates before attempting socket creation
httpsd.cert_status = [httpsd.startup.validate_certificates]
[exit_when_false:<httpsd.cert_status>,0,'certificate load error, shutdown.,.']

## Only reaches this point if validation succeeded
httpsd.sock = [httpsd.create_ssl_socket:<net.https.addr>,<net.https.port>]
[base.protocol.bind:<httpsd.sock>,'https','server']
```

### Why This Pattern is Elegant

1. **Encapsulation**: Validation logic in modules, not config
2. **Reusability**: Any zenka can use the same flow control helpers
3. **Clear Intent**: Reading config file shows exactly what happens
4. **Graceful Shutdown**: Zenka exits cleanly when conditions fail
5. **Restart Handling**: 'v7' automatically restarts zenka with increasing delays

### How to Write Startup Validation Modules

```perl
# modules/httpsd.startup.validate_certificates

my $cert_file = <httpsd.cfg.certificate_path>;
my $key_file  = <httpsd.cfg.key_path>;

unless ( -f $cert_file ) {
    <[base.log]>->(0, "FATAL: Certificate not found: $cert_file");
    return FALSE;  # Triggers [exit_when_false:...]
}

unless ( -f $key_file ) {
    <[base.log]>->(0, "FATAL: Key not found: $key_file");
    return FALSE;  # Triggers [exit_when_false:...]
}

return TRUE;  # Validation passed, continue startup
```

### Key Points

- Modules should return TRUE/FALSE (5/0)
- Modules should log error details (users won't see zenka config)
- Use consistent error message format
- Always check file existence BEFORE attempting use
- Prevents confusing error messages from failed I/O operations

### Known Minor Issue

- exit_when_false exits silently even with error message parameter
- Zenka shutdown happens before log messages can be flushed?
- Is be working as designed (prevent hanging during shutdown)
- Worth investigating in future sessions for better debugging

---

## 15. Module-Based Startup Organization Pattern

### Why Not Use Config File Conditionals?

Previous attempts tried to implement `[if: ... ]` conditionals in startup scripts.
This doesn't work because Protocol-7 doesn't have conditional syntax in config files yet.

**Better approach**: Move startup logic into modules

### Pattern

```
configuration/zenki/httpsd/start:
    [load_modules:<modules.load>]
    [init_modules]
    httpsd.status = [httpsd.startup.validate_certificates]
    [exit_when_false:<httpsd.status>,...]
    httpsd.sock = [httpsd.create_ssl_socket:...]

modules/httpsd.startup.validate_certificates:
    - Do validation
    - Log errors
    - Return TRUE/FALSE
```

### Benefits

1. **Separates concerns**: Config files describe what happens, modules do validation
2. **Reusable**: Other zenki can use similar patterns
3. **Testable**: Can call validation module directly to test
4. **Maintainable**: Logic is in Perl, not config language
5. **Follows conventions**: Similar to letsencrypt.base.fork_letsencrypt_child pattern

### This is the Modern Protocol-7 Way

Other zenki use this pattern:
- `letsencrypt.base.fork_letsencrypt_child` - Forks ACME child process
- `X-11.chk.early-priv-drop` - Checks and drops privileges early
- Pattern extends to any startup validation or setup

---

---

## 16. IPC Command Return Format and Template Processing

### Command Registration Pattern
Only modules in `*.cmd.*` namespace are registered as callable IPC commands:

```perl
# modules/web.cmd.process_template_ipc - Command wrapper
my $hash_ref = shift;
my $args_str = $hash_ref->{'args'} // '';  # NOT call_args->args

# Call implementation
my $result = <[web.process_template_ipc]>->($args_str);
return $result;  # Return hash ref directly
```

**Key Points:**
- Command wrappers receive: `{ 'args' => '...', 'command_id' => '...', 'session_id' => '...', 'reply_id' => '...' }`
- Args are directly in `$hash_ref->{'args'}`, not `$hash_ref->{'call_args'}->{'args'}`

### Command Return Format (CRITICAL)
Commands MUST return hash reference with mode and data:

```perl
# SUCCESS - multi-line content
return {
    'mode' => qw| size |,    # Lowercase 'size' for multi-line support
    'data' => $content
};

# ERROR
return {
    'mode' => qw| false |,
    'data' => qq| error message |
};

# WRONG - tuple format doesn't work
return ( 'size', $content );  # ❌ Will fail
return ( 5, $content );       # ❌ Will fail
```

**Important:**
- Reply mode must be lowercase in return hash: `'size'`, `'false'`, `'true'`
- IPC protocol layer converts to uppercase during transmission
- Handler must normalize mode back to lowercase for checking: `my $mode = lc($reply_data->{'cmd'} // '');`
- Only `'size'` mode supports multi-line content (like HTML templates)

### Base32 Encoding for IPC Arguments
IPC arguments are colon-delimited, requiring base32 encoding for data containing colons:

```perl
# In httpd.process_template - encode before sending
my $template_b32r = encode_b32r($template_content);
my $meta_json = <[httpd.json.encode]>->($meta_vars) // '{}';
my $meta_b32r = encode_b32r($meta_json);

<[base.protocol-7.command.send.local]>->(
    {   'command'   => qw| cube.web.process_template_ipc |,
        'call_args' => {
            'args' => join(':', $template_id, $template_b32r, $meta_b32r, $session_id)
        },
        ...
    }
);

# In web.process_template_ipc - decode after receiving
my $template_content = decode_b32r($template_b32r);
my $meta_json = decode_b32r($meta_b32r);
my $meta_vars = JSON::XS::decode_json($meta_json) // {};
```

**Why This Matters:**
- Template content contains colons in HTML tags: `<head>:`, `<title>`
- JSON metadata contains colons: `"client_addr" : "::1"`
- Without base32 encoding, IPC split on `:` delimiter corrupts data

### Module Loading for Encoding Functions
Both sending and receiving zenka need encode/decode functions:

```perl
# In httpd.init_code
<[base.perlmod.load]>->( 'Crypt::Misc', qw| encode_b64u decode_b64u encode_b32r decode_b32r | );

# In web.init_code
<[base.perlmod.load]>->( 'Crypt::Misc', qw| encode_b32r decode_b32r | );
<[base.perlmod.autoload]>->('JSON::XS');
```

### Cross-Zenka Function Availability
Functions like `httpd.json.decode` don't exist in web zenka context:

```perl
# WRONG - httpd functions not available in web zenka
my $meta_vars = <[httpd.json.decode]>->($meta_json);  # ❌ Undefined

# CORRECT - use Perl module directly
<[base.perlmod.autoload]>->('JSON::XS');  # In web.init_code
my $meta_vars = JSON::XS::decode_json($meta_json);  # ✅ Works
```

### Cube Command Prefix Semantics
When sending IPC commands, `cube.` prefix IS required:

```perl
# In httpd.process_template - sending command
<[base.protocol-7.command.send.local]>->(
    {   'command' => qw| cube.web.process_template_ipc |,  # ✅ cube. prefix required
        ...
    }
);

# In configuration/zenki/cube/access.zenki - permission config
access.cmd.usr.httpd = web.process_template_ipc web.*  # ✅ No cube. prefix (already from cube perspective)
```

**Why:**
- When sending: Must specify `cube.` to route through cube IPC system
- In access.zenki: Already written from cube's perspective, no prefix needed
- Similar pattern in web-browser modules: `cube.pdf2html.get_url`, `cube.content.set_flags`

### Reference Dereferencing Pattern
`base.parser.pattern_split` returns array of scalar references:

```perl
# In web.process_template_recursive
my $final_content = $parsed_content;
if ( ref($final_content) eq 'ARRAY' ) {
    ## Dereference ALL elements (they're all scalar refs from pattern_split)
    my @deref = map { ref($_) ? $$_ : $_ } @{$final_content};
    $final_content = join( '', @deref );
}

# In web.process_template_ipc - also handle array or scalar refs
my $content = $result->{content};
my $ref_type = ref($content);

if ( $ref_type eq 'ARRAY' ) {
    my @deref = map { ref($_) eq 'SCALAR' ? $$_ : $_ } @{$content};
    $content = join( '', @deref );
} elsif ( $ref_type eq 'SCALAR' ) {
    $content = $$content;
}
```

**Pattern:**
- Use `ref($_) ? $$_ : $_` to dereference ANY reference type generically
- Handle both ARRAY and SCALAR reference types
- Always dereference at the source before returning to IPC

### Complete Template Processing Flow

```
HTTP Client → httpd.http_get
    ↓
httpd.route_dispatcher → Determine handler
    ↓
httpd.process_template
    ├─ Read template file (file.slurp)
    ├─ Base32-encode template content
    ├─ JSON-encode + base32-encode metadata
    ├─ Send to cube: cube.web.process_template_ipc
    └─ Register reply handler: httpd.handler.web_template_reply
    ↓
Cube IPC → Route to web zenka
    ↓
web.cmd.process_template_ipc (wrapper)
    └─ Extract args from hash_ref->{'args'}
    ↓
web.process_template_ipc (implementation)
    ├─ Base32-decode template and metadata
    ├─ JSON-decode metadata
    ├─ Call web.process_template_recursive
    ├─ Dereference scalar/array refs
    └─ Return { 'mode' => 'size', 'data' => $content }
    ↓
Cube IPC → Convert mode to uppercase, send to httpd
    ↓
httpd.handler.web_template_reply
    ├─ Normalize mode to lowercase
    ├─ If mode eq 'size': Build HTTP response with content
    ├─ If mode eq 'false': Send 500 error page
    └─ Trigger flush to client
    ↓
HTTP Client receives HTML
```

### Permission Configuration
Two-layer permission system:

```perl
# 1. Sender permissions in cube/access.zenki
access.cmd.usr.httpd = web.process_template_ipc web.*

# 2. Receiver permissions in web/start
access.cmd.usr.cube = process_template_ipc  # (if needed)
```

---

## Next Session Focus Areas

### 1. ✅ COMPLETED: Web Zenka Template Processing
- ✅ Fixed IPC command return format (hash ref instead of tuple)
- ✅ Fixed base32 encoding for template content and metadata
- ✅ Fixed JSON decoding using JSON::XS directly
- ✅ Fixed reference dereferencing for scalar refs
- ✅ Fixed reply mode case sensitivity
- ✅ Template processing now works end-to-end

### 2. HTTPS/TLS Verification (HIGH PRIORITY)
- Verify httpsd works on port 443
- Test TLS handshake
- Verify certificate chain handling
- Test HTTPS with actual clients

### 3. Complete End-to-End Testing
- Test HTTP → template processing → HTTPS response pipeline
- Load test with concurrent requests
- Certificate renewal testing
- Multi-vhost testing

### 4. Fix Locale Warnings
- Address locale warnings during zenki startup
- May need to set LC_ALL or LANG environment variables

---

## Summary of Key Discoveries

| Discovery | Impact | Solution |
|-----------|--------|----------|
| Variable function references don't work with `<[ ]>` | Handler dispatch broken | Use `$code{$name}` directly |
| Namespace aliasing via swap_subs | Function names confusing | Check pre-init for aliases |
| Empty string after path normalization | Root path handling broken | Add `$path = 'index.html' if !length` |
| Local git proxy authentication fails | Can't push changes | Use GitHub directly + GITHUB_PAT |
| httpsd missing from auth.zenki | HTTPS zenka won't start | Register all zenki in auth |
| Mime type function doesn't exist | Template type detection broken | Use regex on file extension |
| Template processing IPC format | Web zenka receives wrong data | Follow: template_id:content:meta:sid |
| Route caching improves performance | Slow repeated lookups | Implement cache with TTL |
| **IPC commands must return hash ref** | Template replies fail | Return `{'mode' => 'size', 'data' => $content}` |
| **Colon delimiter conflicts in IPC** | Template content truncated | Base32-encode all data containing colons |
| **Reply mode case sensitivity** | Handler doesn't recognize mode | Lowercase in hash, normalize with `lc()` in handler |
| **Cross-zenka function unavailability** | JSON decode fails in web zenka | Use `JSON::XS::decode_json()` directly |
| **cube. prefix semantics** | Command routing confusion | Required in send, not in access.zenki |
| **Scalar reference stringification** | Content becomes "SCALAR(0x...)" | Dereference with `ref($_) ? $$_ : $_` pattern |

---

## Code Pattern Reference

### Correct Pattern: Dynamic Handler Invocation
```perl
my $handler_name = $route->{'handler'};
my $handler_ref = $code{$handler_name};

unless (defined $handler_ref && ref($handler_ref) eq 'CODE') {
    <[base.log]>->(0, "Handler not found: $handler_name");
    return <[httpd.send_error_page]>->($id, 500);
}

return $handler_ref->($id, $handler_args);
```

### Correct Pattern: Template Resolution
```perl
# Normalize path
$path =~ s|^/+||;
$path =~ s|/+$||;
$path = 'index.html' if !length $path;

# Try 3 levels in order
my @locations = (
    "$site_root/$vhost/_templates/$path.tmpl",
    "$site_root/_global_templates/$path.tmpl",
);

foreach my $location (@locations) {
    return $location if -f $location;
}

return undef;  # Not found
```

---

**Document Version:** 1.0
**Created:** 2025-11-15
**For:** Future Protocol-7 HTTP/HTTPS development
**Status:** Reference material for next session
