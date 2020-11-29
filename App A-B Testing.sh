

#set the variables representing the name of the target web app and its distribution group
RGNAME='az30314a-labRG'
WEBAPPNAME=$(az webapp list --resource-group $RGNAME --query "[?starts_with(name,'az30314')]".name --output tsv)

# identify the traffic distribution between the two slots
curl -H 'Cache-Control: no-cache' https://$WEBAPPNAME.azurewebsites.net --stderr - | grep '<h1>Azure App Service - Sample Static HTML Site'

