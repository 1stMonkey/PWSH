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
  [Parameter(Mandatory=$true)]
  [String]$ServerInstance
)
#Variables to store errors. 
$errorFullName = $error[0].Exception.GetType().FullName
$errorDesc     = $error[0]


try {
    Invoke-Sqlcmd -Query "SELECT GETDATE() AS TimeOfQuery" -ServerInstance "MyComputer\MainInstance"
}
catch {
    Logtofile -message "Unknown Error : `n$errorDesc $errorFullname" -type Error
}
