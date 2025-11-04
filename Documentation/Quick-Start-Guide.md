# Quick Start: GitHub Migration - 5 Minute Setup

---

## 🚀 TL;DR - What You Need to Do

Our repository moved from GitLab to GitHub. Follow these 5 steps to get up and running:

---

## ⚡ 5-Step Quick Setup

### 1️⃣ Generate SSH Key (1 min)
```powershell
.\STEP1_sshKeygen.ps1
```
Copy the displayed public key.

### 2️⃣ Add Key to GitHub (1 min)
1. Go to: **https://github.com/settings/keys**
2. Click "**New SSH Key**"
3. Paste and save

### 3️⃣ Test Connection (1 min)
```powershell
.\STEP2_testGitHubConnection.ps1
```
Should see: `[SUCCESS] Connection Working!`

### 4️⃣ Update Repositories (5 min)

**Option A - Fresh Clone (Recommended):**
```powershell
.\STEP3_setup-int-repo.ps1
.\STEP4_setup-test-repo.ps1
.\STEP5_setup-prod-repo.ps1
```

**Option B - Update Existing:**
```powershell
# In each repo (INT, TEST, PROD):
git remote set-url origin git@github.com:trimble-transport/ttc-ctp-custint-exchange-platform-monolith.git
git fetch origin
git checkout stage-in  # or stage-ac or stage-pd
git pull
```

### 5️⃣ Test Daily Update (1 min)
```powershell
.\DailyUpdate.ps1
```

---

## 📋 Key Changes

| What | Old | New |
|------|-----|-----|
| **Platform** | GitLab | GitHub |
| **INT Branch** | `3.100/in` | `stage-in` |
| **TEST Branch** | `3.100/ac` | `stage-ac` |
| **PROD Branch** | `3.100/pd` | `stage-pd` |
| **Repo URL** | gitlab.office.transporeon.com | github.com/trimble-transport/... |

---

## 🆘 Quick Troubleshooting

**"Permission denied"**
→ Add your SSH key to: https://github.com/settings/keys

**"Branch not found"**
→ Use new branch names: `stage-in`, `stage-ac`, `stage-pd`

**TortoiseGit fails**
→ Settings → Network → SSH client → `C:\Windows\System32\OpenSSH\ssh.exe`

---

## ✅ Done!

Your daily workflow stays the same:
- `.\DailyUpdate.ps1` - Get latest changes
- `git add`, `git commit`, `git push` - Works as before

---

**Questions?** See full announcement email or contact [SUPPORT].

**Deadline:** [INSERT DATE]

---

_Keep this handy as a reference card!_

