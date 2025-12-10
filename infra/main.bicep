param location string = 'westus3'
param appName string
@allowed([
  'B1'
  'P1v3'
])
param appServicePlanSkuName string = 'B1'
param appServicePlanSkuTier string = appServicePlanSkuName == 'P1v3' ? 'PremiumV3' : 'Basic'
param workspaceSku string = 'PerGB2018'

// Derive ACR name: alphanumeric only, lowercase
var acrName = toLower(replace(appName, '-', ''))
var acrNameSafe = '${acrName}acr'

module acr 'modules/acr.bicep' = {
  name: 'acr'
  params: {
    name: acrNameSafe
    location: location
    sku: 'Basic'
    adminUserEnabled: false
  }
}

module logAnalytics 'modules/logAnalytics.bicep' = {
  name: 'logAnalytics'
  params: {
    name: '${appName}-law'
    location: location
    sku: workspaceSku
    retentionInDays: 30
  }
}

module appService 'modules/appService.bicep' = {
  name: 'appService'
  params: {
    appName: appName
    location: location
    planSkuName: appServicePlanSkuName
    planSkuTier: appServicePlanSkuTier
    imageName: '${acr.outputs.loginServer}/${appName}:latest'
    applicationInsightsWorkspaceId: logAnalytics.outputs.workspaceId
  }
}

// Role assignment: Web App managed identity gets AcrPull on ACR
module acrPullRole 'modules/roleAssignment.bicep' = {
  name: 'acrPullRole'
  params: {
    principalId: appService.outputs.webAppPrincipalId
    acrName: acrNameSafe
  }
}

// Microsoft Foundry (Azure OpenAI) for GPT-4 and Phi
// Note: OpenAI deployed to eastus for model availability; app remains in westus3
module foundry 'modules/foundry.bicep' = {
  name: 'foundry'
  params: {
    name: '${appName}-openai'
    location: 'eastus'
    sku: 'S0'
    kind: 'OpenAI'
  }
}

output webAppName string = appService.outputs.webAppName
output webAppUrl string = appService.outputs.webAppUrl
output appInsightsName string = appService.outputs.appInsightsName
output logAnalyticsName string = logAnalytics.outputs.workspaceName
output acrLoginServer string = acr.outputs.loginServer
output foundryEndpoint string = foundry.outputs.cognitiveServicesEndpoint
