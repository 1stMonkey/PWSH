<#
  .synopsis
    Get O365 group informaiton.

  .Description
    Scripts connects to Azure to gather data about O365 groups. This script can be useful to find departed users who are owers of O365 groups. 
    This is important as removing user from group does not remove them from being an owner. 

  .Inputs
    None

  .Outputs
    PS Grid with O365 group's data

  .Example
    .\Groups_Owner.ps1

  .Notes
    Version: 1.0
    Author: Erik Flores
    Date Created: 20220408

  Changelog:
    1.0.0
      ~ Change
      + New Feature
    1.0.1
      ~ added more attributes to the grid columns. 
#>

if (Get-Module -ListAvailable -Name AzureAD) {
    Write-Host "Module exists"
} 
else {
    Write-Host "Module does not exist"
    
}

#Connect to AzureAD
Connect-AzureAD
$GroupData = @()
 
#Get all Office 365 Groups
Get-AzureADMSGroup -Filter "groupTypes/any(c:c eq 'Unified')" -All:$true | ForEach-object {
    $GroupName = $_.DisplayName
     
    #Get Owners
    $GroupOwners = Get-AzureADGroupOwner -ObjectId $_.ID | Select UserPrincipalName, DisplayName, Mail, Visibility
 
        $GroupData += New-Object PSObject -Property ([Ordered]@{
        Group_Name = $GroupName
        Owner = $GroupOwners.UserPrincipalName -join "; "
        OwnerName = $GroupOwners.DisplayName -join "; "

    })
}
 
#Export Group Owners data to CSV
$GroupData | Sort-Object -Property GroupName | Out-GridView
