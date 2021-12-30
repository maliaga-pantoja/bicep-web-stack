@description('service plan name like "F1" ')
param sku string = 'F1'

@description('service plan capacity, example "1" ')
param servicePlanCapacity int = 1

@description('webapp name to be used as part of serviceplan, webapp and source control')
param webappName string = 'pacifico-webstack2'

@description('nodejs version')
param linuxFxVersion string = 'NODE|14-lts'


// env vars
param port string = '3000'
param file_shared_name string = 'shared'
param storage_key string = 'xxx'
// git repo config
param branch string = 'master'
param repositoryUrl string = 'https://github.com/maliaga-pantoja/webapp-storage-account.git'

resource appServicePlan 'Microsoft.Web/serverfarms@2020-06-01' = {
  name: 'asp-${webappName}-${resourceGroup().location}'
  location: resourceGroup().location
  kind: 'linux'
  properties: {
    reserved: true
  }
  sku: {
    name: sku
    capacity: servicePlanCapacity
  }
}

resource webApplication 'Microsoft.Web/sites@2020-06-01' = {
  name: 'wa-${webappName}-${resourceGroup().location}'
  location: resourceGroup().location
  properties: {
    httpsOnly: true
    serverFarmId: appServicePlan.id
    siteConfig: {
      linuxFxVersion: linuxFxVersion
      appSettings: [
        {
          name: 'PORT'
          value: port
        }
        {
          name: 'STORAGE_KEY'
          value: storage_key
        }
        {
          name: 'FILE_SHARED_NAME'
          value: file_shared_name
        }
      ]
    }
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
