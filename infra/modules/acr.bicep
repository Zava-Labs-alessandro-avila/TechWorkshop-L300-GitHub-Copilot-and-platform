param name string
param location string
param sku string = 'Basic'
param adminUserEnabled bool = false

resource acr 'Microsoft.ContainerRegistry/registries@2023-07-01' = {
  name: name
  location: location
  sku: {
    name: sku
  }
  properties: {
    adminUserEnabled: adminUserEnabled
    networkRuleBypassOptions: 'AzureServices'
    policies: {
      quarantinePolicy: { status: 'disabled' }
      retentionPolicy: { status: 'disabled', days: 7 }
      trustPolicy: { status: 'disabled', type: 'Notary' }
    }
  }
}

output registryName string = acr.name
output loginServer string = acr.properties.loginServer
