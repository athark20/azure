param location string 
param storageaccount array
// Logic to generate storageName based on setEnv and other values
param productname string
param subproductname string
param setEnv string
var region = location == 'westus' ? 'zweus' : location == 'eastus' ? 'zeaus' : 'unknown'
var baseName = 'cor${setEnv}${region}${productname}${subproductname}'
output basnameprint string = baseName
module storage './modules/storageAccount.bicep' = [
  for (storage, i) in storageaccount: {
    name: 'storageDeployment${i}'
    params: {
      location: location
      storageName: '${baseName}${storage.sasuffixes}'
      storageContainers: [for container in storage.storageContainers: {value: container}]
      storageFileshares: storage.storageFileshares
      // storageContainerRoleAssignments: storageContainerRoleAssignments
      storageAccountSKU: storage.sku
      minimumTlsVersion: storage.minimumTlsVersion
      allowBlobPublicAccess: storage.allowBlobPublicAccess
      allowCrossTenantReplication: storage.allowCrossTenantReplication
    }    
  }
]