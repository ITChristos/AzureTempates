#Install AzureRM if needed (VSC only)
Get-Module -Name Az
Install-Module Az -AllowClobber
Connect-AzureRmAccount
Get-AzureRmTenant
Enable-AzureRmContextAutosave
Get-AzureRmContext

$resourceGroupName = Read-Host -Prompt "Enter the Resource Group name(i.e. tyrresource)"
$location = Read-Host -Prompt "Enter the location (i.e. westus)"

# Create New Resource Group (Unless adding to existing resource group)
New-AzureRmResourceGroup -Name $resourceGroupName -Location $location
#    [-Tag <Hashtable>]
#    [-Force]
#    [-ApiVersion <String>]
#    [-Pre]
#    [-DefaultProfile <IAzureContextContainer>]
#    [-WhatIf]
#    [-Confirm]
#    [<CommonParameters>]

# Create the storage account.
$storageAccountName = Read-Host -Prompt "Enter the storage account name (3-24 characters, numbers/lowercase letters only)(i.e. tyrsto)"
$storageAccount = New-AzStorageAccount -ResourceGroupName $resourceGroupName -Name $storageAccountName -Location $location -SkuName "Standard_LRS"

#Deploy Virtual Network
$templateUri = "https://raw.githubusercontent.com/ITChristos/AzureTemplates/main/TYR-NETWORK/template.json"
New-AzResourceGroupDeployment -ResourceGroupName $resourceGroupName -TemplateUri $templateUri

#Deploy Resource Group Objects
$tyrresourcetemplateUri = "https://raw.githubusercontent.com/ITChristos/AzureTemplates/main/ResourceGroup-tyrresource/template.json"
New-AzResourceGroupDeployment -ResourceGroupName $resourceGroupName -TemplateUri $tyrresourcetemplateUri

#VMadd Template
# $___________templateUri = ""
# New-AzResourceGroupDeployment -ResourceGroupName $resourceGroupName -TemplateUri $___________templateUri

#Deploy Network Security Group
$NSGtemplateUri = "https://raw.githubusercontent.com/ITChristos/AzureTemplates/main/NSG/template.json"
New-AzResourceGroupDeployment -ResourceGroupName $resourceGroupName -TemplateUri $NSGtemplateUri

#Lock Resources (prevents other users in org from accidentally deleting or modifying critical resources)
$resourceGroupName = Read-Host -Prompt "Enter the Resource Group name"
$storageAccountName = Read-Host -Prompt "Enter the storage account name"

New-AzResourceLock -LockName LockStorage -LockLevel CanNotDelete -ResourceGroupName $resourceGroupName -ResourceName $storageAccountName -ResourceType Microsoft.Storage/storageAccounts

#Get all locks for a storage account
$resourceGroupName = Read-Host -Prompt "Enter the Resource Group name"
$storageAccountName = Read-Host -Prompt "Enter the storage account name"

Get-AzResourceLock -ResourceGroupName $resourceGroupName -ResourceName $storageAccountName -ResourceType Microsoft.Storage/storageAccounts

#Delete lock of a storage account
$resourceGroupName = Read-Host -Prompt "Enter the Resource Group name"
$storageAccountName = Read-Host -Prompt "Enter the storage account name"

$lockId = (Get-AzResourceLock -ResourceGroupName $resourceGroupName -ResourceName $storageAccountName -ResourceType Microsoft.Storage/storageAccounts).LockId
Remove-AzResourceLock -LockId $lockId

#Move Resources
$srcResourceGroupName = Read-Host -Prompt "Enter the source Resource Group name"
$destResourceGroupName = Read-Host -Prompt "Enter the destination Resource Group name"
$storageAccountName = Read-Host -Prompt "Enter the storage account name"

$storageAccount = Get-AzResource -ResourceGroupName $srcResourceGroupName -ResourceName $storageAccountName
Move-AzResource -DestinationResourceGroupName $destResourceGroupName -ResourceId $storageAccount.ResourceId

#Delete Resources
$resourceGroupName = Read-Host -Prompt "Enter the Resource Group name"
$storageAccountName = Read-Host -Prompt "Enter the storage account name"

Remove-AzStorageAccount -ResourceGroupName $resourceGroupName -AccountName $storageAccountName
Remove-Az