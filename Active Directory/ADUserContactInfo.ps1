<#
  .synopsis
    Script will run query agains domain controllers to create csv contain users contact inforamtion including email, phone, fax and extension.  
  .Description
  
  .Notes
    Version: 1.1.1
    Author: Erik Flores
    Date Created: 20170801

Changelog:

  1.1.0 - 20170205
    + added exporting to CSV
    + added asking user where to save
  1.2 - 20220615
    ~ changed the way file name is obtained. 
    + added try catch to avoid script hanging 
    + added error logging
    ~ Renamed table headers
    ~ Remove "+" from the phone numbers as it causes excel to display them in a condense form. 
    + added AD filter to only query for users with email and title. 
    + added sort to create list with alphabetical order by name
    ~ changed "if (!$FileLocation)"" from "if ($FileLocation -eq Null)"" as it didn't work. 
    + Added opening of file after it has been created. 
    - Uncessary comments about file path location. 
#>

[CmdletBinding()]
param(
  [Parameter(Mandatory=$false)]
  [String]$outputpath = ".\AD_User_Contact_Info.csv"
)

#Variables to store errors. 
$errorFullName = $error[0].Exception.GetType().FullName
$errorDesc     = $error[0]

#Get filename location and name from users
$FileLocation = Read-Host -Prompt "Where do you want to save the file. Default name is  ADUserContactInfo.csv? "

#If user did not specify a file location and name assign default file name
if (!$FileLocation) {$FileLocation = $outputpath}

try {
  #Query AD for users with a title and emails like '@aeafcu.org'
  Get-ADUser -Filter "Title -like '*' -and emailaddress -like '*@aeafcu.org'" -Properties sAMAccountName, DisplayName, EmailAddress, Title, facsimileTelephoneNumber,`
  telephoneNumber, ipphone  |Sort-Object -property sAMAccountName| Select-Object @{name='Login ID'; expression = {$_.sAMAccountName}}, `
  @{name='Name'; expression = {$_.DisplayName}}, @{name='Email'; expression = {$_.EmailAddress}}, Title, @{name='Fax Number'; expression = {$_.facsimileTelephoneNumber.trim("+")}}, `
  @{Label='External Number'; Expression={$_.telephoneNumber.trim("+")}}, @{name='Extension Number'; expression = {$_.ipphone}} | Export-CSV $FileLocation 
}

catch {
  #Add record to log file
  Add-log -message "Unable to query AD: `n$errorDesc $errorFullname" -type Error
}

try {
      #open file
      Start-Process $FileLocation
}
#Log error message to file if access has been denied. 
catch [System.IO.IOException]{
  #Let the user know the file might be open. 
  write-host "Check the file is not open: `n$errorFullname `n$errorDesc"
  }
#Log error message to file any other error
catch {
  #Add record to log file
  Add-log -message "Unable to open file: `n$errorDesc $errorFullname" -type Error


}