#
# DeployLinuxVMUsingPowerShell.ps1
# Use this script to manually deploy the ARM Template with parameter input file.
# Change variables before running deployment

#region Variables
$Location = 'WestEurope' 
$ResourceGroupName = 'WebAppContainer-rg' 
$appServicePlanName = 'UDAppServiceLinuxPlan'
$servicePlanTier = 'Basic'
$servicePlanSku = 'B1'
$acrName = 'UDContainerRegistry'
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

#region variables
$ARMTemplateFile = '.\Templates\WebAppContainerPrereqs.json'
#endregion

#region create ARM Template Parameter object
$parametersARM = @{}
$parametersARM.Add('resourceGroupLocation', $Location)
$parametersARM.Add('resourceGroupName', $ResourceGroupName)
$parametersARM.Add('appServicePlanName', $appServicePlanName)
$parametersARM.Add('servicePlanTier', $servicePlanTier)
$parametersARM.Add('servicePlanSku', $servicePlanSku)
$parametersARM.Add('acrName', $acrName)
#endregion

#region Deploy ARM Template
   
#region Test ARM Template
Test-AzureRmDeployment `
    -TemplateFile $ARMTemplateFile `
    -TemplateParameterObject $parametersARM `
    -Location $Location `
    -OutVariable testarmtemplate
#endregion

#region Deploy ARM Template with local Parameter file
$result = (New-AzureRMDeployment `
        -TemplateFile $ARMTemplateFile `
        -Location $Location `
        -TemplateParameterObject $parametersARM -Verbose -DeploymentDebugLogLevel All)
$result
#endregion

#endregion