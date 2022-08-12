<#
  .synopsis
    Powershell's profile

  .Description
    Microsoft.PowerShell.profile.ps1 makes changes to the look and feel of the Posh terminal.
    Additionally, it starts Posh transcript, runs fuctions to delete transcript and log files
    past the number of retention days, dot sources other utilities scripts.

  .Inputs
    None

  .Outputs
   None

  .Example
    .$PROFILE

  .Notes
    Version: 1.0.1
    Author: Erik Flores
    Date Created: 20170713

  Changelog:
    1.0.1
      ~ Change
      + New Feature
      ~ moved all cmdlets to utilities.ps1
#>

#Check if OneDrive folder exist. Set working directory and source utilities
if (test-path $env:OneDrive){
   Set-Location $env:OneDrive
}

function Prompt {
    $myIdentity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $securityPrincipal  = [security.Principal.WindowsPrincipal] $myIdentity

    $(if (Test-Path variable.:/PSDebugContext) {'[DBG]: '}
        elseif($securityPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {"[ADMIN]: "}
        else{' '}

    $PromptString = (get-date -Format "HH:mm") +"------------------------------------------- `n" + $env:COMPUTERNAME + "  |" + (Get-Location) + "|`n=>"
    Write-Host $PromptString -ForegroundColor Yellow -NoNewline
    )
Return ' '
}

 $Today = get-date -Format yyyyMMdd

#Check if config file exist

$configFileName = $env:COMPUTERNAME + "_config.ps1"
$configFilePath = ".\PS\" + $configFileName

if ((test-path $configFilePath)) {
  . .\PS\EF-WS1_config.ps1
}
else{
  . .\PS\SetPSConfigFile.ps1
  CreateConfig $configFilePath
  }
#dot source utilities scripts
 . .\PS\SetPSUtilities.ps1

 #Begin transcript
 write-Transcript $Today

 #Remove logs and transcripts that are past number of retention days
 Remove-Log
 Remove-transcript


 if (test-path $myConfig.myProfile.myProfilePath){
   $myCreds = Import-Clixml $myConfig.myProfile.myProfilePath
 }
 
 else {
  . .\PS\SetCredsFile.ps1
   Set-MySuperCreds $fileName
   $myCreds = Import-Clixml $myConfig.myProfile.myProfilePath
 }
 oh-my-posh --init --shell pwsh --config .\PS\atomic.omp.json| Invoke-Expression