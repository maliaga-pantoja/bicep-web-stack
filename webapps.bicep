@description('service plan name like "F1" ')
param sku string = 'F1'

@description('service plan capacity, example "1" ')
param servicePlanCapacity int = 1

@description('webapp name to be used as part of serviceplan, webapp and source control')
param deployment_name string = 'pacificowebstack'

@description('nodejs version')
param linuxFxVersion string = 'NODE|14-lts'

@description('environment name')
param environment string = 'dev'

// env vars
param container string
param storage_name string
param client_secret string
param resource_id string
param client_id string
// git repo config
param branch string = 'master'
param repositoryUrl string = 'https://github.com/maliaga-pantoja/webapp-storage-account.git'

resource appServicePlan 'Microsoft.Web/serverfarms@2020-06-01' = {
  name: 'asp-${deployment_name}-${resourceGroup().location}-${environment}'
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

resource webApplication 'Microsoft.Web/sites@2021-02-01' = {
  name: 'wa-${deployment_name}-${resourceGroup().location}-${environment}'
  location: resourceGroup().location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    httpsOnly: true
    serverFarmId: appServicePlan.id
    siteConfig: {
      linuxFxVersion: linuxFxVersion
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

resource keyVault 'Microsoft.KeyVault/vaults@2021-06-01-preview' = {
  name: 'akv-${deployment_name}-${resourceGroup().location}-${environment}'
  location: resourceGroup().location
  properties: {
    enabledForDeployment: true
    enabledForTemplateDeployment: true
    enabledForDiskEncryption: true
    tenantId: tenant().tenantId
    enableSoftDelete: false
    accessPolicies: [
      {
        tenantId: tenant().tenantId
        objectId: webApplication.identity.principalId
        permissions: {
          secrets: [
            'all'
          ]
        }
      }
      {
        tenantId: tenant().tenantId
        objectId: resource_id
        permissions: {
          secrets: [
            'all'
          ]
        }
      }
    ]
    sku: {
      name: 'standard'
      family: 'A'
    }
  }
}
// storage account key
resource keyVaultSecretStorageKey 'Microsoft.KeyVault/vaults/secrets@2019-09-01' = {
  name: '${keyVault.name}/storagename'
  properties: {
    value: storage_name
  }
}
// container instance name
resource keyVaultSecretContainerAccess 'Microsoft.KeyVault/vaults/secrets@2019-09-01' = {
  name: '${keyVault.name}/container'
  properties: {
    value: container
  }
}
// webapp env vars necesary to access to keyvault
resource webappVars 'Microsoft.Web/sites/config@2021-02-01' = {
  name: 'web'
  parent: webApplication
  properties: {
    appSettings: [
      {
        name: 'AZURE_TENANT_ID'
        value: tenant().tenantId
      }
      {
        name: 'AZURE_CLIENT_ID'
        value: client_id
      }
      {
        name: 'AZURE_CLIENT_SECRET'
        value: client_secret
      }
      {
        name: 'VAULT_NAME'
        value: keyVault.name
      }
    ]
  }
}
