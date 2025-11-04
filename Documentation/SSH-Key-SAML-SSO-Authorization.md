# Authorize SSH Key for SAML SSO

## Overview
When working with GitHub organizations that have SAML SSO enabled (like `trimble-transport`), you need to authorize your SSH key specifically for that organization, even if your SSH key is already added to your GitHub account.

## Steps to Authorize SSH Key

### 1. Navigate to SSH Keys Settings
Go to: https://github.com/settings/keys

### 2. Locate Your SSH Key
Find your SSH key in the list. Look for the key with fingerprint ending in `...U8LI`

Key details:
- **Type:** RSA (4096 bit)
- **Email:** maxim_larkin@trimble.com
- **Fingerprint:** SHA256:bA9f4jqPtqPZeMUBs3UzN0jPnYblkcJqlbgdwdgU8LI

### 3. Configure SSO
Next to the key, you should see a button that says **"Configure SSO"** or **"Enable SSO"**

Click that button

### 4. Authorize Organization
Find **"trimble-transport"** in the list of organizations

Click **"Authorize"** next to it

### 5. Verify Authorization
After authorization, you should see a green checkmark or "Authorized" status next to the `trimble-transport` organization

## Testing the Connection

After authorizing your SSH key, test the connection by cloning a repository:

```bash
git clone git@github.com:trimble-transport/ttc-ctp-custint-exchange-platform-monolith.git
```

## Troubleshooting

### Error: "SAML SSO enabled or enforced"
If you see this error:
```
ERROR: The 'trimble-transport' organization has enabled or enforced SAML SSO.
```

This means your SSH key hasn't been authorized yet. Follow the steps above.

### Multiple SSH Keys
If you have multiple SSH keys, make sure you're authorizing the correct one that's being used by Git. You can check which key is being used:

```bash
ssh -T git@github.com
```

## Additional Resources

- [GitHub Documentation: Authenticating with SAML SSO](https://docs.github.com/articles/authenticating-to-a-github-organization-with-saml-single-sign-on/)
- [About SSH Key Authorization](https://docs.github.com/en/authentication/authenticating-with-saml-single-sign-on/authorizing-an-ssh-key-for-use-with-saml-single-sign-on)

