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
  [String]$Path,
  [Parameter(Mandatory=$true)]
  [String]$fileExt,
  [Parameter(Mandatory=$true)]
  [Int32]$numberOfDays
)

Begin {
  #Check if the path provided exists. 
  If (!(Test-path $Path)){
    write-outpu "Path doesn't exits."
    #Exit script if path does not exits. 
    Exit
  }
}

Process {
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

  #Varaible to hold the list of deleted files. 
  $deletedfiles= @()

  #Get list of file from the specified path that matches age and extension. 
  $fileList = Get-ChildItem -Path $Path | Where-Object {($_.LastWriteTime -lt (Get-Date).AddDays($numberOfDays))  -and ($_.Extension -eq $fileExt)}
 
  #Cycle thrue the files one at a time to delete them. 
  foreach ($file in $filelist){
    try {
        #Remove file.
        Remove-Item $File.FullName -ErrorAction Continue -WarningAction Continue -WhatIf
    }
    
    #Catch error when file is being used by another process.
    catch [System.IO.IOException]  {
      #Add record to log file
      add-log -message "File was not removed possibly because it is being used: $tsFile : $errorFullname `n$errorDesc" -type Error
    }
           
    #Catch any other errors
    catch {
      #Add record to log file
      send-log -message "Error purging file $File : " -messagetype Error
    }

    finally{
      #If file no longer exist, log to file the deletion of file.
      if ((Test-Path $file.FullName)){
        #Add record to log file
        send-log -message "File $file has been deleted." -messagetype Info
        $deletedfiles += $file
      }
    }
  }
}

end {
  #Output the count and list of names of the files deleted. 
  Write-host "These are the deleted files `n"
  $deletedfiles
  $deletedfiles |Measure-Object | Select-Object Count
}