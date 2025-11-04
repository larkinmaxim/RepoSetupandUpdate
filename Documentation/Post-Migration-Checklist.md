# Post-Migration Checklist

## 📋 Verification & Testing Checklist

Use this checklist to verify the migration was successful and everything is working correctly.

---

## ✅ File Verification

### PowerShell Scripts
- [ ] `STEP1_sshKeygen.ps1` - References GitHub (not GitLab)
- [ ] `STEP2_testGitLabConnection.ps1` - All GitHub references updated
- [ ] `STEP3_setup-int-repo.ps1` - Uses GitHub URL and `stage-in` branch
- [ ] `STEP4_setup-test-repo.ps1` - Uses GitHub URL and `stage-ac` branch
- [ ] `STEP5_setup-prod-repo.ps1` - Uses GitHub URL and `stage-pd` branch
- [ ] `DailyUpdate.ps1` - No version detection, uses static branch names

### Documentation Files
- [ ] `README.md` - All GitHub references
- [ ] `docs/README.md` - Updated
- [ ] `docs/STEP1_sshKeygen.md` - References GitHub
- [ ] `docs/STEP2_testGitHubConnection.md` - New file created
- [ ] `docs/STEP3_setup-int-repo.md` - GitHub URL and `stage-in`
- [ ] `docs/STEP4_setup-test-repo.md` - GitHub URL and `stage-ac`
- [ ] `docs/STEP5_setup-prod-repo.md` - GitHub URL and `stage-pd`
- [ ] `docs/DailyUpdate.md` - Updated for static branches

### Migration Documentation
- [ ] `Documentation/GitLab-to-GitHub-Migration-Plan.md` - Created
- [ ] `Documentation/Migration-Changes-Detailed.md` - Created
- [ ] `Documentation/Migration-Implementation-Summary.md` - Created

---

## 🧪 Functional Testing

### Test 1: SSH Key Generation
```powershell
.\STEP1_sshKeygen.ps1 -Email "test@example.com"
```
- [ ] Script runs without errors
- [ ] Public key displayed
- [ ] Instructions mention GitHub (not GitLab)
- [ ] URL shown is `https://github.com/settings/keys`

### Test 2: GitHub Connection Test
```powershell
.\STEP2_testGitHubConnection.ps1
```
- [ ] Script runs without errors
- [ ] Connects to `github.com`
- [ ] Success message mentions GitHub
- [ ] Error messages reference GitHub settings

### Test 3: INT Repository Setup
```powershell
.\STEP3_setup-int-repo.ps1
```
- [ ] Default URL is GitHub repository
- [ ] Default branch is `stage-in`
- [ ] Clone succeeds
- [ ] SSH remote URL is set to GitHub
- [ ] No GitLab references in output

### Test 4: TEST Repository Setup
```powershell
.\STEP4_setup-test-repo.ps1
```
- [ ] Default URL is GitHub repository
- [ ] Default branch is `stage-ac`
- [ ] Clone succeeds
- [ ] SSH remote URL is set to GitHub
- [ ] No GitLab references in output

### Test 5: PROD Repository Setup
```powershell
.\STEP5_setup-prod-repo.ps1
```
- [ ] Default URL is GitHub repository
- [ ] Default branch is `stage-pd`
- [ ] Clone succeeds
- [ ] SSH remote URL is set to GitHub
- [ ] No GitLab references in output

### Test 6: Daily Update
```powershell
.\DailyUpdate.ps1
```
- [ ] No version detection occurs
- [ ] Uses branch names: `stage-in`, `stage-ac`, `stage-pd`
- [ ] All three repositories update successfully
- [ ] Progress bars display correctly
- [ ] Summary shows correct branch names
- [ ] No version number in summary

---

## 🔍 Code Review Checklist

### Search for Remaining GitLab References
Run these searches to ensure no GitLab references remain:

```powershell
# Search for GitLab in PowerShell files
Get-ChildItem -Filter *.ps1 -Recurse | Select-String -Pattern "gitlab" -CaseSensitive:$false

# Search for old GitLab URL
Get-ChildItem -Filter *.ps1 -Recurse | Select-String -Pattern "gitlab.office.transporeon.com"

# Search for GitLab in documentation
Get-ChildItem -Filter *.md -Recurse | Select-String -Pattern "gitlab" -CaseSensitive:$false

# Search for old branch patterns
Get-ChildItem -Filter *.ps1 -Recurse | Select-String -Pattern "3\.100"
```

**Expected Results:**
- [ ] No GitLab references in active scripts (STEP*.ps1, DailyUpdate.ps1)
- [ ] No GitLab references in active documentation (README.md, docs/*.md)
- [ ] No `3.100` version references in active scripts
- [ ] Only migration documentation should reference old GitLab URLs

### Branch Name Verification
```powershell
# Check for new branch names in scripts
Get-ChildItem -Filter *.ps1 -Recurse | Select-String -Pattern "stage-in|stage-ac|stage-pd"
```

**Expected Results:**
- [ ] STEP3 uses `stage-in`
- [ ] STEP4 uses `stage-ac`
- [ ] STEP5 uses `stage-pd`
- [ ] DailyUpdate.ps1 uses all three branch names

---

## 🔐 Security & Access Checklist

### GitHub Access
- [ ] GitHub repository URL is correct: `github.com/trimble-transport/ttc-ctp-custint-exchange-platform-monolith`
- [ ] Repository is accessible (check in browser)
- [ ] All three branches exist on GitHub:
  - [ ] `stage-in` branch exists
  - [ ] `stage-ac` branch exists
  - [ ] `stage-pd` branch exists

### SSH Configuration
- [ ] SSH keys can be generated for GitHub
- [ ] SSH connection to `github.com` works
- [ ] SSH authentication succeeds
- [ ] No SSH references to `gitlab.office.transporeon.com` remain

---

## 📚 Documentation Quality Checklist

### README.md
- [ ] Title mentions GitHub
- [ ] Clone instructions work
- [ ] All URLs are GitHub URLs
- [ ] Branch names are updated
- [ ] Examples use new branch names
- [ ] Troubleshooting is relevant to GitHub

### Script Documentation (docs/*.md)
- [ ] All script docs match actual script behavior
- [ ] Parameters documented correctly
- [ ] Examples use GitHub URLs
- [ ] Examples use new branch names
- [ ] No broken internal links

### Migration Documentation
- [ ] Migration plan is complete
- [ ] Detailed changes are accurate
- [ ] Implementation summary is accurate
- [ ] All three documents are consistent

---

## 🎯 End-User Readiness Checklist

### For New Users
- [ ] Can follow README instructions from scratch
- [ ] All steps work in sequence (STEP1 → STEP2 → STEP3 → STEP4 → STEP5)
- [ ] DailyUpdate works after setup
- [ ] Error messages are helpful and accurate
- [ ] No confusion about which platform (GitHub vs GitLab)

### For Existing Users
- [ ] Migration path is documented
- [ ] Option to update existing clones is clear
- [ ] Option to re-clone fresh is clear
- [ ] No loss of local changes (if following instructions)
- [ ] Can switch from old to new smoothly

---

## 🐛 Known Issues & Limitations

Document any known issues discovered during testing:

- [ ] Issue 1: _____________________________________
- [ ] Issue 2: _____________________________________
- [ ] Issue 3: _____________________________________

---

## ✅ Final Sign-Off

### Technical Verification
- [ ] All files updated
- [ ] All tests passed
- [ ] No GitLab references in active code
- [ ] All GitHub URLs correct
- [ ] All branch names updated

### Documentation Verification
- [ ] README.md is accurate
- [ ] All docs/*.md files are accurate
- [ ] Migration documentation is complete
- [ ] No broken links

### Functional Verification
- [ ] Can generate SSH keys
- [ ] Can test GitHub connection
- [ ] Can clone INT repository
- [ ] Can clone TEST repository
- [ ] Can clone PROD repository
- [ ] Can run daily updates
- [ ] All operations work end-to-end

---

## 📝 Sign-Off

**Verified By:** _____________________  
**Date:** _____________________  
**Status:** ☐ Passed ☐ Failed  
**Notes:** _____________________

---

**Checklist Version:** 1.0  
**Date Created:** November 4, 2025  
**Purpose:** Post-migration verification for GitLab to GitHub migration

