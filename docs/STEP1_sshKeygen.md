# STEP1_sshKeygen.ps1 — SSH Key Generator

Generates an RSA 4096-bit SSH keypair and prints the public key for GitLab registration.

## Synopsis

```powershell
./STEP1_sshKeygen.ps1 [-Email <string>] [-Force]
```

## Parameters

- Email <string>
  - Email address to embed as a comment in the SSH public key.
  - If omitted, the script uses `$DEFAULT_EMAIL` from within the script; if still empty, you will be prompted interactively with validation.

- Force [switch]
  - Overwrite existing key files without prompting.

## Behavior

- Creates `~/.ssh/` if missing.
- Writes keys to `~/.ssh/id_rsa` and `~/.ssh/id_rsa.pub`.
- Validates email format when prompting.
- Supports non-interactive overwrite via `-Force`.
- Displays the generated public key and next steps to add it in GitLab.

## Examples

```powershell
# Generate a key and be prompted for a valid email if not configured
./STEP1_sshKeygen.ps1

# Generate a key with a predefined email
./STEP1_sshKeygen.ps1 -Email "john.doe@company.com"

# Force-regenerate the key, overwriting existing files
./STEP1_sshKeygen.ps1 -Email "john.doe@company.com" -Force
```

## Output

- Writes status messages to the console.
- On success: prints the public key content.
- Exit codes: `0` success, `1` failure, `0` cancel.

## Notes

- Keys are generated with 4096-bit RSA and no passphrase by default.
- After generation, test connectivity using `STEP2_testGitLabConnection.ps1`.