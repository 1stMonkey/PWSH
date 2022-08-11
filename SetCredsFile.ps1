<#
  .synopsis
    Save credentials to file

  .Description
    Obtain credentials to save them to an xml object in the user's local home path. The credentils are saved to variable to be used later in commands and scripts. 
  
  .Inputs
    $myConfig.myProfile.myProfilePath

  .Outputs
    xml file saved @ $myConfig.myProfile.myProfilePath with encrypted credentials. 
  .Example
    Set-MySuperCreds $fileName
    $myCreds = Import-Clixml $myConfig.myProfile.myProfilePath

  .Notes
    Version: 1.0
    Author: Erik Flores
    Date Created: 20170713

Changelog:
  1.0 
    ~ Change
    + New Feature
  1.1
    ~ Removed the fuction to get credentilas
    + added Yes/No prompt to ask if credential file should be obtaina and file created. 
    ~ Simplified the script by removing extra code and unecessary variables. 
    ~

#>

function Set-MySuperCreds {
    ## The following four lines only need to be declared once in your script.
    $yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes","Description."
    $no = New-Object System.Management.Automation.Host.ChoiceDescription "&No","Description."
    $options = [System.Management.Automation.Host.ChoiceDescription[]]($yes, $no)
    
    ## Use the following each time your want to prompt the use
    $title = "Credentials file" 
    $message = "Do you want to create an encrypted file containing your credentials?"
    $result = $host.ui.PromptForChoice($title, $message, $options, 1)
    switch ($result) {
     0{
      #Getting credentials and saving them 
       Get-Credential | Export-Clixml $myConfig.myProfile.myProfilePath
     }

     1{
         #Warning of no file creation. 
       Write-Host "No credentials file will be created. "
       Logtofile -message "Credentilas file was not created : $errorFullname `n$errorDesc" -type Info
     }
    }
}