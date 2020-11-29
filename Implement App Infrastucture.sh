
#generate a pseudo-random string of characters that will be used as a prefix for names of resources you will provision in this exercise:
export PREFIX=$(echo `openssl rand -base64 5 | cut -c1-7 | tr '[:upper:]' '[:lower:]' | tr -cd '[[:alnum:]]._-'`)

#designate the Azure region into which you want to provision resources
export LOCATION='<Azure region>'

#create a resource group that will host all resources
export RESOURCE_GROUP_NAME='az30314b-labRG'
az group create --name "${RESOURCE_GROUP_NAME}" --location "$LOCATION"

#create an Azure Storage account that will host container with blobs to be processed by the Azure function
export STORAGE_ACCOUNT_NAME="az30314b${PREFIX}"
export CONTAINER_NAME="workitems"
export STORAGE_ACCOUNT=$(az storage account create --name "${STORAGE_ACCOUNT_NAME}" --kind "StorageV2" --location "${LOCATION}" --resource-group "${RESOURCE_GROUP_NAME}" --sku "Standard_LRS")

#create a variable storing the value of the connection string property of the Azure Storage account
export STORAGE_CONNECTION_STRING=$(az storage account show-connection-string --name "${STORAGE_ACCOUNT_NAME}" --resource-group "${RESOURCE_GROUP_NAME}" -o tsv)

#create a container that will host blobs to be processed by the Azure function
az storage container create --name "${CONTAINER_NAME}" --account-name "${STORAGE_ACCOUNT_NAME}" --connection-string "${STORAGE_CONNECTION_STRING}"

#create an Application Insights resource that will provide monitoring of the Azure Function processing blobs and store its key in a variable
export APPLICATION_INSIGHTS_NAME="az30314bi${PREFIX}"
az resource create --name "${APPLICATION_INSIGHTS_NAME}" --location "${LOCATION}" --properties '{"Application_Type": "other", "ApplicationId": "function", "Flow_Type": "Redfield"}' --resource-group "${RESOURCE_GROUP_NAME}" --resource-type "Microsoft.Insights/components"
export APPINSIGHTS_KEY=$(az resource show --name "${APPLICATION_INSIGHTS_NAME}" --query "properties.InstrumentationKey" --resource-group "${RESOURCE_GROUP_NAME}" --resource-type "Microsoft.Insights/components" -o tsv)

#configure Application Settings of the newly created function, linking it to the Application Insights and Azure Storage account
az functionapp config appsettings set --name "${FUNCTION_NAME}" --resource-group "${RESOURCE_GROUP_NAME}" --settings "APPINSIGHTS_INSTRUMENTATIONKEY=$APPINSIGHTS_KEY" FUNCTIONS_EXTENSION_VERSION=~2
az functionapp config appsettings set --name "${FUNCTION_NAME}" --resource-group "${RESOURCE_GROUP_NAME}" --settings "STORAGE_CONNECTION_STRING=$STORAGE_CONNECTION_STRING" FUNCTIONS_EXTENSION_VERSION=~2

#Add functions in Azure Portal

#upload a test blob to the Azure Storage account you created earlier
export STORAGE_ACCESS_KEY="$(az storage account keys list --account-name "${STORAGE_ACCOUNT_NAME}" --resource-group "${RESOURCE_GROUP_NAME}" --query "[0].value" --output tsv)"
export WORKITEM='workitem1.txt'
touch "${WORKITEM}"
az storage blob upload --file "${WORKITEM}" --container-name "${CONTAINER_NAME}" --name "${WORKITEM}" --auth-mode key --account-key "${STORAGE_ACCESS_KEY}" --account-name "${STORAGE_ACCOUNT_NAME}"

#Configure an Azure Event Grid subscription-based queue messaging
#register the eventgrid resource provider in your subscription:
az provider register --namespace microsoft.eventgrid

#generate a pseudo-random string of characters that will be used as a prefix for names of resources
export PREFIX=$(echo `openssl rand -base64 5 | cut -c1-7 | tr '[:upper:]' '[:lower:]' | tr -cd '[[:alnum:]]._-'`)

#identify the Azure region hosting the target resource group and its existing resources
export RESOURCE_GROUP_NAME_EXISTING='az30314b-labRG'
export LOCATION=$(az group list --query "[?name == '${RESOURCE_GROUP_NAME_EXISTING}'].location" --output tsv)
export RESOURCE_GROUP_NAME='az30314c-labRG'
az group create --name "${RESOURCE_GROUP_NAME}" --location $LOCATION

#create an Azure Storage account that will host a container to be used by the Event Grid subscription that you will configure in this task
export STORAGE_ACCOUNT_NAME="az30314cst${PREFIX}"
export CONTAINER_NAME="workitems"
export STORAGE_ACCOUNT=$(az storage account create --name "${STORAGE_ACCOUNT_NAME}" --kind "StorageV2" --location "${LOCATION}" --resource-group "${RESOURCE_GROUP_NAME}" --sku "Standard_LRS")

#create a variable storing the value of the connection string property of the Azure Storage account
export STORAGE_CONNECTION_STRING=$(az storage account show-connection-string --name "${STORAGE_ACCOUNT_NAME}" --resource-group "${RESOURCE_GROUP_NAME}" -o tsv)

#create a container that will to be used by the Event Grid subscription
az storage container create --name "${CONTAINER_NAME}" --account-name "${STORAGE_ACCOUNT_NAME}" --connection-string "${STORAGE_CONNECTION_STRING}"

#create a variable storing the value of the Resource Id property of the Azure Storage account:
export STORAGE_ACCOUNT_ID=$(az storage account show --name "${STORAGE_ACCOUNT_NAME}" --query "id" --resource-group "${RESOURCE_GROUP_NAME}" -o tsv)

#create the Storage Account queue that will store messages generated by the Event Grid subscription that you will configure in this task
export QUEUE_NAME="az30314cq${PREFIX}"
az storage queue create --name "${QUEUE_NAME}" --account-name "${STORAGE_ACCOUNT_NAME}" --connection-string "${STORAGE_CONNECTION_STRING}"

#create the Event Grid subscription that will facilitate generation of messages in Azure Storage queue in response to blob uploads to the designated container in the Azure Storage account:
export QUEUE_SUBSCRIPTION_NAME="az30314cqsub${PREFIX}"
az eventgrid event-subscription create --name "${QUEUE_SUBSCRIPTION_NAME}" --included-event-types 'Microsoft.Storage.BlobCreated' --endpoint "${STORAGE_ACCOUNT_ID}/queueservices/default/queues/${QUEUE_NAME}" --endpoint-type "storagequeue" --source-resource-id "${STORAGE_ACCOUNT_ID}"

#upload a test blob to the Azure Storage account you created earlier in this task
export AZURE_STORAGE_ACCESS_KEY="$(az storage account keys list --account-name "${STORAGE_ACCOUNT_NAME}" --resource-group "${RESOURCE_GROUP_NAME}" --query "[0].value" --output tsv)"
export WORKITEM='workitem2.txt'
touch "${WORKITEM}"
az storage blob upload --file "${WORKITEM}" --container-name "${CONTAINER_NAME}" --name "${WORKITEM}" --auth-mode key --account-key "${AZURE_STORAGE_ACCESS_KEY}" --account-name "${STORAGE_ACCOUNT_NAME}"
