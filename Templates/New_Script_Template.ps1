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
#Fuction to write logs. Use send-logs -message "This is the message" -messagetype (Info, Waring, Error)
Function send-log{
  param(
    [Parameter(Mandatory=$true)]
    [String]$message,
    [Parameter(Mandatory=$true)]
    [String]$messageType
  )

  #Check if the "add-log" fuction exist on the fuction drive to prevent using it when not available.
  $functionList = Get-ChildItem function: | Where-Object {$_.name -eq "add-log"}
  if ($functionList){
    #Check if the message type is error as it requires the $error variable and atributes to log the entire message. 
    if ($messageType -ne "Error"){
      #Add info or waring log by calling SetPSlogging script to write log
      add-log -message $message -type $messageType
    }
     
    else{
      #Variables to store errors. 
      $errorFullName = $error[0].Exception.GetType().FullName
      $errorDesc     = $error[0]

      #Add error log by calling SetPSlogging script to write log
      add-log -message "$message : $errorFullname `n$errorDesc" -type $messageType
    }
  }
}

function Get-SmallFiles {
  param (
      [PSDefaultValue(Help = '100')]
      $Size = 100,
      [switch]$on
  )
}
