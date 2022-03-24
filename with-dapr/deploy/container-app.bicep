param containerAppName string
param location string
param environmentId string
param containerImage string
param containerPort int
param isExternalIngress bool = false
param containerRegistry string
param containerRegistryUsername string

param environmentVars array = []

@secure()
param containerRegistryPassword string

resource containerApp 'Microsoft.App/containerApps@2022-01-01-preview' = {
  name: containerAppName
  location: location
  properties: {
    managedEnvironmentId: environmentId
    configuration: {
      secrets: [
        {
          name: 'registry-password'
          value: containerRegistryPassword
        }
      ]
      registries: [
        {
          server: containerRegistry
          username: containerRegistryUsername
          passwordSecretRef: 'registry-password'
        }
      ]
      ingress: {
        external: isExternalIngress
        targetPort: containerPort
      }
      dapr: {
        enabled: true
        appPort: containerPort
        appId: containerAppName
      }
    }
    template: {
      containers: [
        {
          image: containerImage
          name: containerAppName
          env: environmentVars
        }
      ]
      scale: {
        minReplicas: 0
      }
    }
  }
}

output fqdn string = containerApp.properties.configuration.ingress.fqdn
