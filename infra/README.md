# ZavaStorefront Infra (dev)

This folder contains Bicep modules and orchestration to provision Azure infrastructure for the ZavaStorefront web application (dev environment) in **westus3**.

## Resources
| Resource | Module | Description |
|----------|--------|-------------|
| Azure Container Registry (ACR) | `modules/acr.bicep` | Basic SKU, stores container images |
| Log Analytics Workspace | `modules/logAnalytics.bicep` | Centralized logging |
| Application Insights | `modules/appService.bicep` | App telemetry, linked to Log Analytics |
| App Service Plan (Linux) | `modules/appService.bicep` | Hosts Web App for Containers |
| Web App for Containers | `modules/appService.bicep` | Pulls images from ACR via managed identity |
| AcrPull Role Assignment | `modules/roleAssignment.bicep` | Grants Web App identity pull access to ACR |
| Azure OpenAI (Foundry) | `modules/foundry.bicep` | GPT-4 and Phi-3 model deployments |

## Parameters
| Parameter | Default | Description |
|-----------|---------|-------------|
| `location` | `westus3` | Azure region |
| `appName` | (required) | Base name for all resources |
| `appServicePlanSkuName` | `B1` | App Service Plan SKU (`B1` or `P1v3`) |
| `workspaceSku` | `PerGB2018` | Log Analytics SKU |

## Cost Estimates (dev tier)
- ACR Basic: ~$5/month
- App Service B1: ~$13/month
- Log Analytics: Pay per GB ingested (~$2.30/GB)
- Azure OpenAI S0: Pay per 1K tokens (varies by model)

## Deployment Workflow

### Prerequisites
- Azure CLI with Bicep extension
- Azure Developer CLI (azd)
- GitHub repo secrets configured (for CI):
  - `AZURE_CREDENTIALS` (service principal JSON)
  - `AZURE_SUBSCRIPTION_ID`
  - `AZURE_RESOURCE_GROUP`
  - `ACR_NAME`

### Provision with azd
```pwsh
azd auth login
azd env new dev
azd provision --preview   # Review changes
azd up                    # Provision and deploy
```

### Build Container (Cloud - No Local Docker Required)
Use GitHub Actions workflow `.github/workflows/build-and-push.yml` which runs:
```bash
az acr build --registry <acr-name> --image zava-storefront:latest .
```

Or manually:
```pwsh
az acr build --registry zavastorefront acr --image zava-storefront:latest --file Dockerfile .
```

## Security
- Web App uses **system-assigned managed identity**
- ACR admin user is **disabled**
- Web App has **AcrPull** role on ACR (no password secrets)
- HTTPS only, FTP disabled

## Smoke Test
1. After `azd up`, visit the Web App URL in outputs
2. Check Application Insights for telemetry
3. Test Azure OpenAI endpoint with:
```pwsh
az cognitiveservices account show --name zava-storefront-openai --resource-group <rg>
```
