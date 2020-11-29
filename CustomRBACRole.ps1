
#connect to Azure AD tenant associated with your Azure subscription
Connect-AzureAD

#identify the Azure AD DNS domain name
$domainName = ((Get-AzureAdTenantDetail).VerifiedDomains)[0].Name

#create new Azure AD user
$passwordProfile = New-Object -TypeName Microsoft.Open.AzureAD.Model.PasswordProfile
$passwordProfile.Password = 'Pa55w.rd1234'
$passwordProfile.ForceChangePasswordNextLogin = $false
New-AzureADUser -AccountEnabled $true -DisplayName 'az30310aaduser1' -PasswordProfile $passwordProfile -MailNickName 'az30310aaduser1' -UserPrincipalName "az30310aaduser1@$domainName"

#identify the user principal name of the newly created Azure AD user
(Get-AzureADUser -Filter "MailNickName eq 'az30310aaduser1'").UserPrincipalName

#JSON Custom RBAC Role definition
# {
#     "Name": "Virtual Machine Operator (Custom)",
#     "Id": null,
#     "IsCustom": true,
#     "Description": "Allows to start/restart Azure VMs",
#     "Actions": [
#         "Microsoft.Compute/*/read",
#         "Microsoft.Compute/virtualMachines/restart/action",
#         "Microsoft.Compute/virtualMachines/start/action"
#     ],
#     "NotActions": [

#     ],
#     "AssignableScopes": [
#         "/subscriptions/SUBSCRIPTION_ID"
#     ]
# }

#Replace the <SUBSCRIPTION_ID> placehoder with the ID value of the Azure subscription
$subscription_id = (Get-AzContext).Subscription.id
(Get-Content -Path $HOME/roledefinition30310.json) -Replace 'SUBSCRIPTION_ID', "$subscription_id" | Set-Content -Path $HOME/roledefinition30310.json
#verify
Get-Content -Path $HOME/roledefinition30310.json

#create the custom role definition:
New-AzRoleDefinition -InputFile $HOME/roledefinition30310.json
#verify role creation:
Get-AzRoleDefinition -Name 'Virtual Machine Operator (Custom)'


