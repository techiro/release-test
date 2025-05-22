# GitHub App Private Key Format Guide

When using GitHub Apps for authentication in workflows, it's important to properly format the private key to avoid decoding errors like `error:1E08010C:DECODER routines::unsupported`.

## Proper Format for GitHub App Private Key

The private key must be stored in the proper PEM format, with all line breaks preserved. GitHub Actions secrets will automatically handle line breaks correctly, but you must ensure the key is pasted exactly as it was downloaded, including:

1. The beginning line: `-----BEGIN RSA PRIVATE KEY-----`
2. All key content in the middle
3. The ending line: `-----END RSA PRIVATE KEY-----`

## Adding the Private Key to Repository Secrets

1. Navigate to your repository settings: **Settings** > **Secrets and variables** > **Actions**
2. Click on **New repository secret**
3. Name: `RELEASE_INTEGRATION_APP_PRIVATE_KEY` 
4. Value: Copy and paste the entire content of your .pem file, including the BEGIN and END lines

**Important:** Do not modify, remove line breaks, or reformat the private key content in any way.

## Common Errors and Solutions

### Error: `DECODER routines::unsupported`

This error typically occurs when:

1. **Line breaks are removed** from the private key
2. **Format is changed** (e.g., base64 encoded or special characters escaped)
3. **BEGIN/END lines are missing** or altered

### Solution

1. Re-download the private key from GitHub App settings
2. Open the .pem file in a text editor that does not automatically modify line endings
3. Copy the entire content exactly as is
4. Paste into the GitHub secret value field without any modifications

## Example Format

The private key should look like this (with actual content in place of the ellipsis):

```
-----BEGIN RSA PRIVATE KEY-----
MIIEogIBAAKCAQEAvHEWb9...
...many lines of characters...
...h8NPgJwIDAQAB
-----END RSA PRIVATE KEY-----
```

Remember that GitHub handles multiline secrets correctly, so you do not need to add any additional formatting or escape characters.