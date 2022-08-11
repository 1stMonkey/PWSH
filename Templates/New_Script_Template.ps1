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