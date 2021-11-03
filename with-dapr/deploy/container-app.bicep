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

resource containerApp 'Microsoft.Web/containerApps@2021-03-01' = {
  name: containerAppName
  kind: 'containerapp'
  location: location
  properties: {
    kubeEnvironmentId: environmentId
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
      dapr: {
        enabled: true
        appPort: containerPort
        appId: containerAppName
      }
    }
  }
}

output fqdn string = containerApp.properties.configuration.ingress.fqdn
