<#
    .synopsis
        General management of powershell logs

    .Description
        Logging.ps1 generate logging files containg information about where error, waring and inf ormational messages are originated from and the powershell stack generated. 
    .parameter numberOfDays
        Number of days old transcript file has to be to be included on list of files to be deleted. 

    .Inputs
        None

    .Outputs
        None
  
    .Example
        Remove-logs -numberOfDays

    .Notes
        Version: 1.0
        Author: Erik Flores
        Date Created: 20170713

    Changelog:
        1.1 
            ~ Change
            + New Feature
        1.2
            ~ Applied filter to get-child to get only files with desired ext and that are a # of days old
            ~ simplified code when setting log folders. 
            - removed sending logs to log folder when there is an error creating log folder. 

#>
#Variables to store errors. 
$errorFullName = $error[0].Exception.GetType().FullName
$errorDesc     = $error[0]

#Function to create folder to save log files. 
function Set-Logging{
    Write-host "Setting up logging. "
    if (!(Test-Path $myConfig.Logging.lPath)) {
        try {
            #Creating  folder because one does not exist.
            Write-host 'Creating folder to save log files: ' $myconfig.Logging.lPath
            New-Item -ItemType Directory -Path $myConfig.Logging.lPath -ErrorAction stop
       }
       
       catch {        
        #Log error message to file
        $errorFullName = $error[0].Exception.GetType().FullName
        $errorDesc     = $error[0]
        Write-Host "Unable to create folder. Error: $errorDesc`n $errorFullName"
       }
    }
}

function add-log () {
    param(
        [Parameter(Mandatory = $true)][String]$message,
        [ValidateSet("Info", "Warning", "Error")][String]$type = "Info"
    )


    $date = get-date -Format g
    #The Get-PSCallStack is used to determined what script called the fuction. This is an array of objects. 
    $trace = Get-PSCallStack
    #To save the names of all the commands from the call stack. 
    $stack = @()
    $line = 0
   
    #Extract the name of the command  from the $trace array as it contain more informaiton than needed. 
    foreach($frame in $trace){
        #Add each command name to $stack
        $stack += $frame.command
    }

    #Remove the first object in $stack as it contains the calling script without the fuction information. Less usefull. 
    #Remove the last object in $stack as it is the call from this function on line #62 $trace = Get-PSCallStack
    $callStack = $stack[-1.. ($stack.Length -1)]
    $functionCall = ""
    
    #Get the line numbers that made the call to the script. This is an array if there are multiple hops.
    #Splitting at ' ' to separate the numbers into an array. 
    $lineArray =$trace.ScriptLineNumber -split ' '

    #Cycle thru the $stack (command names) to remove the name of this fuction (add-log) and (<ScriptBlock>) as they are not necessary. 
    Foreach($frame in $callStack){
        if($frame -ne "add-log" -and $frame -ne "<ScriptBlock>"){
            $functionCall += $frame + "|"
        }
    }

    #Remove the first and the last ScriptLineNumber as the first is this script and the last is the call from this function on line #62 $trace = Get-PSCallStack
    $lineArray = $lineArray | Select-Object  -Skip 1 | Select-Object -SkipLast 1
    #Merge the array of ScriptLineNumber to a single variable to simply sending to output. Also adding ':' as a separator for easy reading. 
    $line = $lineArray -join ':' 

    #Display the text in different colors depending on the severity of the message. 
    switch ($Type) {
        "Info" { write-host $output -foreground Yellow }
        "Warning" { write-host $output -ForegroundColor Magenta }
        "Error" { write-host $output -foreground Red }
    }

    #Get current time to document timelines
    $Today = get-date -Format yyyyMMdd
    #Built the name of the log file to include date. All PS processes will log to the same log file on the same day. 
    $LogFileName = 'log' + $Today + '.txt' #Name of transcript file
    
    #Build the message to be sent to log. 
    $output = "[$date][$type][$functionCall][$line]: $message Other"

    try{
        #Write message to log file. 
        Write-Output $output | out-file  -FilePath (Join-Path $myconfig.logging.lPath -ChildPath $LogFileName) -Append 
    }
    
    catch [System.IO.IOException] {
        #Start setup of logging folders when they don't exists. 
        Set-Logging
    }

    catch{
        #When everything else fails, let the user know something went wrong. 
        Write-output "Something went wrong with writing log. Unknown error."
    }

}

#Function to purge log files based on configured age in days from configuration file. 
function Remove-log {
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact='Medium')]
    param(
        [Parameter ()][Int]$numberOfDays = $myConfig.Logging.RetentionDays
    )

    #get all log files from folder filtering folder that are # days old and have ext .txt
    $logFileList = Get-ChildItem $myconfig.Logging.lPath | Where-Object {($_.LastWriteTime -lt (Get-Date).AddDays($numberOfDays)) -and ($_.Extension -eq ".txt")}
    


    foreach ($logFile in $logFileList){

        try {
            #Remove log file
            Remove-Item $logFile.FullName -ErrorAction Continue -WarningAction Continue
            
            #If file no longer exist, log to file the deletion of the file. 
            if (!(Test-Path $logFile.FullName)){
                #Add record to log file
                add-log -message "File $logFile has been deleted." -type Info    
            }
        }

        #Catch error when file is being used by another process. 
        catch [System.IO.IOException]  {
            #Add record to log file
            add-log -message "File was not removed possibly because it is being used: $logFile : $errorFullname `n$errorDesc" -type Error 
        }

        #Catch any other errors. 
        catch {
            #Add record to log file
            add-log -message "$errorFullname `n$errorDesc" -type Error
        }
    }
}