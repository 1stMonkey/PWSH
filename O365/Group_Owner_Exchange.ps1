<#
  .synopsis
    Get O365 group informaiton.

  .Description
    Scripts connects to O365 to gather data about O365 groups. This script can be useful to find departed users who are owers of O365 groups. 
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

#Connect to Exchange Online
Connect-ExchangeOnline -ShowBanner:$False
 
#Get All Office 365 Groups
$GroupData = @()
$Groups = Get-UnifiedGroup -ResultSize Unlimited -SortBy Name
 

#Loop through each Group
$Groups | Foreach-Object {
    #Get Group Owners
    $GroupOwners = Get-UnifiedGroupLinks -LinkType Owners -Identity $_.Id | Select-object DisplayName, PrimarySmtpAddress, `
      GroupMemberCount, AccessType, Notes, AllowAddGuests, ModerationEnabled
    
    $GroupData += New-Object -TypeName PSObject -Property @{
            Guest_Allowed = $_.AllowAddGuests
            Moderation =$_.ModerationEnabled    
            Owner = $GroupOwners.DisplayName -join "; "
            Group_Name = $_.Alias
            "Group's Email" = $_.PrimarySmtpAddress
            "Member Count" =$_.GroupMemberCount
            Access =$_.AccessType
            Notes =$_.Notes
    }
}
#Get Groups Data
#$GroupData
$GroupData | Sort-Object -Property GroupName | Out-GridView

#Disconnect Exchange Online
Disconnect-ExchangeOnline -Confirm:$False


