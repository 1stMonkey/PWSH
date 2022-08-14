<#
  .synopsis
    Install a pre-configure list of applications

  .Description
    Provides the option to install group of applications useful when setting up new workstations that need your typical set of tools installed. 

  .Inputs
    None

  .Outputs
    None

  .Example
    invoke-command Winget_Install.ps1

  .Notes
    Version: 1.0
    Author: Erik Flores
    Date Created: 20220320

  Changelog:
    1.0.1
      ~ Change
      + New Feature
#>

#The following four lines only need to be declared once in your script.
$yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes","Description."
$no = New-Object System.Management.Automation.Host.ChoiceDescription "&No","Description."
$cancel = New-Object System.Management.Automation.Host.ChoiceDescription "&Cancel","Description."
$options = [System.Management.Automation.Host.ChoiceDescription[]]($yes, $no, $cancel)

#Import list of software from csv and assign to variable. 
$softwareTitle =Import-csv ".\SoftwareList.csv"

#Function to install applications from SoftwareList.csv
Function WingetInstallSoftware{
  #Cycle thru all the sofware names from Softwarelist.csv asking the user if they would like it for it to be installed. 
  foreach ($App in $softwareTitle) {
    $title = "Software Installation" 
    $message = "Do you want to install " + $app.name + "?"
  
    #Build message to be presented to user during switch. 
    $result = $host.ui.PromptForChoice($title, $message, $options, 1)
  
    #Switch to provide the option toinstall
    switch ($result) {
      0{
        if ($app.name -ne "JanDeDobbeleer.OhMyPosh"){
          #Install software
          Winget Install $App.name -h -s winget
        }
        
        else{
          #Oh-My-Posh requires some fonts to work properly. This will install software and download the font. 
          $X = join-path $env:HOMEPATH -ChildPath "\Downloads\Fonts.zip"
          Winget Install $App.name -h -s winget
          Invoke-WebRequest "https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/JetBrainsMono.zip" -OutFile $X
        }

      }

      1{
        #Do not install software. 
        Write-Host "The user declined installation"
      }

      2{
        #Cancel action and exit
        exit
      }
    }
  }
}

#Experimental:
function WingetUpgradeall {
  if (Get-ScheduledTask -TaskName WingetUpgrade){
    Write-Host "Schedule task exists"

  }
 else {
     $Mypath = '-NoLogo -NoProfile  Winget upgrade --all'
     $Action = New-ScheduledTaskAction -Execute 'pwsh.exe' -Argument $Mypath
     $Trigger = New-ScheduledTaskTrigger -Weekly -WeeksInterval 2 -DaysOfWeek Monday -At 8am
     $Settings = New-ScheduledTaskSettingsSet
     $Task = New-ScheduledTask -Action $Action -Trigger $Trigger -Settings $Settings
     Register-ScheduledTask -TaskName 'WingetUpgrade' -InputObject $Task 
 }
}

WingetInstallSoftware