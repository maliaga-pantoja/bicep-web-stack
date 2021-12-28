@description('service plan name like "F1" ')
param sku string = 'F1'

@description('service plan capacity, example "1" ')
param servicePlanCapacity int = 1

@description('webapp name to be used as part of serviceplan, webapp and source control')
param webappName string = 'pacifico-webstack'

// git repo config
param branch string = 'master'
param repositoryUrl string = 'https://github.com/maliaga-pantoja/bicep-webapp.git'

resource appServicePlan 'Microsoft.Web/serverfarms@2020-12-01' = {
  name: 'asp-${webappName}'
  location: resourceGroup().location
  kind: 'linux'
  sku: {
    name: sku
    capacity: servicePlanCapacity
  }
}

resource webApplication 'Microsoft.Web/sites@2020-12-01' = {
  name: 'wa-${webappName}'
  location: resourceGroup().location
  tags: {
    'hidden-related:${resourceGroup().id}/providers/Microsoft.Web/serverfarms/appServicePlan': 'Resource'
    'displayName': 'website'
  }
  properties: {
    serverFarmId: appServicePlan.id
  }
}
resource srcControl 'Microsoft.Web/sites/sourcecontrols@2021-01-01' = {
  name: 'web'
  parent: webApplication
  properties: {
    repoUrl: repositoryUrl
    branch: branch
    isManualIntegration: true
    deploymentRollbackEnabled: true
    isGitHubAction: false
  }
}
