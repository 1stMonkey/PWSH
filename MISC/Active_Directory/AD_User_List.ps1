<#
  .synopsis
    script will run a queary against domain to obtain users and their information. Report will be saved to user's desktop of a specific path if desired. 
  .Description
  
  .Notes
    Version: 1.1.1
    Author: Erik Flores
    Date Created: 20170801

Changelog:

  1.1.0 - 20170205
    + added exporting to CSV
    + added asking user where to save
  1.1.1 - 20170801
    ~ changed the query to return user's last logon, password expired date, password never expires, and userAccountcontrol
    ~ Changed the default path of csv report to user's desktop. 
  1.2.1
    + added a switch statment to convert userAccountcontrol codes to a user readable entry. 

#>

[CmdletBinding()]
param(
  [Parameter(Mandatory=$false)]
  [String]$outputpath = ".\AD_User_list.csv"
)



#explain file location and name requirement
write-host "This script will output a file containing all Active Directory users. Specified file location and name needs to have csv extention specified explicitly. e.g. list.csv or \\server\share\list.csv"

#Get filename location and name from users
$FileLocation = Read-Host -Prompt "Where do you want to save the file. Default value AD_User_list.csv? Press enter for user's Desktop "

#If user did not specify a file location and name assign default file name
#$fullpath = Join-Path -path $env:USERPROFILE -ChildPath "Documents|AD_User_List.csv"
if ($FileLocation -eq $null) {Write-Host "True"}
#Write-Host $fullpath
#Write-Host "FIleLocation" $FileLocation

#Import active directory module
#Import-module ActiveDirectory

<#
Try {
    #run query to get users from AD and output data into file

    Get-ADUser -Filter * -Properties sAMAccountName, DisplayName, pwdLastSet, lastLogon, userAccountControl| Select-object sAMAccountName,  DisplayName, @{name='pwdLastSetDT';  expression={[datetime]::fromFileTime($_.pwdlastset)}}, @{name='lastLogonDT'; expression={[datetime]::fromFileTime($_.lastLogon)}}, `
       @{name = 'AccountControl'; expression ={switch ($_.userAccountControl){ `
         512 {"enabled"} `
         514 {"Disabled"} `
         544 {"enabled  password not required"} `
         66082 {"disabled  password does not expire and not required"} `
         66048 {"enabled  password never expires"} `
         66050 {"disabled  password never expires"}  `
         590336 {"enabled  user cannot change password  password never expires"} `
         4194818 {"account disable normal_account dont_req_preauth"} `
         4194816 {"enabled - dont_req_preauth"} `
         4260352 {"enabled -dont req preauth, password never expires"}         
         16843264 {"users can delegate resources"} `
        }}} | Export-CSV -Path $outputpath -NoTypeInformation
    }
Catch [System.exception]{$error[0]}
Finally{"End of script"}
 #>
  Get-ADUser -Filter * -Properties sAMAccountName, DisplayName, EmailAddress, Title, facsimileTelephoneNumber,telephoneNumber, ipphone  | Select-Object @{name='Login ID'; expression = {$_.sAMAccountName}}, @{name='Name'; expression = {$_.DisplayName}}, @{name='Email'; expression = {$_.EmailAddress}}, Title, @{name='Fax Number'; expression = {$_.facsimileTelephoneNumber}}, @{name='External Number'; expression = {$_.telephoneNumber}}, @{name='Extension Number'; expression = {$_.ipphone}} | Export-CSV $FileLocation   