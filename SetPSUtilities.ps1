<#
  .synopsis
    This script serves as a central place to dot source utilities scripts. Additionally,
    it containg functions to add earier ways run task or changes behavior of cmdlets.

  .Description
    dot sourcing scripts from the PSUtilities folder. This script is initiated from Powershell's profile.
  .Inputs
    None

  .Outputs
    None

  .Example
    None

  .Notes
    Version: 1.0
    Author: Erik Flores
    Date Created: 20170713

  Changelog:
    1.0.1
      ~ Change
      + New Feature


#>

. .\PS\SendPSEmail.ps1
. .\PS\SetPSConnections.ps1
. .\PS\SetPSLogging.ps1
. .\PS\SetPSTranscript.ps1
. .\PS\SetCredsfile.ps1
 #Remove alias for CD because replacement has been created Ref# function cd
 if (test-path alias:cd ) { remove-item alias:cd}

#Display folder contents after changing directore
function cd {
  Param(
      [Parameter(Position=0)][string]$literalPath = $env:OneDrive
      )
  Set-Location $literalPath ; ll
}

#Enchance display of get-child
function ll{
  Param(
    [Parameter(Position=0)][string]$literalPath
    )

    #Check if path is null and if it is make it the current path.
    if($null -eq $literalPath) {$literalPath = "."}
    get-childitem $literalPath | Select-object BaseName, Extension, @{Name='Length(Mb)'; Expression={[math]::Round($_.Length/1024/1024,2)}}, Mode
  }

  #Set alias with parameter to edit files with VScode
function edit {
   Param(
       [Parameter(Mandatory = $true, Position=0)][string]$literalpath
       )
       code $literalpath
       #~Needs to check if VSCode exist
}

#Copy Powershell profile to VScode's powershell profile.
function Copy-ProfileToVSCode {
   Copy-Item $Profile -Destination (join-path $env:OneDrive -ChildPath '\Documents\WindowsPowerShell\Microsoft.VSCode_profile.ps1')
}

#Run powershell with administrative provileges
function runadmin{
  #Checking if Powershell is running with administrative provilege
  If (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)){
      Start-Process powershell -Verb runAs #-ArgumentList $arguments
  }
}