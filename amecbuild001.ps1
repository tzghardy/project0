<#
>add-azurermaccount
>login-azureaccount
>get-azuresubscription
#>

<# Create Test001 Resource Group in East US Location, this can be fed by parameters on ps1 execution! #>

$coreRG = "rgVDC1core"
$networkRG = "rgVDC1network"
$location = "East US"
$deployURL = "https://raw.githubusercontent.com/tzghardy/project0/master/"


New-AzureRmResourceGroup -Name $coreRG -Location $location

<#create Storage Account in resource group "Test001"...output is storageNameOutput = storageaccountname... #>
New-AzureRmResourceGroupDeployment -ResourceGroupName $coreRG -TemplateFile $deployURL"storageaccount/azuredeploy.json" -TemplateParameterFile $deployURL"storageaccount/azuredeploy.parameters.core.json"

<#create Test001Network Resrouce Group in East US Location#>
New-AzureRmResourceGroup -Name $networkRG -Location $location

<#create StorageAccount in resource group "Test001Network"...output is storageNameOutput = storageaccountname... #>
New-AzureRmResourceGroupDeployment -ResourceGroupName $networkRG -TemplateFile "./storageaccount/azuredeploy.json" -TemplateParameterFile "./storageaccount/azuredeploy.parameters.network.json"

<#create NSG for VDC1#>
New-AzureRmResourceGroupDeployment -ResourceGroupName $networkRG -TemplateFile "./NetSecGroup/azuredeploy.json" -TemplateParameterFile "./NetSecGroup/azuredeploy.parameters.json"

<#create UDR for VDC1#>
<#not_working (no Virt Appliance) New-AzureRmResourceGroupDeployment -ResourceGroupName "rgVDC1network" -TemplateFile "./UserDefRoute/azuredeploy.json" -TemplateParameterFile "./UserDefRoute/azuredeploy.parameters.json"
#>

<#create virtualNetworks for VDC1#>
New-AzureRmResourceGroupDeployment -ResourceGroupName $networkRG -TemplateFile "./vnet/azuredeploy.json" -TemplateParameterFile "./vnet/azuredeploy.parameters.json"

<#create AD PDC#>
New-AzureRmResourceGroupDeployment -ResourceGroupName $coreRG -TemplateFile "./AD_NewDomain/azuredeploy_pdc.json" -TemplateParameterFile "./AD_NewDomain/azuredeploy_pdc.parameters.json"

<#fix vnet DNS configuration with 1st server#>
New-AzureRmResourceGroupDeployment -ResourceGroupName $networkRG -TemplateFile "./vnet/azuredeploywdns.json" -TemplateParameterFile "./vnet/azuredeploywdns1.parameters.json"

<#create AD BDC#>
New-AzureRmResourceGroupDeployment -ResourceGroupName $coreRG -TemplateFile "./AD_NewDomain/azuredeploy_bdc.json" -TemplateParameterFile "./AD_NewDomain/azuredeploy_bdc.parameters.json"

<#fix vnet DNS configuration with 2nd server#>
New-AzureRmResourceGroupDeployment -ResourceGroupName $networkRG -TemplateFile "./vnet/azuredeploywdns.json" -TemplateParameterFile "./vnet/azuredeploywdns2.parameters.json"
