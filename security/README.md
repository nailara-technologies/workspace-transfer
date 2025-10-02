# 🔒 Security Tools

This directory contains security automation tools for protecting the repository.

---

## 🛡️ Secret Scanner Pre-commit Hook

**Prevents accidental commits of GitHub tokens, SSH keys, and other secrets.**

### Quick Install

```bash
cd /path/to/workspace-transfer
perl security/hooks/install-pre-commit-hook.pl
```

### Test

```bash
perl security/hooks/test-secret-scanner.pl
```

### Documentation

See [SECRET_SCANNER_GUIDE.md](./SECRET_SCANNER_GUIDE.md) for complete documentation.

---

## 📁 Files

- `SECRET_SCANNER_GUIDE.md` - Complete documentation
- `hooks/pre-commit-secret-scanner.pl` - The secret scanner
- `hooks/install-pre-commit-hook.pl` - Installation script
- `hooks/test-secret-scanner.pl` - Test suite

---

## 🎯 What This Prevents

✅ GitHub tokens leaking into commits  
✅ SSH private keys in repository  
✅ AWS credentials in code  
✅ Passwords and API keys  
✅ Force-push history rewrites  

**Install once, protected forever!** 🚀
