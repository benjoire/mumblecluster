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
git add .gitignore _cheatsheet_github.md

# 7) verify what is staged
git diff --cached

# 8) commit
git commit -m "github: flows hardened _cheatsheet_github.md"

# 9) push to origin main
git push origin main
```

---

## Clean README / CHANGELOG replacement flow

Use this when the updated files currently exist under temporary names such as:

- `README_MumbleCluster_updated.md`
- `CHANGELOG_updated.md`

```bash
cd /data/github/mumblecluster

# replace files cleanly
mv README_MumbleCluster_updated.md README.md
cp /path/to/CHANGELOG_updated.md CHANGELOG.md

# inspect state
git status
git diff
git diff --cached

# stage only intended files
git add README.md CHANGELOG.md .gitignore

# final review
git diff --cached

# commit + push
git commit -m "docs: refine datapath findings and dual-lane networking model"
git push origin main
```

---

## Fast pre-push sanity routine

```bash
cd /data/github/mumblecluster
git preflight
git sensitive
git diff --cached
```

---

## Notes

- `ssh -T git@github.com` is mainly an auth/connectivity test. Once SSH is stable, it does not need to be run before every push.
- `.gitignore` affects untracked files before staging. It does **not** automatically stop Git from tracking files that were already committed earlier.
- Prefer:
  - `git add README.md CHANGELOG.md .gitignore`
- Over:
  - `git add -A`
- Last safe checkpoint before commit:
  - `git diff --cached`

---

## Common failure patterns

### Wrong folder
```bash
pwd
git rev-parse --show-toplevel
```

### Not a git repository
You are likely one directory too high.
Expected repo path:
```bash
cd /data/github/mumblecluster
```

### Sensitive alias throws `unknown switch 'E'`
Cause:
- alias was created without shell execution mode (`!`)

Fix:
```bash
git config --global alias.sensitive '!git ls-files | grep -Ei "(\.pem$|\.key$|token|secret|wireguard|openvpn|credential|passwd|htpasswd)" || true'
```

### `.gitignore` does not seem to work
Possible cause:
- file is already tracked

Check:
```bash
git ls-files | grep '\.bak$'
```

Untrack while keeping local file:
```bash
git rm --cached <file>
```
