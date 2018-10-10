# PushDockerImage.ps1
# Use this script to manually Push the Docker image to the ACR.
# Change variables before running deployment

#region Variables
$ResourceGroupName = 'WebAppContainer-rg' 
$acrName = 'UDContainerRegistry'
$dockerimagename = 'udhelloworld'
$dockerimageversion = 'latest'
$dockerfile = '.\\Dockerfile\dockerfile'
#endregion

#region Connect to Azure
Add-AzureRmAccount
 
#Select Azure Subscription
$subscription = 
(Get-AzureRmSubscription |
        Out-GridView `
        -Title 'Select an Azure Subscription ...' `
        -PassThru)
 
Set-AzureRmContext -SubscriptionId $subscription.Id -TenantId $subscription.TenantID
#endregion

#region Build the image from the Docker file
# docker images are case-sensitive. Make sure acrname is lowercase.
$command = ('Get-Content -Path $dockerfile | docker build - -t {0}.azurecr.io/{1}:{2}' -f $($acrName.ToLower()), $dockerimagename, $dockerimageversion)
Invoke-Expression $command
#endregion

#region Push the Docker image to Azure Container Registry
#Log in to Azure Container Registry
$ContainerAdminUser = Get-AzureRmContainerRegistryCredential -ResourceGroupName $ResourceGroupName -Name $acrName

#Retrieve Login Server name of Azure Container Registry
Get-AzureRmContainerRegistry -ResourceGroupName $ResourceGroupName -Name $acrName | Select-Object Name, LoginServer, ResourceGroupName

#login in Docker Container Registry
$command = ('docker login {0}.azurecr.io --username {1} --password {2}' -f $($acrName.ToLower()), $ContainerAdminUser.Username, $ContainerAdminUser.Password)
Invoke-Expression $command

#Push Docker image to ACR
$command = ('docker push {0}.azurecr.io/{1}:{2}' -f $($acrName.ToLower()), $dockerimagename, $dockerimageversion)
Invoke-Expression $command
#endregion