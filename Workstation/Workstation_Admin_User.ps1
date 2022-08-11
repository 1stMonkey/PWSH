<#
  .synopsis
    synopsis

  .Description
    description

  .Inputs
    input

  .Outputs
    output

  .Example
    example

  .Notes
    Version: 1.0
    Author: Erik Flores
    Date Created: 20170713

  Changelog:
    1.0.1
      ~ Change
      + New Feature
#>

[CmdletBinding()]
param(

  [Parameter(Mandatory=$True)]
  [String]$userAccount,
  [Parameter(Mandatory=$True)]
  [SecureString]$Password
)


Function CheckPassword {
    <#checking if the supplied password meets pattern validation. 
        Must contain a digit
        Must contain a lower case letter
        Must contain a capital letter
        Must contain between 12 and 40 characters. 
        #>

    Param(
        [ValidatePattern ("((?=.*\d)")]
        [Parameter(Mandatory=$True)]
        [String]$PlainPass
    )
Write-Host $PlainPass

#(?=.*[a-z])(?=.*[A-Z]).{12,40})
}
 #secure string is being converted to plain text to be able to perform pattern validation
$x = ConvertFrom-SecureString -SecureString $Password -AsPlainText


try {
    #Changing the ErrorActionPreference to Stop to stop script when error is encountered. 
    $ErrorActionPreference = 1

    #checking if the supplied password meets Pattern validation. 
    CheckPassword $x 


    #Check if the account exist and update password. 
    if(Get-LocalUser $userAccount){
        Get-LocalUser $userAccount | Set-LocalUser -Password $Password 
        Write-Output "`nUser $userAccount password has been updated"
    }
    
    #Create new account if account does not exits. 
    Else{
        New-LocalUser -Name $userAccount -Description "This is the break glass account" -Password $Password -AccountNeverExpires -PasswordNeverExpires 
        Write-Host "Account $userAccount has been created. "
    }
    
    #Check account exists before adding to group. 
    if(Get-LocalUser $userAccount){
        Add-LocalGroupMember -Group Administrators -Member $userAccount 
        Write-Output "`nUser $userAccount has been added to Administrators group"
    }
}

#Log error message to file if access has been denied. 
catch [System.UnauthorizedAccessException]{
    $errorDesc     = $error[0]
    $errorFullName = $error[0].Exception.GetType().FullName
    write-host "Elevated permissions are required: `n$errorFullname `n$errorDesc" -type Error
  }
<#
#Log error message to file if password validation failed.
catch [System.Management.Automation.RuntimeException]{
    $errorDesc     = $error[0]
    $errorFullName = $error[0].Exception.GetType().FullName
    write-host "`nPassword Pattern validation has failed. `
    Must contain a digit `
    Must contain a lower case letter `
    Must contain a capital letter `
    Must contain between 12 and 40 characters"
  }
#>
#Log error message to file any other error
catch {
     $errorDesc     = $error[0]
     $errorFullName = $error[0].Exception.GetType().FullName
     Logtofile -message "Unknown Error : `n$errorDesc $errorFullname" -type Error
}
