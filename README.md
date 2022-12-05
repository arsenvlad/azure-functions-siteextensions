# Azure Functions Site Extensions

This is a simple example of installing Azure Functions site extension using ARM/Bicep template and Kudo APIs directly.

## Create function app

```bash
./deploy-functionapps.sh
```

## Kudo APIs

> NOTE: Kudo PUT call to /api/siteextensions/{siteExtensionsName} will take at least 35 seconds. We cannot make other calls to the Kudo endpoint while the site extension is being installed since these calls with result in "Conflict" error.

```bash
# Set name of resource group, function app, and the site extension name to install.
resourceGroup=avdtrepro400-westeurope
functionAppName=avdtrepro400-westeurope-1
siteExtensionName=Dynatrace

# Get URL and credentials for calling Kudo API.
publishUrl=$(az functionapp deployment list-publishing-profiles --resource-group $resourceGroup --name $functionAppName --query "[?publishMethod == 'ZipDeploy'].publishUrl" -o tsv)
userName=$(az functionapp deployment list-publishing-profiles --resource-group $resourceGroup --name $functionAppName --query "[?publishMethod == 'ZipDeploy'].userName" -o tsv)
userPWD=$(az functionapp deployment list-publishing-profiles --resource-group $resourceGroup --name $functionAppName --query "[?publishMethod == 'ZipDeploy'].userPWD" -o tsv)

# Generate Basic authentication header using the credentials of the function app instance.
basicAuth=`echo -n "$userName:$userPWD" | base64 -w 0`

# Create Kudo API endpoint for site extensions.
siteExtensionUrl=https://$publishUrl/api/siteextensions/$siteExtensionName
echo "Publishing $siteExtensionUrl"

# If the extension was already installed, for example, via the Bicep template, delete it.
az rest --url $siteExtensionUrl --method DELETE --headers "Authorization=Basic $basicAuth" -o json

# Install the extension. This call will take at least 35 seconds. We cannot make other calls to the Kudo endpoint while site extension is being installed.
time az rest --url $siteExtensionUrl --method PUT --headers "Authorization=Basic $basicAuth" -o json 

# Get the installed extension.
az rest --url $siteExtensionUrl --method GET --headers "Authorization=Basic $basicAuth" -o json
```

## Example of Conflict error

![Conflict error when making concurrent calls to the Kudo PUT /api/siteextensions/$siteExtensionName endpoint](./images/conflict-409-error.png)