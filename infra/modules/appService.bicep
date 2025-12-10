param appName string
param location string
param planSkuName string
param planSkuTier string
param imageName string
param applicationInsightsWorkspaceId string

resource ai 'Microsoft.Insights/components@2020-02-02' = {
  name: '${appName}-ai'
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
    IngestionMode: 'LogAnalytics'
    Flow_Type: 'Bluefield'
    WorkspaceResourceId: applicationInsightsWorkspaceId
  }
}

resource plan 'Microsoft.Web/serverfarms@2023-12-01' = {
  name: '${appName}-plan'
  location: location
  sku: {
    name: planSkuName
    tier: planSkuTier
    size: planSkuName
    capacity: 1
  }
  properties: {
    reserved: true
    perSiteScaling: false
    targetWorkerCount: 0
  }
}

resource web 'Microsoft.Web/sites@2023-12-01' = {
  name: appName
  location: location
  tags: {
    'azd-service-name': 'web'
  }
  properties: {
    httpsOnly: true
    serverFarmId: plan.id
    siteConfig: {
      linuxFxVersion: 'DOCKER|${imageName}'
      alwaysOn: true
      ftpsState: 'Disabled'
      acrUseManagedIdentityCreds: true
      appSettings: [
        {
          name: 'WEBSITES_PORT'
          value: '8080'
        }
        {
          name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
          value: ai.properties.ConnectionString
        }
        {
          name: 'ApplicationInsightsAgent_EXTENSION_VERSION'
          value: '~3'
        }
      ]
    }
  }
  identity: {
    type: 'SystemAssigned'
  }
}

output webAppName string = web.name
output webAppUrl string = 'https://${web.name}.azurewebsites.net'
output appInsightsName string = ai.name
output webAppPrincipalId string = web.identity.principalId
