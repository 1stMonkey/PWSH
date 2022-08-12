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


## The following four lines only need to be declared once in your script.
$yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes","Description."
$no = New-Object System.Management.Automation.Host.ChoiceDescription "&No","Description."
$cancel = New-Object System.Management.Automation.Host.ChoiceDescription "&Cancel","Description."
$options = [System.Management.Automation.Host.ChoiceDescription[]]($yes, $no, $cancel)
$softwareTitle = "Microsoft.PowerShell", "Microsoft.VisualStudioCode", "Git.Git","Insecure.Nmap", "Balena.Etcher", "Microsoft.PowerToys", "Adobe.Acrobat.Reader.64-bit","Microsoft.SQLServerManagementStudio", "JanDeDobbeleer.OhMyPosh","RoyalApps.RoyalTS","Microsoft.WindowsTerminal"






Function OhMy{
  $title = "Fonts" 
  $message = "Do you want to download font for OhMyPosh?"
  $result = $host.ui.PromptForChoice($title, $message, $options, 1)
  
  switch ($result) {
    0{
      Invoke-WebRequest https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/JetBrainsMono.zip
    }
    1{
      Write-Host "The user declined download"
    }
    2{
      exit
    }
  }
}


Function WingetInstallSoftware{
  foreach ($App in $softwareTitle) {
    $title = "Software Installation" 
    $message = "Do you want to install $App ?"
    $result = $host.ui.PromptForChoice($title, $message, $options, 1)
  
    switch ($result) {
      0{
       Winget Install $App
      }
      1{
        Write-Host "The user declined installation"
      }
      2{
        exit
      }
    }
  }
}

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

WingetUpgradeall
OhMy
WingetInstallSoftware