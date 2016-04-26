<#
>add-azurermaccount
>login-azureaccount
>get-azuresubscription

Cisco Deploy requires: http://go.microsoft.com/fwlink/?LinkId=534873
and
http://stackoverflow.com/questions/34358017/configure-programmatic-deployment-for-azure-bing-maps


#>

<# Create Test001 Resource Group in East US Location, this can be fed by parameters on ps1 execution! #>

$coreRG = "rgVDC1core"
$networkRG = "rgVDC1network"
$location = "East US"
$deployURL = "https://raw.githubusercontent.com/tzghardy/project0/master/"
$deploystorage = $deployURL+"StorageAccount/azuredeploy.json"
$parametersstoragecore = $deployURL+"StorageAccount/azuredeploy_core.parameters.json"
$parametersstoragenetwork = $deployURL+"StorageAccount/azuredeploy_network.parameters.json"
$deploynsg = $deployURL+"NetSecGroup/azuredeploy.json"
$parametersnsg = $deployURL+"NetSecGroup/azuredeploy.parameters.json"
$deployvnet = $deployURL+"VNET/azuredeploy.json"
$parametersvnet = $deployURL+"VNET/azuredeploy.parameters.json"
$deployvnetwdns = $deployURL+"VNET/azuredeploy_wdns.json"
$parametersvnetdns1 = $deployURL+"VNET/azuredeploy_wdns1.parameters.json"
$parametersvnetdns2 = $deployURL+"VNET/azuredeploy_wdns2.parameters.json"
$deployavset = $deployURL+"AvailabilitySet/azuredeploy.json"
$parametersavset = @{"AvailabilitySetName"="adAvailabilitySet"}
$deploydc = $deployURL+"AD_NewDomain/azuredeploy_dc.json"
$parameterspdc = $deployURL+"AD_NewDomain/azuredeploy_pdc.parameters.json"
$parametersbdc = $deployURL+"AD_NewDomain/azuredeploy_bdc.parameters.json"


New-AzureRmResourceGroup -Name $coreRG -Location $location

<#create Storage Account in resource group "Test001"...output is storageNameOutput = storageaccountname... #>
New-AzureRmResourceGroupDeployment -Name "Core_Storage_Account" -ResourceGroupName $coreRG -TemplateURI $deploystorage -TemplateParameterURI $parametersstoragecore

<#create Test001Network Resrouce Group in East US Location#>
New-AzureRmResourceGroup -Name $networkRG -Location $location

<#create StorageAccount in resource group "Test001Network"...output is storageNameOutput = storageaccountname... #>
New-AzureRmResourceGroupDeployment -Name "Network_Storage_Account"-ResourceGroupName $networkRG -TemplateURI $deploystorage -TemplateParameterURI $parametersstoragenetwork

<#create NSG for VDC1#>
New-AzureRmResourceGroupDeployment -Name "NetSecGroup_Deploy"-ResourceGroupName $networkRG -TemplateURI $deploynsg -TemplateParameterURI $parametersnsg

<#create UDR for VDC1#>
<#not_working (no Virt Appliance) New-AzureRmResourceGroupDeployment -ResourceGroupName "rgVDC1network" -TemplateURI "./UserDefRoute/azuredeploy.json" -TemplateParameterURI "./UserDefRoute/azuredeploy.parameters.json"
#>

<#create virtualNetworks for VDC1#>
New-AzureRmResourceGroupDeployment -Name "vNet_Deploy" -ResourceGroupName $networkRG -TemplateURI $deployvnet -TemplateParameterURI $parametersvnet
<#create AD PDC#>
New-AzureRmResourceGroupDeployment -Name "PDC_Deploy" -ResourceGroupName $coreRG -TemplateURI $deploydc -TemplateParameterURI $parameterspdc

<#fix vnet DNS configuration with 1st server#>
New-AzureRmResourceGroupDeployment -Name "Add_PDC_DNS"-ResourceGroupName $networkRG -TemplateURI $deployvnetwdns -TemplateParameterURI $parametersvnetdns1

<#create AD BDC#>
New-AzureRmResourceGroupDeployment -Name "BDC_Deploy"-ResourceGroupName $coreRG -TemplateURI $deploydc -TemplateParameterURI $parametersbdc

<#fix vnet DNS configuration with 2nd server#>
New-AzureRmResourceGroupDeployment -Name "Add_BDC_DNS" -ResourceGroupName $networkRG -TemplateURI $deployvnetdns -TemplateParameterURI $parametersvnetdns2
