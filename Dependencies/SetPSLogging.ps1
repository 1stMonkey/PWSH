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
        1.0.1 
            ~ Change
            + New Feature
        1.0.2
            ~ Applied filter to get-child to get only files with desired ext and that are a # of days old
#>

function Set-Logging{
    
    $Sname = Split-Path $MyInvocation.ScriptName -Leaf
    $Today = get-date -Format yyyyMMdd
    $LogFileName = 'log' + $Today + '.txt' #Name of transcript file
    $logPath = $myconfig.myLogging.loggingPath

    $x = 1
    do {
        #Check if transcript folder exist
        if (test-path $logPath) {

            $x=0

            $output = "[$sName][$date][$type][$functionCall][$line]: $message"
            Write-Output $output | out-file  -FilePath (Join-Path $logPath -ChildPath $LogFileName) -Append
    }

        else {
        write-host 'Creating psLogs folder' -ForegroundColor yellow
        New-Item -ItemType Directory -Path ($logPath)
        }

    }
     until ($x -eq 0)  

}

function LogToFile () {
    param(
        [Parameter(Mandatory = $true)][String]$message,
        [ValidateSet("Info", "Warning", "Error")][String]$type = "Info"
    )

    $date = get-date -Format g
    $trace = Get-PSCallStack
    $stack = @()
    $line = 0
   
    foreach($frame in $trace){
        $frameName = $frame.command
        $stack += $frameName
    }

   $callStack = $stack[-1.. ($stack.Length -1)]
    $functionCall = ""
    
    $lineArray =$trace.ScriptLineNumber -split ' '

    Foreach($frame in $callStack){
        if($frame -ne "LogToFile"){
            $functionCall = $frame + "|"
        }
    }

    $lineArray = $lineArray | Select  -Skip 1 | Select -SkipLast 1
    [array]::Reverse($lineArray)
    $line = $lineArray -join ':' 
    
    $functionCall = $functionCall.substring(0, $functionCall.Length -1)
    $output = "[$date][$type][$functionCall][$line]: $message"

    switch ($Type) {
        "Info" { write-host $output -foreground Yellow }
        "Warning" { write-host $output -ForegroundColor Magenta }
        "Error" { write-host $output -foreground Red }
    }

    $Sname = Split-Path $MyInvocation.ScriptName -Leaf
    $Today = get-date -Format yyyyMMdd
    $LogFileName = 'log' + $Today + '.txt' #Name of transcript file
    $logPath = $myconfig.myLogging.loggingPath

    $output = "[$sName][$date][$type][$functionCall][$line]: $message"
   try{
       Write-Output $output | out-file  -FilePath (Join-Path $logPath -ChildPath $LogFileName) -Append 
    }
    
    catch [System.IO.IOException] {
        Set-Logging
    }

}

function Remove-log {
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact='Medium')]
    param(
        [Parameter ()][Int]$numberOfDays = $myConfig.myLogging.RetentionDays
    )

    #get all log files from folder filtering folder that are # days old and have ext .txt
    $logFileList = Get-ChildItem $myconfig.myLogging.loggingPath | Where-Object {($_.LastWriteTime -lt (Get-Date).AddDays($numberOfDays)) -and ($_.Extension -eq ".txt")}
    
   
    foreach ($logFile in $logFileList){
        try {
            Remove-Item $logFile.FullName -ErrorAction Continue -WarningAction Continue
            if (!(Test-Path $logFile.FullName)){
                LogToFile -message "File $logFile has been deleted." -type Info    
            }
        }
        
        catch [System.IO.IOException]  {
            #Log error message to file
            $errorFullName = $error[0].Exception.GetType().FullName
            $errorDesc     = $error[0]
           LogToFile -message "File was not removed possibly because it is being used: $logFile : $errorFullname `n$errorDesc" -type Error 
        }
        catch {
            #Log error message to file
            $errorFullName = $error[0].Exception.GetType().FullName
            $errorDesc     = $error[0]
            Logtofile -message "Unknown Error : $errorFullname `n$errorDesc" -type Error
        }
    }
}