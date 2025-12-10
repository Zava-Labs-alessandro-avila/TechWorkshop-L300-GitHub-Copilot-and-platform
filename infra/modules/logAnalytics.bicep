param name string
param location string
param sku string = 'PerGB2018'
param retentionInDays int = 30

resource la 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: name
  location: location
  properties: {
    retentionInDays: retentionInDays
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
    sku: {
      name: sku
    }
  }
}

output workspaceId string = la.id
output workspaceName string = la.name
