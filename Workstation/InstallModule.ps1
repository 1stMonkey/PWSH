<#
  .synopsis
    Install powershell modules

  .Description
    Script will attempt to install module from the suplied module name from pipeline or other scripts. 

  .Inputs
    Module Name -The name of the module to be installed. 

  .Outputs
    None

  .Example
    InstallModule AzureAD

  .Notes
    Version: 1.0
    Author: Erik Flores
    Date Created: 20170713

  Changelog:
    1.0.1
      ~ added comments to script to make it easy to undertand. 
      + New Feature
#>


[CmdletBinding()]
param(
  [Parameter(Mandatory=$true)]
  [String]$moduleName
)

#Check if the module already exists. 
if (Get-Module -ListAvailable -Name $moduleName) {
  #Notfiy user module is already installed. 
  Write-Host "Module $moduleName already exists"
} 

else {
  If (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)){
    # Relaunch as an elevated process: Pass module name.
    Start-Process pwsh.exe  "-File",('"{0}"' -f $MyInvocation.MyCommand.path ), $moduleName -Verb RunAs
  }
  else {
    #Notify user of wait time on new window. 
    Write-output "Getting module informaion"
    install-module $moduleName
    #Ask user to press any key to allow reader to read window before closing. 
    Read-Host -Prompt "Press any key to continue"
  }
}