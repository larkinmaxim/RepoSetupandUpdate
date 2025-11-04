# GitLab to GitHub Migration Implementation Plan

## 📊 Executive Summary

**Migration Status:** GitLab → GitHub  
**New Repository:** https://github.com/trimble-transport/ttc-ctp-custint-exchange-platform-monolith/  
**Date:** November 4, 2025

### Branch Mapping Changes

| Environment | Old GitLab Branch | New GitHub Branch |
|-------------|-------------------|-------------------|
| **PROD** | `3.100/pd` | `stage-pd` |
| **TEST** | `3.100/ac` | `stage-ac` |
| **INT** | `3.100/in` | `stage-in` |

---

## 🔍 Analysis: What Needs to Change

### 1. **Repository URLs**
- **Old:** `https://gitlab.office.transporeon.com/Development/portfolio.git`
- **Old SSH:** `git@gitlab.office.transporeon.com:Development/portfolio.git`
- **New:** `https://github.com/trimble-transport/ttc-ctp-custint-exchange-platform-monolith.git`
- **New SSH:** `git@github.com:trimble-transport/ttc-ctp-custint-exchange-platform-monolith.git`

### 2. **Branch Naming Convention**
- **Changed from:** Version-based branches (e.g., `3.100/in`, `3.100/ac`, `3.100/pd`)
- **Changed to:** Stage-based branches (e.g., `stage-in`, `stage-ac`, `stage-pd`)

### 3. **Authentication Method**
- **Old:** GitLab SSH keys (gitlab.office.transporeon.com)
- **New:** GitHub SSH keys or Personal Access Tokens (github.com)

### 4. **Files Requiring Updates**

#### **PowerShell Scripts:**
1. ✅ `STEP1_sshKeygen.ps1` - SSH key generation for GitLab
2. ✅ `STEP2_testGitLabConnection.ps1` - GitLab connection test
3. ✅ `STEP3_setup-int-repo.ps1` - INT repository setup
4. ✅ `STEP4_setup-test-repo.ps1` - TEST repository setup
5. ✅ `STEP5_setup-prod-repo.ps1` - PROD repository setup
6. ✅ `DailyUpdate.ps1` - Daily update script with version detection

#### **Documentation Files:**
1. ✅ `README.md` - Main documentation
2. ✅ `docs/STEP1_sshKeygen.md`
3. ✅ `docs/STEP2_testGitLabConnection.md`
4. ✅ `docs/STEP3_setup-int-repo.md`
5. ✅ `docs/STEP4_setup-test-repo.md`
6. ✅ `docs/STEP5_setup-prod-repo.md`
7. ✅ `docs/DailyUpdate.md`
8. ✅ `docs/README.md`

---

## 📋 Implementation Plan

### **Phase 1: Update Core Scripts** (Priority: HIGH)

#### Task 1.1: Update STEP1_sshKeygen.ps1
**Changes Required:**
- Replace GitLab URL references with GitHub
- Update instructions to point to GitHub SSH settings
- Change: `https://gitlab.office.transporeon.com/-/user_settings/ssh_keys`
- To: `https://github.com/settings/keys`
- Update test command from `git@gitlab.office.transporeon.com` to `git@github.com`

#### Task 1.2: Create STEP2_testGitHubConnection.ps1
**Changes Required:**
- Replace GitLab host with GitHub: `github.com`
- Update connection test: `ssh -T git@github.com`
- Update success message to expect GitHub welcome message
- Remove GitLab-specific troubleshooting steps

#### Task 1.3: Update STEP3_setup-int-repo.ps1
**Changes Required:**
- Change default `RemoteUrl` parameter from GitLab to GitHub
- Change default `BranchName` from `3.100/in` to `stage-in`
- Update SSH remote URL configuration (line 176)
- Update error messages and documentation links

#### Task 1.4: Update STEP4_setup-test-repo.ps1
**Changes Required:**
- Change default `RemoteUrl` parameter from GitLab to GitHub
- Change default `BranchName` from `3.100/ac` to `stage-ac`
- Update SSH remote URL configuration (line 175)
- Update error messages and documentation links

#### Task 1.5: Update STEP5_setup-prod-repo.ps1
**Changes Required:**
- Change default `RemoteUrl` parameter from GitLab to GitHub
- Change default `BranchName` from `3.100/pd` to `stage-pd`
- Update SSH remote URL configuration (line 174)
- Update error messages and documentation links

#### Task 1.6: Update DailyUpdate.ps1
**Changes Required:**
- **MAJOR CHANGE:** Remove automatic version detection logic (lines 63-92)
- GitHub uses fixed branch names, not version-based branches
- Update `$RepositoryConfig` to use new branch names
- Simplify branch logic - no need for version prefix
- Update configuration section with new branch names

**Old Configuration:**
```powershell
$RepositoryConfig = @(
    @{ FolderPath = "INT"; BranchSuffix = "in"; ... },
    @{ FolderPath = "TEST"; BranchSuffix = "ac"; ... },
    @{ FolderPath = "PROD"; BranchSuffix = "pd"; ... }
)
# Branch constructed as: "$VersionNumber/$BranchSuffix" (e.g., "3.100/in")
```

**New Configuration:**
```powershell
$RepositoryConfig = @(
    @{ FolderPath = "INT"; BranchName = "stage-in"; ... },
    @{ FolderPath = "TEST"; BranchName = "stage-ac"; ... },
    @{ FolderPath = "PROD"; BranchName = "stage-pd"; ... }
)
# Branch used directly: "stage-in", "stage-ac", "stage-pd"
```

---

### **Phase 2: Update Documentation** (Priority: HIGH)

#### Task 2.1: Update README.md
**Changes Required:**
- Replace all GitLab references with GitHub
- Update clone command to use GitHub repository URL
- Update authentication instructions for GitHub
- Update troubleshooting sections
- Update repository structure documentation
- Update branch naming conventions
- Remove GitLab-specific troubleshooting (TortoiseGit with GitLab)

#### Task 2.2: Update docs/*.md Files
**Changes Required:**
- Update `docs/STEP1_sshKeygen.md` - GitHub SSH instructions
- Update `docs/STEP2_testGitLabConnection.md` - Rename and update for GitHub
- Update `docs/STEP3_setup-int-repo.md` - New branch name and GitHub URL
- Update `docs/STEP4_setup-test-repo.md` - New branch name and GitHub URL
- Update `docs/STEP5_setup-prod-repo.md` - New branch name and GitHub URL
- Update `docs/DailyUpdate.md` - New branch logic
- Update `docs/README.md` - General GitHub references

---

### **Phase 3: Testing and Validation** (Priority: HIGH)

#### Task 3.1: Test SSH Key Generation
- Verify new GitHub SSH instructions work
- Test GitHub authentication
- Validate error handling

#### Task 3.2: Test Repository Cloning
- Test INT setup with new branch name
- Test TEST setup with new branch name
- Test PROD setup with new branch name
- Verify all three environments can be cloned

#### Task 3.3: Test Daily Update Script
- Verify simplified branch logic works
- Test force pull functionality
- Verify progress bars work correctly
- Test with all three environments

---

### **Phase 4: Migration Execution** (Priority: MEDIUM)

#### Task 4.1: Backup Current Setup
- Document current working directory structure
- Save copies of existing scripts
- Note any custom configurations

#### Task 4.2: Update All Files
- Execute all script updates from Phase 1
- Execute all documentation updates from Phase 2

#### Task 4.3: Clean Up Old Repositories (Optional)
- Remove old GitLab-cloned folders (INT, TEST, PROD)
- Re-clone from GitHub using updated scripts
- Verify new clones work correctly

---

### **Phase 5: Additional Considerations** (Priority: LOW)

#### Task 5.1: GitHub-Specific Features
**Consider adding:**
- GitHub Actions workflow files (`.github/workflows/`)
- GitHub Issue templates (`.github/ISSUE_TEMPLATE/`)
- Pull Request templates (`.github/PULL_REQUEST_TEMPLATE.md`)
- GitHub-specific `.gitignore` entries
- Branch protection rules documentation

#### Task 5.2: Access Management
**Verify:**
- Team members have GitHub access to the repository
- SSH keys or PATs are configured for all developers
- Branch permissions are properly configured on GitHub

#### Task 5.3: CI/CD Pipeline Updates
**Check if needed:**
- Update deployment scripts to use GitHub branches
- Update CI/CD configurations (if any)
- Update webhook configurations
- Update automated build systems

---

## 🚨 Critical Changes Summary

### 1. **Authentication**
- **Before:** GitLab SSH keys for `gitlab.office.transporeon.com`
- **After:** GitHub SSH keys for `github.com`
- **Action:** Users must generate new SSH keys for GitHub or use existing ones

### 2. **Branch Strategy**
- **Before:** Dynamic version-based branches (e.g., `3.100/in`, auto-detected)
- **After:** Static stage-based branches (e.g., `stage-in`)
- **Action:** DailyUpdate.ps1 must be simplified - no version detection needed

### 3. **Repository URL**
- **Before:** `gitlab.office.transporeon.com/Development/portfolio.git`
- **After:** `github.com/trimble-transport/ttc-ctp-custint-exchange-platform-monolith.git`
- **Action:** Update all default parameters in setup scripts

---

## 📝 Step-by-Step Migration Instructions

### For End Users:

1. **Update Scripts:** Ensure all PowerShell scripts are updated to latest versions
2. **Generate GitHub SSH Key:** Run updated `STEP1_sshKeygen.ps1`
3. **Add Key to GitHub:** Go to https://github.com/settings/keys and add your SSH public key
4. **Test Connection:** Run updated `STEP2_testGitHubConnection.ps1`
5. **Clone Repositories:** Run STEP3, STEP4, and STEP5 scripts in order
6. **Daily Updates:** Use updated `DailyUpdate.ps1` with new branch names

### For Administrators:

1. **Verify GitHub Repository Access:** Ensure all team members have appropriate access levels
2. **Configure Branch Protection:** Set up branch protection rules for `stage-pd` (production)
3. **Update CI/CD:** Update any automated deployment pipelines
4. **Notify Team:** Inform all developers about the migration and new procedures
5. **Migration Support:** Provide support for developers during transition

---

## 🔧 Technical Details

### SSH URL Changes
```bash
# Old GitLab SSH URL
git@gitlab.office.transporeon.com:Development/portfolio.git

# New GitHub SSH URL
git@github.com:trimble-transport/ttc-ctp-custint-exchange-platform-monolith.git
```

### Branch Mapping Details
```bash
# Old INT Branch
origin/3.100/in → Local: 3.100/in

# New INT Branch
origin/stage-in → Local: stage-in

# Old TEST Branch
origin/3.100/ac → Local: 3.100/ac

# New TEST Branch
origin/stage-ac → Local: stage-ac

# Old PROD Branch
origin/3.100/pd → Local: 3.100/pd

# New PROD Branch
origin/stage-pd → Local: stage-pd
```

### DailyUpdate.ps1 Logic Changes
**Old Logic:**
1. Fetch all remote branches
2. Parse branches to find versions (e.g., "3.100", "3.99", etc.)
3. Sort versions and select the latest
4. Construct branch name: `{version}/{suffix}` (e.g., "3.100/in")

**New Logic:**
1. Use static branch names directly
2. No version detection needed
3. Use branch name as-is: `stage-in`, `stage-ac`, `stage-pd`

---

## ⚠️ Potential Issues and Solutions

### Issue 1: Existing Cloned Repositories
**Problem:** Users may have existing INT/TEST/PROD folders from GitLab
**Solution:** 
- Scripts already handle existing directories
- Users will be prompted to remove and re-clone
- Or manually update remote URL: `git remote set-url origin <new-github-url>`

### Issue 2: SSH Key Compatibility
**Problem:** GitLab SSH keys may not be registered on GitHub
**Solution:**
- Same SSH keys can be used for both platforms
- Users should add their existing `~/.ssh/id_rsa.pub` to GitHub
- Or generate new keys specifically for GitHub

### Issue 3: Branch Not Found Errors
**Problem:** Scripts trying to check out old version-based branches
**Solution:**
- All scripts must be updated before use
- Clear error messages should guide users
- Validation checks should verify branch existence

### Issue 4: DailyUpdate.ps1 Version Detection Failure
**Problem:** GitHub doesn't use version-based branches
**Solution:**
- Remove entire version detection function
- Use static branch names from configuration
- Simplify update logic significantly

---

## ✅ Success Criteria

Migration is complete when:

- [ ] All PowerShell scripts updated with GitHub URLs and branch names
- [ ] All documentation updated with GitHub references
- [ ] SSH authentication works with GitHub
- [ ] All three environments (INT, TEST, PROD) can be cloned successfully
- [ ] DailyUpdate.ps1 works with new branch structure
- [ ] All team members have GitHub access
- [ ] All team members have been trained on new procedures
- [ ] CI/CD pipelines (if any) are updated and functional
- [ ] No references to GitLab remain in active documentation

---

## 📞 Support and Resources

### GitHub Documentation
- **SSH Setup:** https://docs.github.com/en/authentication/connecting-to-github-with-ssh
- **Repository Cloning:** https://docs.github.com/en/repositories/creating-and-managing-repositories/cloning-a-repository
- **Branch Management:** https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/proposing-changes-to-your-work-with-pull-requests/about-branches

### New Repository Location
- **Main Repository:** https://github.com/trimble-transport/ttc-ctp-custint-exchange-platform-monolith/
- **Settings Page:** https://github.com/trimble-transport/ttc-ctp-custint-exchange-platform-monolith/settings
- **SSH Key Setup:** https://github.com/settings/keys

---

## 📅 Recommended Timeline

| Phase | Duration | Priority |
|-------|----------|----------|
| Phase 1: Update Core Scripts | 2-4 hours | HIGH |
| Phase 2: Update Documentation | 2-3 hours | HIGH |
| Phase 3: Testing and Validation | 2-3 hours | HIGH |
| Phase 4: Migration Execution | 1-2 hours | MEDIUM |
| Phase 5: Additional Considerations | 4-8 hours | LOW |

**Total Estimated Time:** 11-20 hours for complete migration

---

## 📋 Checklist for Implementation

### Pre-Migration
- [ ] Backup all existing scripts and documentation
- [ ] Verify GitHub repository access for all team members
- [ ] Document current setup and configurations
- [ ] Test GitHub SSH access manually

### During Migration
- [ ] Update all 6 PowerShell scripts
- [ ] Update all 8 documentation files
- [ ] Test each script individually
- [ ] Test complete workflow (STEP1 through STEP5)
- [ ] Test DailyUpdate.ps1 with all three repositories

### Post-Migration
- [ ] Remove old GitLab references from all files
- [ ] Update team knowledge base
- [ ] Conduct training session for team members
- [ ] Monitor for issues during first week
- [ ] Collect feedback and make improvements

---

**Document Version:** 1.0  
**Last Updated:** November 4, 2025  
**Status:** Ready for Implementation

