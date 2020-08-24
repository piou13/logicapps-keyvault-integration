[CmdletBinding()]
Param(
	[Parameter(Mandatory=$true)]
    [string]$ResourceGroupName,

    [Parameter(Mandatory=$true)]
    [string]$KeyvaultName,

    [Parameter(Mandatory=$true)]
    [string]$LogicappsName,

    [Parameter(Mandatory=$true)]
    [string]$UserAssignedIdentitiesName
)

$0 = $myInvocation.MyCommand.Definition
$CommandDirectory = [System.IO.Path]::GetDirectoryName($0)
Push-Location $CommandDirectory

Connect-AzAccount

if ($null -eq (Get-AzResourceGroup -Name $ResourceGroupName -ErrorAction Ignore)) {
    throw "The Resources Group '$ResourceGroupName' doesn't exist."
}

Write-Host "Resource Group Name: $ResourceGroupName"
Write-Host "Deploying ARM Template ... "

Push-Location "..\arm"
$DeploymentName = "LogicAppKeyvault-" + ((Get-Date).ToUniversalTime()).ToString("MMdd-HHmm")

$ArmParamsObject = @{"KeyvaultName"=$KeyvaultName;"LogicappsName"=$LogicappsName;"UserAssignedIdentitiesName"=$UserAssignedIdentitiesName}
New-AzResourceGroupDeployment -Mode Incremental -Name $DeploymentName -ResourceGroupName $ResourceGroupName -TemplateFile "logicapps-keyvault.json" -TemplateParameterObject $ArmParamsObject

Write-Host "Done" -ForegroundColor Green
Push-Location $CommandDirectory