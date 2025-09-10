# STEP2_testGitLabConnection.ps1 — GitLab SSH Connection Test

Validates your SSH key presence, known_hosts setup, and connectivity to the GitLab server.

## Synopsis

```powershell
./STEP2_testGitLabConnection.ps1
```

## Parameters

- None.

## Behavior

- Verifies presence of `~/.ssh/id_rsa` and `~/.ssh/id_rsa.pub`.
- Displays key fingerprint when available.
- Ensures the GitLab host key exists in `~/.ssh/known_hosts` (adds if missing via ssh-keyscan).
- Tests SSH connectivity with `ssh -T git@gitlab.office.transporeon.com`.
- Prints contextual guidance on common failures.

## Expected Successful Output

```
[SUCCESS] Connection Working!
SSH connection to GitLab is working perfectly!
GitLab Response: Welcome to GitLab, @username!
```

## Examples

```powershell
# Basic connectivity test
./STEP2_testGitLabConnection.ps1
```

## Troubleshooting

- Permission denied: ensure your public key is added at GitLab profile → SSH Keys.
- Connection refused/timeout: check VPN and corporate firewall; validate DNS reachability.
- Host key verification failed: run `ssh -T git@gitlab.office.transporeon.com` once and accept the host key.