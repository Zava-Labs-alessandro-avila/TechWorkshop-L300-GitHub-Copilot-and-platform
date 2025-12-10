# GitHub Actions Workflow Setup

## Required Secret

### `AZURE_CREDENTIALS`

Create a service principal with Contributor access to your resource group:

```bash
az ad sp create-for-rbac \
  --name "github-actions-zava" \
  --role Contributor \
  --scopes /subscriptions/<SUBSCRIPTION_ID>/resourceGroups/rg-zava-labs-alessandro-avila \
  --json-auth
```

Copy the JSON output and add it as a repository secret:

1. Go to **Settings** → **Secrets and variables** → **Actions**
2. Click **New repository secret**
3. Name: `AZURE_CREDENTIALS`
4. Value: Paste the JSON output

## Workflow Variables

The following values are hardcoded in the workflow but can be changed if needed:

| Variable | Value | Description |
|----------|-------|-------------|
| `ACR_NAME` | `zavastorefrontacr` | Azure Container Registry name |
| `IMAGE_NAME` | `zava-storefront` | Container image name |
| `RESOURCE_GROUP` | `rg-zava-labs-alessandro-avila` | Azure resource group |
| `APP_NAME` | `zava-storefront` | App Service name |

## Usage

The workflow runs automatically on push to `main` or `dev` branches, or can be triggered manually via **Actions** → **Build and Deploy** → **Run workflow**.
