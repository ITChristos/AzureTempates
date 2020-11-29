#designate the region
$location = '<Azure region>'

#New Deployment in a subscription
New-AzSubscriptionDeployment `
 -Location $location `
 -Name az30310subaDeployment `
 -TemplateFile $HOME/azuredeploy30310suba.json `
 -rgLocation $location `
 -rgName 'az30310a-labRG'

 #New Resource Group deployment
 New-AzSubscriptionDeployment `
 -Location $location `
 -Name az30310subaDeployment `
 -TemplateFile $HOME/azuredeploy30310suba.json `
 -rgLocation $location `
 -rgName 'az30310a-labRG'