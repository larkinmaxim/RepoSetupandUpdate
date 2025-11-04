# STEP2_testGitHubConnection.ps1 — GitHub SSH Connection Test

Validates your SSH key presence, known_hosts setup, and connectivity to the GitHub server.

## Synopsis

```powershell
./STEP2_testGitHubConnection.ps1
```

## Parameters

- None.

## Behavior

- Verifies presence of `~/.ssh/id_rsa` and `~/.ssh/id_rsa.pub`.
- Displays key fingerprint when available.
- Ensures the GitHub host key exists in `~/.ssh/known_hosts` (adds if missing via ssh-keyscan).
- Tests SSH connectivity with `ssh -T git@github.com`.
- Prints contextual guidance on common failures.

## Expected Successful Output

```
[SUCCESS] Connection Working!
SSH connection to GitHub is working perfectly!
GitHub Response: Hi @username! You've successfully authenticated, but GitHub does not provide shell access.
```

## Examples

```powershell
# Basic connectivity test
./STEP2_testGitHubConnection.ps1
```

## Troubleshooting

- Permission denied: ensure your public key is added at GitHub Settings → SSH and GPG keys (https://github.com/settings/keys).
- Connection refused/timeout: check VPN and corporate firewall; validate DNS reachability.
- Host key verification failed: run `ssh -T git@github.com` once and accept the host key.

