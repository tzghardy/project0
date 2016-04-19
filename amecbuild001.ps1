<#
>add-azurermaccount
>login-azureaccount
>get-azuresubscription
#>

<# Create Test001 Resource Group in East US Location, this can be fed by parameters on ps1 execution! #>

New-AzureRmResourceGroup -Name "rgVDC1core" -Location "East US"

<#create Storage Account in resource group "Test001"...output is storageNameOutput = storageaccountname... #>
New-AzureRmResourceGroupDeployment -ResourceGroupName "rgVDC1core" -TemplateFile "./storageaccount/azuredeploy.json" -TemplateParameterFile "./storageaccount/azuredeploy.parameters.core.json"

<#create Test001Network Resrouce Group in East US Location#>
New-AzureRmResourceGroup -Name "rgVDC1network" -Location "East US"

<#create StorageAccount in resource group "Test001Network"...output is storageNameOutput = storageaccountname... #>
New-AzureRmResourceGroupDeployment -ResourceGroupName "rgVDC1network" -TemplateFile "./storageaccount/azuredeploy.json" -TemplateParameterFile "./storageaccount/azuredeploy.parameters.network.json"

<#create NSG for VDC1#>
New-AzureRmResourceGroupDeployment -ResourceGroupName "rgVDC1network" -TemplateFile "./NetSecGroup/azuredeploy.json" -TemplateParameterFile "./NetSecGroup/azuredeploy.parameters.json"

<#create UDR for VDC1#>
<#not_working (no Virt Appliance) New-AzureRmResourceGroupDeployment -ResourceGroupName "rgVDC1network" -TemplateFile "./UserDefRoute/azuredeploy.json" -TemplateParameterFile "./UserDefRoute/azuredeploy.parameters.json"
#>

<#create virtualNetworks for VDC1#>
New-AzureRmResourceGroupDeployment -ResourceGroupName "rgVDC1network" -TemplateFile "./vnet/azuredeploy.json" -TemplateParameterFile "./vnet/azuredeploy.parameters.json"

<#create AD PDC/BDC#>
New-AzureRmResourceGroupDeployment -ResourceGroupName "rgVDC1core" -TemplateFile "./AD_NewDomain/azuredeploy.json" -TemplateParameterFile "./AD_NewDomain/azuredeploy.parameters.json"
