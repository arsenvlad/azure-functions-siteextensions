param location string = resourceGroup().location
param name string

resource serverFarm 'Microsoft.Web/serverfarms@2022-03-01' = {
  name: name
  location: location
  sku: {
    name: 'S1'
  }
  kind: 'asp'
}

resource function 'Microsoft.Web/sites@2022-03-01' = {
  name: name
  location: location
  kind: 'functionapp'
  properties: {
    serverFarmId: serverFarm.id
    siteConfig: {
      alwaysOn: true
      appSettings: [
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: 'dotnet'
        }     
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~4'
        }
      ]
    }
  }
}

resource siteextension 'Microsoft.Web/sites/siteextensions@2022-03-01' = {
  parent: function
  name: 'Dynatrace'
} 
