# GitHub Cheat-Sheet — MumbleCluster

## Standard docs push flow

```bash
# 1) go to repo
cd /data/github/mumblecluster

# 2) verify GitHub SSH auth (optional)
ssh -T git@github.com

# 3) inspect current repo state
git branch --show-current
git status
git remote -v
git diff
git diff --cached

# 4) optional hardening checks
git check-ignore -v README.md.bak
git ls-files | grep -Ei '(\.bak$|\.pem$|\.key$|token|secret|wireguard|openvpn|credential|passwd|htpasswd)' || true
git log --oneline -n 5
git show --stat HEAD

# 5) optional helper aliases
git config --global alias.sensitive '!git ls-files | grep -Ei "(\.pem$|\.key$|token|secret|wireguard|openvpn|credential|passwd|htpasswd)" || true'
git sensitive

git config --global alias.preflight '!pwd && echo && git rev-parse --show-toplevel && echo && git branch --show-current && echo && git remote -v && echo && git status && echo && git diff --cached --stat'
git preflight

# 6) stage only intended files
git add _cheatsheet_github.md

# 7) verify what is staged
git diff --cached

# 8) commit
git commit -m "github: hardened SOP _cheatsheet_github.md"

# 9) push to origin main
git push origin main
```
---

