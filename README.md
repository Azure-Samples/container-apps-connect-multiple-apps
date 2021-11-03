# Azure Container Apps Sample - multi-container communication

The following sample shows how to use Azure Container Apps to have one container call another within the environment.  This is possible both with or without [Dapr](https://dapr.io).  Dapr will provide mTLS, auto-retries, and additional telemetry if enabled.  

The `nodeApp` (container-1-node) is an express.js API that will call a `/hello` endpoint.  This route will call the `dotnetApp` (container-2-dotnet) to return a message.  
  
To view the version of this solution that does not utilize Dapr, see the [`with-fqdn`](./with-fqdn) folder.  To view the version of this solution that does utilize Dapr, see the [`with-dapr`](./with-dapr) folder.
## Deploy and Run

### Deploy via GitHub Actions (recommended)
The GitHub Actions will deploy an environment that includes both the with-fqdn and with-dapr versions of the solution.

1. Fork the sample repo
2. Create the following required [encrypted secrets](https://docs.github.com/en/actions/security-guides/encrypted-secrets#creating-encrypted-secrets-for-an-environment) for the sample

  | Name | Value |
  | ---- | ----- |
  | AZURE_CREDENTIALS | The JSON credentials for an Azure subscription. [Learn more](https://docs.microsoft.com/azure/developer/github/connect-from-azure?tabs=azure-portal%2Cwindows#create-a-service-principal-and-add-it-as-a-github-secret) |
  | RESOURCE_GROUP | The name of the resource group to create |
  | PACKAGES_TOKEN | A GitHub personal access token with the `packages:read` scope. [Learn more](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token) |

### Deploy via Azure CLI
See the README.md files within each folder for scripts to deploy the sample using the Azure CLI.