param principalId string
param cognitiveServicesName string
param roleDefinitionId string = 'a97b65f3-24c7-4388-baec-2e87135dc908' // Cognitive Services User built-in role

resource cognitiveServices 'Microsoft.CognitiveServices/accounts@2024-10-01' existing = {
  name: cognitiveServicesName
}

resource cognitiveServicesRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(cognitiveServices.id, principalId, roleDefinitionId)
  scope: cognitiveServices
  properties: {
    principalId: principalId
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', roleDefinitionId)
    principalType: 'ServicePrincipal'
  }
}
