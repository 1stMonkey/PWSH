<#
  .synopsis
    simpliies connecting to proxy server

  .Description
    configure ways to make connections to various systems. Simplification of commands is the goal for the script. 
  
  .Inputs
    None

  .Outputs
    None
  
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

#Connect to proxy server at aea
function connect-proxy {
    $Proxy = "jump1.uconnect.local"
    
    if (Test-Connection $Proxy -count 1){
        #changig background to show text better when on Proxy 
        $Host.UI.RawUI.BackgroundColor = ('DarkGreen')
        Start-Process -filepath "pwsh" -ArgumentList ('/c ssh -C -D 1082 "erikflores@uconnect.local@jump1.uconnect.local"')
        $Host.UI.RawUI.BackgroundColor = ('DarkMagenta')
    }
    Else {
       $eMessage=$Error[0].Exception.Message
        LogtoFile -message "Tried connecting to Proxy. Somthing went wrong. $eMessage" -type Error 
    }
}

function Switch-NetAdpater {
    LogtoFile -message "Running script to switch Network adapters with Admin privileges" -type Info
    $scripPath =  (join-path $PSScriptRoot -ChildPath "NetAdapters.ps1")
    & $scripPath
}
