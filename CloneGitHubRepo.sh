

#create a new directory named az30314a1 and set it as your current directory
mkdir az30314a1
cd ~/az30314a1/

#clone a sample app repository to the az30314a1 directory
REPO=https://github.com/Azure-Samples/html-docs-hello-world.git
git clone $REPO
cd html-docs-hello-world

#configure a deployment user
USERNAME=az30314user$RANDOM
PASSWORD=az30314pass$RANDOM
az webapp deployment user set --user-name $USERNAME --password $PASSWORD 
echo $USERNAME
echo $PASSWORD

#create the resource group which will host the App Service web app
LOCATION='<location>'
RGNAME='az30314a-labRG'
az group create --location $LOCATION --resource-group $RGNAME

#create a new App Service plan
SPNAME=az30314asp$LOCATION$RANDOM
az appservice plan create --name $SPNAME --resource-group $RGNAME --location $LOCATION --sku S1

#create a new, Git-enabled App Service web app
WEBAPPNAME=az30314$RANDOM$RANDOM
az webapp create --name $WEBAPPNAME --resource-group $RGNAME --plan $SPNAME --deployment-local-git

#retrieve the publishing URL of the newly created App Service web app
URL=$(az webapp deployment list-publishing-credentials --name $WEBAPPNAME --resource-group $RGNAME --query scmUri --output tsv)

#set the git remote alias representing the Git-enabled Azure App Service web app
git remote add azure $URL

#push to the Azure remote with git push azure master
git push azure master

# identify the FQDN of the newly deployed App Service web app
az webapp show --name $WEBAPPNAME --resource-group $RGNAME --query defaultHostName --output tsv

#specify the required global git configuration settings
git config --global user.email "user@az30314.com"
git config --global user.name "user az30314"

#commit the change you applied locally to the master branch
git add index.html
git commit -m 'v1.0.1'

# retrieve the publishing URL of the newly created staging slot of the App Service web app
RGNAME='az30314a-labRG'
WEBAPPNAME=$(az webapp list --resource-group $RGNAME --query "[?starts_with(name,'az30314')]".name --output tsv)
SLOTNAME='staging'
URLSTAGING=$(az webapp deployment list-publishing-credentials --name $WEBAPPNAME --slot $SLOTNAME --resource-group $RGNAME --query scmUri --output tsv)

#set the git remote alias representing the staging slot of the Git-enabled Azure App Service web app:
git remote add azure-staging $URLSTAGING

#push to the Azure remote with git push azure master
git push azure-staging master