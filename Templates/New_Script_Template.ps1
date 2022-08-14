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
  [String]$aMandatoryParameter,

  [String]$nonMandatoryParameter,

  [Parameter(Mandatory=$true)]
  [String]$anotherMandatoryParameter

)
#Variables to store errors. 
$errorFullName = $error[0].Exception.GetType().FullName
$errorDesc     = $error[0]
function Get-SmallFiles {
  param (
      [PSDefaultValue(Help = '100')]
      $Size = 100,
      [switch]$on
  )
}

Add-log -message "This is the template: `n$errorDesc $errorFullname" -type Error