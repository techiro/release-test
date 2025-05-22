# GitHub App Integration for Cross-Repository Operations

This PR replaces the usage of `RELEASE_TEST_SERVER_TOKEN` in the `.github/workflows/sync-from-server.yml` workflow with a GitHub App-based authentication. Using a GitHub App provides better security and more fine-grained control compared to personal access tokens.

## Changes Made

1. Modified `sync-from-server.yml` to:
   - Generate a GitHub App token at runtime
   - Use the token for checking out the server repository
   - Use the token for git operations and PR creation

2. Added documentation:
   - Created a GitHub App setup guide in the repository
   - Updated README.md to reference the GitHub App approach

## How to Create and Configure a GitHub App

Follow these steps to create a GitHub App for use with techiro/release-test and techiro/release-test-server:

### 1. Create a GitHub App

1. Go to GitHub Settings → Developer settings → GitHub Apps
2. Click "New GitHub App"
3. Complete the registration:
   - Name: `Techiro Release Integration` (or your preferred name)
   - Homepage URL: Your repository URL
   - Webhook: Uncheck (not needed)
   - Repository permissions:
     - Contents: Read & write
     - Pull requests: Read & write
     - Metadata: Read-only

### 2. Generate a Private Key

1. After creating the app, go to its settings
2. In the "Private keys" section, click "Generate a private key"
3. Save the downloaded .pem file

### 3. Install the App on Both Repositories

1. In the app settings, click "Install App"
2. Select the account/organization
3. Choose both repositories: `techiro/release-test` and `techiro/release-test-server`

### 4. Configure Repository Secrets and Variables

1. In the `techiro/release-test` repository, go to Settings → Secrets and variables → Actions
2. Add a new repository secret:
   - Name: `GITHUB_APP_PRIVATE_KEY`
   - Value: The entire contents of the .pem file (including BEGIN/END lines)
3. Add a new repository variable:
   - Name: `GITHUB_APP_ID`
   - Value: Your GitHub App ID (found in the app's settings)

The workflow is now ready to use the GitHub App for authentication.

## Benefits of Using GitHub Apps

- **Fine-grained permissions**: Only request the permissions actually needed
- **No token expiration**: Private keys don't expire (but can be revoked if needed)
- **Improved security**: Tokens are generated on demand for specific operations
- **Easier management**: No need to update personal tokens when they expire