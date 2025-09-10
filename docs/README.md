# PowerShell Scripts API Documentation

This section documents the public entry points, parameters, behaviors, and usage examples for all scripts in this repository.

- STEP1_sshKeygen.ps1 — SSH key generation utility
- STEP2_testGitLabConnection.ps1 — SSH connectivity validator
- STEP3_setup-int-repo.ps1 — INT environment repository bootstrapper
- STEP4_setup-test-repo.ps1 — TEST environment repository bootstrapper
- STEP5_setup-prod-repo.ps1 — PROD environment repository bootstrapper
- DailyUpdate.ps1 — Multi-repo updater with progress tracking

## Quick Start

- Run scripts by right-clicking a `.ps1` file and selecting "Run with PowerShell", or from the terminal: `./ScriptName.ps1`.
- If you encounter execution policy issues, run the following in an elevated PowerShell:

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

## Script Docs

- See `STEP1_sshKeygen.md`
- See `STEP2_testGitLabConnection.md`
- See `STEP3_setup-int-repo.md`
- See `STEP4_setup-test-repo.md`
- See `STEP5_setup-prod-repo.md`
- See `DailyUpdate.md`