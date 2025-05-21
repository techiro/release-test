# Repository Sync Setup

This document explains how to set up the synchronization between the `techiro/release-test-server` and `techiro/release-test` repositories.

## Overview

The synchronization works as follows:

1. When `release-server.md` is updated in the `techiro/release-test-server` repository, a GitHub Actions workflow is triggered.
2. This workflow sends a repository_dispatch event to the `techiro/release-test` repository.
3. The `techiro/release-test` repository receives this event and runs a workflow that:
   - Executes `make sync server-release` to fetch the updated `release-server.md` file
   - Creates a new branch with the changes
   - Opens a pull request with the updated content

## Setup Instructions

### In the techiro/release-test-server Repository

1. Create a GitHub Personal Access Token with `repo` scope.
2. Add this token as a repository secret named `REPO_ACCESS_TOKEN` in the `techiro/release-test-server` repository.
3. Create a workflow file at `.github/workflows/sync-to-release-test.yml` with the content from the `sync-to-release-test.yml.reference` file.

### In the techiro/release-test Repository

1. Ensure the `receive-server-updates.yml` workflow file is in the `.github/workflows/` directory.
2. Ensure the `Makefile` with the `sync server-release` target is in the root directory.

## Testing the Workflow

To test the workflow:

1. Make a change to the `release-server.md` file in the `techiro/release-test-server` repository and push it to the `main` branch.
2. The workflow in the `techiro/release-test-server` repository will trigger and send a repository_dispatch event to the `techiro/release-test` repository.
3. The workflow in the `techiro/release-test` repository will run, fetch the updated file, and create a pull request with the changes.

## Troubleshooting

- If the workflow in the `techiro/release-test-server` repository fails, check that the `REPO_ACCESS_TOKEN` secret is correctly set.
- If the workflow in the `techiro/release-test` repository fails, check that the `Makefile` is correctly set up and that the GitHub token has sufficient permissions.