# GitHub App Setup Guide

This guide explains how to create and configure a GitHub App that can be used for cross-repository operations between techiro/release-test and techiro/release-test-server repositories.

## Creating a GitHub App

1. Go to your GitHub account settings
2. Navigate to **Settings** > **Developer settings** > **GitHub Apps**
3. Click on **New GitHub App**
4. Fill in the required information:
   - **GitHub App name**: `Techiro Release Integration` (or a name of your choice)
   - **Homepage URL**: Use your repository URL (e.g., https://github.com/techiro/release-test)
   - **Webhook**: Uncheck this box if you don't need webhook events
   - **Repository permissions**:
     - **Contents**: Read & write (Required to access repository content, create branches, and commit changes)
     - **Pull requests**: Read & write (Required to create and manage pull requests)
     - **Metadata**: Read-only (Required for basic repository information)
   - **Where can this GitHub App be installed?**: Select "Any account" to allow installation on multiple organizations

5. Click on **Create GitHub App**

## Generating a private key for the GitHub App

1. After creating the app, navigate to your app's settings page
2. Scroll down to the **Private keys** section
3. Click on **Generate a private key**
4. Save the downloaded .pem file securely

## Installing the GitHub App

1. Navigate to the app's settings page
2. On the left sidebar, click on **Install App**
3. Choose the organization where your repositories are located
4. Select the repositories where you want to install the app (select both `techiro/release-test` and `techiro/release-test-server`)
5. Click on **Install**

## Configuring Repository Secrets and Variables

1. In your `techiro/release-test` repository, go to **Settings** > **Secrets and variables** > **Actions**
2. Add the following repository secrets:
   - **Name**: `GITHUB_APP_PRIVATE_KEY`
   - **Value**: Paste the entire contents of the private key .pem file, including the `-----BEGIN RSA PRIVATE KEY-----` and `-----END RSA PRIVATE KEY-----` lines

3. Then go to the **Variables** tab and add:
   - **Name**: `GITHUB_APP_ID`
   - **Value**: Your GitHub App ID (visible on the app's settings page)

## Testing the Integration

To test that the GitHub App is properly configured:

1. Run the `sync-from-server.yml` workflow manually
2. Verify that the workflow can access both repositories and complete successfully
3. Check that pull requests are created properly

## Troubleshooting

If you encounter issues:

1. Ensure the GitHub App has the correct permissions
2. Verify the App is installed on both repositories
3. Check that the private key and App ID are correctly configured in repository secrets/variables
4. Review the workflow run logs for any authentication or permission errors