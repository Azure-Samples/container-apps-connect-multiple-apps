# Calling with Dapr

Calling with Dapr will leverage the Dapr sidecar to securely call the other service (dotnet-app).  Dapr provides mTLS, automatic retries, and distributed tracing.

```js
const dotnetAppId = process.env.DOTNET_APP_ID;
const daprPort = process.env.DAPR_HTTP_PORT || 3500;
// ... 
var data = await axios.get(`http://localhost:${daprPort}/hello`, {
  headers: {'dapr-app-id': `${dotnetAppId}`} //sets app name for service discovery
});
res.send(`${JSON.stringify(data.data)}`);
```

## Local debug

#### Terminal 1
```bash
export DOTNET_APP_ID=dotnet-app-dapr
cd ./with-dapr/container-1-node
npm install
dapr run -a node-app-dapr -p 3000 -- npm run start
```

#### Terminal 2
```bash
cd ./with-dapr/container-2-dotnet
dotnet build
dapr run -a dotnet-app-dapr -p 5230 -- dotnet run
```

Browse to http://localhost:3000

## Deploy with CLI

```bash
# Login to the CLI
az login
az extension add \
  --source https://workerappscliextension.blob.core.windows.net/azure-cli-extension/containerapp-0.2.0-py2.py3-none-any.whl
az provider register --namespace Microsoft.Web

# Create a resource group
az group create \
  --name 'sample-rg' \
  --location canadacentral

az monitor log-analytics workspace create \
  --resource-group 'sample-rg' \
  --workspace-name 'logs-for-sample'

LOG_ANALYTICS_WORKSPACE_CLIENT_ID=`az monitor log-analytics workspace show --query customerId -g 'sample-rg' -n 'logs-for-sample' --out tsv`
LOG_ANALYTICS_WORKSPACE_CLIENT_SECRET=`az monitor log-analytics workspace get-shared-keys --query primarySharedKey -g 'sample-rg' -n 'logs-for-sample' --out tsv`

# Create a container app environment
az containerapp env create \
  --name 'sample-env'\
  --resource-group 'sample-rg' \
  --logs-workspace-id $LOG_ANALYTICS_WORKSPACE_CLIENT_ID \
  --logs-workspace-key $LOG_ANALYTICS_WORKSPACE_CLIENT_SECRET \
  --location canadacentral

# Deploy the container-2-dotnet dotnet-app
az containerapp create \
  --name dotnet-app-dapr \
  --resource-group 'sample-rg' \
  --environment 'sample-env' \
  --image 'ghcr.io/jeffhollan/container-sample-node-to-csharp/dotnet-dapr:main' \
  --target-port 80 \
  --dapr-app-id node-app \
  --enable-dapr true \
  --ingress 'internal'

# Deploy the container-1-node node-app
az containerapp create \
  --name node-app-dapr \
  --resource-group 'sample-rg' \
  --environment 'sample-env' \
  --image 'ghcr.io/jeffhollan/container-sample-node-to-csharp/node-dapr:main' \
  --target-port 3000 \
  --ingress 'external' \
  --environment-variables DOTNET_APP_ID=dotnet-app-dapr \
  --dapr-app-id node-app \
  --enable-dapr true \
  --query configuration.ingress.fqdn

```

