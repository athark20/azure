// This Bicep file creates a storage account.

@description('The Azure region where the storage account will be deployed.')
param location string = resourceGroup().location
param storageName string
param storageContainers array
param storageFileshares array
// param storageContainerRoleAssignments array


//@minLength(3)
//@maxLength(24)
@description('Provide a name for the storage account. The only allowed characters are letters and numbers without any dashes.')
// This function ensures that the name is stored in lowercase.
var storageAccountName  = toLower(storageName) 

@description('Storage Account SKU')
param storageAccountSKU string

@description('Minimum TLS version for the storage account.')
param minimumTlsVersion string

param allowBlobPublicAccess bool

param allowCrossTenantReplication bool

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-05-01' = {
  name: storageAccountName
  location: location
  kind: 'StorageV2'
  sku: {                          // SKU specifies the performance tier for the storage account
    name: storageAccountSKU        
  }
  properties: {
    allowBlobPublicAccess: allowBlobPublicAccess
    allowCrossTenantReplication: allowCrossTenantReplication
    
    minimumTlsVersion: minimumTlsVersion
    
  }
}
// The name of the provisioned storage account
//output storageName string = storageAccount.name

// Check blob service
resource blobService 'Microsoft.Storage/storageAccounts/blobServices@2023-05-01' existing = {
  parent: storageAccount
  name: 'default'
}

// Create container
resource containers 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-05-01' = [
  for (storageContainer, index) in storageContainers: {
    name: storageContainer.name
    parent: blobService
    }  
]

// Check SMB Fileshare service
resource fileService 'Microsoft.Storage/storageAccounts/fileServices@2023-05-01' existing = {
  parent: storageAccount
  name: 'default'
}

// Create SMB Fileshare
resource fileShare 'Microsoft.Storage/storageAccounts/fileServices/shares@2023-05-01' = [
  for (storagefileShare, index) in storageFileshares: {
    name: storagefileShare.name
    parent: fileService
    properties: {
    accessTier: storagefileShare.accessTier
    shareQuota: storagefileShare.shareQuota
    enabledProtocols: storagefileShare.enabledProtocols
    }
  }  
]

// The name of the provisioned storage account
output storageName string = storageAccount.name