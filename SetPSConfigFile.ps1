<#
  .synopsis
    create configuration files for scritps to obtain variables. 

  .Description
    Create configuration file containing several attributes that are needed for scripts to work properly. 
    If configuration file does not exist, a new file will be created from a template located in the template folder. 

  .Inputs
    configFilePath = path where the file will be saved. 

  .Outputs
    One PS configuration file for each device. 

  .Example
    CreateConfig $configFilePath
    CreateConfig C:\Users\%username%\Documents

  .Notes
    Version: 1.0
    Author: Erik Flores
    Date Created: 20220326

  Changelog:
    1.0
      ~ Change
      + New Feature
    1.1
      ~ Change the path to allow .config file to be moved to TemplateFolder.
      ~Rename the .config file to .configTemplate to avoid being included on gitignore
#>

Function CreateConfig {
    param(
        [Parameter(Mandatory = $true)][String]$configFilePath
    )

    ## The following four lines only need to be declared once in your script.
    $yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes","Description."
    $no = New-Object System.Management.Automation.Host.ChoiceDescription "&No","Description."
     $options = [System.Management.Automation.Host.ChoiceDescription[]]($yes, $no)

     ## Use the following each time your want to prompt the use
     $title = "Config File" 
     $message = "Do you want to create a config file?"
     $result = $host.ui.PromptForChoice($title, $message, $options, 1)

     switch ($result) {
        0{
         #This will copy the config file template and save it to OneDrive with host name included on file name. 

             if (!(test-path $configFilePath)) {
                 Write-host "Creating configuration file"
                 Copy-Item ".\PSUtilities\Templates\.configTemplate.ps1" -Destination $configFilePath

                 #Open file for editing. 
                 notepad $configFilePath | Out-Null

                 write-host "A new configuration file has been created " + $configFilePath
             }

             else {
                 #Warn that config file already exist.
                 Write-host "File already exist at " + $configFilePath
             }
        }

        1{
             #Option to not create a config file. 
             Write-host "Configuration File will not be created."
             Write-Host "No"
        }
    }
}