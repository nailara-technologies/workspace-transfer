# 🔒 Secret Scanner Pre-commit Hook

## Overview

The Secret Scanner is a pre-commit hook that automatically scans files for sensitive credentials (tokens, keys, passwords) **before** they are committed to the repository. This prevents accidental exposure of secrets in version control history.

---

## ✅ What It Detects

The scanner identifies the following secret patterns:

### GitHub Tokens
- **Classic tokens**: `ghp_*` (36 characters)
- **Fine-grained tokens**: `github_pat_*` (82 characters)  
- **OAuth tokens**: `gho_*` (36 characters)
- **App tokens**: `ghu_*` or `ghs_*` (36 characters)

### Cloud & Service Credentials
- **AWS Access Keys**: `AKIAIO*` format
- **SSH Private Keys**: `-----BEGIN RSA PRIVATE KEY-----`
- **Slack Tokens**: `xox[baprs]-*` format

### Generic Patterns
- **Passwords in URLs**: `https://user:password@host`
- **API Keys**: `API_KEY=*` patterns
- **Secret declarations**: `secret=*`, `password=*` patterns

---

## 🛠️ Installation

### For New Repositories

```bash
cd /path/to/your/repository
perl /home/claude/work/install-pre-commit-hook.pl
```

### For Existing Repositories

The installer will:
1. Detect your git repository
2. Backup any existing pre-commit hook
3. Install the secret scanner
4. Make it executable

---

## 🚀 Usage

### Normal Workflow

Once installed, the hook runs **automatically** on every commit:

```bash
git add myfile.txt
git commit -m "Update config"
```

If secrets are detected, you'll see:

```
🚨 SECRET DETECTION - COMMIT BLOCKED 🚨
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Found 1 potential secret(s) in 1 location(s):

  ❌ myfile.txt:42
     Type: GitHub Classic Token
     Match: ghp_1234...34AB

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### Override Options

**⚠️ Use these with extreme caution!**

#### 1. Bypass All Hooks
```bash
git commit --no-verify
```

#### 2. Bypass Secret Check Only
```bash
GIT_ALLOW_SECRETS=1 git commit
```

---

## 🔧 How It Works

### Scanning Process

1. **Triggered**: Runs automatically before each commit
2. **Scope**: Scans only files staged for commit (`git add`)
3. **Patterns**: Uses regex patterns to detect secrets
4. **Binary files**: Automatically skipped
5. **Performance**: Files >1MB skipped for speed

### Safe to Commit

The following patterns are **NOT** flagged:
- Placeholder text: `YOUR_TOKEN_HERE`, `INSERT_KEY`
- Environment variable names: `$GITHUB_TOKEN`
- Documentation examples with obvious fake values

---

## 📝 Best Practices

### Instead of Committing Secrets:

#### 1. Use Environment Variables
```bash
export GITHUB_TOKEN="ghp_..."
# In code: my $token = $ENV{GITHUB_TOKEN};
```

#### 2. Use Config Files (Gitignored)
```bash
echo "config/secrets.json" >> .gitignore
# Store actual secrets in config/secrets.json
```

#### 3. Use Placeholders in Code
```perl
my $token = 'YOUR_TOKEN_HERE';  # ✅ Safe
# my $token = 'ghp_real123...';  # ❌ Will be blocked
```

---

## 🧪 Testing

Run the test suite to verify detection:

```bash
perl /home/claude/work/test-secret-scanner.pl
```

Expected output:
```
✅ PASS: Clean file
✅ PASS: GitHub classic token
✅ PASS: GitHub fine-grained token
✅ PASS: SSH private key
✅ PASS: AWS access key
✅ PASS: Password in URL
✅ PASS: Safe placeholder
✅ PASS: Slack token

✅ All tests passed!
```

---

## 🔄 Maintenance

### Update Patterns

Edit `/home/claude/work/pre-commit-secret-scanner.pl`:

```perl
my %patterns = (
    'Custom Secret Type' => qr/your_regex_pattern/,
    # Add more patterns here
);
```

### Reinstall After Updates

```bash
perl /home/claude/work/install-pre-commit-hook.pl
```

### Disable Temporarily

```bash
mv .git/hooks/pre-commit .git/hooks/pre-commit.disabled
```

### Re-enable

```bash
mv .git/hooks/pre-commit.disabled .git/hooks/pre-commit
```

---

## 📊 Real-World Impact

### Before Secret Scanner

```
❌ Token committed → Detected by GitHub → Force push required
❌ Rewrite git history → Team disruption
❌ Revoke/rotate credentials → Service downtime risk
```

### After Secret Scanner

```
✅ Secret detected before commit → Immediate feedback
✅ Fix locally → No history rewrite needed
✅ Credentials stay secure → No rotation required
```

---

## 🆘 Troubleshooting

### False Positives

If the scanner flags legitimate content:

1. **Review the match**: Is it actually a secret?
2. **Refactor if possible**: Use placeholders or env vars
3. **Override if necessary**: Use `--no-verify` (document why!)

### Hook Not Running

```bash
# Check if hook exists
ls -la .git/hooks/pre-commit

# Check if executable
stat .git/hooks/pre-commit

# Reinstall
perl /home/claude/work/install-pre-commit-hook.pl
```

### Perl Dependencies

The scanner requires:
- Perl 5.24+
- Term::ANSIColor (core module)

---

## 📚 Files

- **Scanner**: `/home/claude/work/pre-commit-secret-scanner.pl`
- **Installer**: `/home/claude/work/install-pre-commit-hook.pl`
- **Tests**: `/home/claude/work/test-secret-scanner.pl`
- **Hook location**: `.git/hooks/pre-commit` (per repository)

---

## 🎯 Summary

✅ **Automatic protection** against accidental secret commits  
✅ **Zero configuration** after installation  
✅ **Fast scanning** with smart skip logic  
✅ **Clear feedback** when secrets detected  
✅ **Override options** for edge cases  

**Your repository is now protected against credential leaks!** 🛡️
