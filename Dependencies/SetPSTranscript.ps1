<#
    .synopsis
        General management of powershell transcript process and files.

    .Description
        Transcript.ps1 starts poweshell transcripts in addition to recall current transcript and purge transcript files.

    .parameter numberOfDays
        Number of days old transcript file has to be to be included on list of files to be deleted.

    .Inputs
        Today date to crate transcript file name
        Retention date for Remove-Transcript. This argument comes from config hash file.


    .Outputs
        text files with a transcript of each powershell instance. 

    .Example
        Write-Transcript -Today (get-date -Format yyyyMMdd)
        Remove-Transcripts -numberOfDays 3

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
            ~ changed static variable to $myConfig.Logging.tsPath. 
        1.3 
            ~ changed log files extensions from .txt to .log. 
            ~ fixed the set-transcript module to ensure it was being called when folder didn't exitst. 
            ~ changed to $myconfig.logging.tsPath to make it shorter and simpler.
            ~ changed back to .txt as .log got confusing with logging. 

#>

#Configure folders and files to save transcript files.
function Set-Transcript {
    #Check if folder exists. 
    if (!(Test-Path $myConfig.Logging.tsPath)) {
        try {
            #Creating PSTrancript folder because one does not exist.
            Write-host 'Creating folder to save transcript files: ' $myconfig.Logging.tsPath
            New-Item -ItemType Directory -Path $myConfig.Logging.tsPath -ErrorAction stop
       }
       
       catch {
        #log that no transcript will be recorded because OneDrive is not available.
        LogToFile -message "Unable to create folder to save transcripts. No transcript will be recorded. " -type Info
                    
        #Log error message to file
        $errorFullName = $error[0].Exception.GetType().FullName
        $errorDesc     = $error[0]
        Logtofile -message "Unknown Error : $errorFullname `n$errorDesc" -type Error
       }
    }
}

#Set up folders and beging writing transcript to OneDrive
function write-Transcript {
    Param(
    [Parameter (Mandatory = $true)][String]$Today
    )
        #Form transcript file name with computer name, date and PID to create individual transcripts for each powershell process. 
        #This will allow to record each PS window to a separate transcript files. 
        $tranFileName = 'psTranscript_'+ $env:COMPUTERNAME + '_' + $Today + '_'+ $PID +'.txt'

        $PSTransFile  = Join-Path $myConfig.Logging.tsPath -ChildPath $tranFileName

        if (!(test-path $myConfig.Logging.tsPath)){
            Set-Transcript
        }
            
        try {
            #Begin writing transcript
            Start-Transcript -Path ($PSTransFile) -Append -ErrorAction stop -WarningAction Continue

            #Log the starting of transcript
            LogToFile -message "Transcript is being written" -type Info
        }

        catch {
            #Log error message to file
            $errorFullName = $error[0].Exception.GetType().FullName
            $errorDesc     = $error[0]
            Logtofile -message "Unknown Error : $errorFullname `n$errorDesc" -type Error
            }   
    
}

#Open transcript for review
function get-Transcript {
    #Open VSCode to view the current transcript. 
    #This assumes that VSCode is install on a Windows host. $IsWindows can be utilized to improve OS detection and opoen correct application. 
    code (Join-Path $myConfig.Logging.tsPath -childpath ('psTranscript_'+ $env:COMPUTERNAME + '_' + $Today + '_'+ $PID +'.txt'))
}

#Function to purge transcript logs based on configured age in days from configuration file. 
function Remove-Transcript {
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact='Medium')]
    param(
        [Parameter ()][Int]$numberOfDays = $myConfig.Logging.RetentionDays
    )

    #get all log files from folder filtering folder that are # days old and have ext .txt
    $tsFilesList = Get-ChildItem $myConfig.Logging.tsPath | Where-Object {($_.LastWriteTime -lt (Get-Date).AddDays($numberOfDays)) -and ($_.Extension -eq ".txt")}

    foreach ($tsFile in $tsFilesList){

        try {
            #Remove transcript file
            Remove-Item $tsFile.FullName -ErrorAction Continue -WarningAction Continue

            #If file no longer exist, log to file the deletion of file.
           if (!(Test-Path $tsFile.FullName)){
                LogToFile -message "File $tsFile has been deleted." -type Info
            }
        }

        #Catch error when file is being used by another process.
        catch [System.IO.IOException]  {
            #Log error message to file
            $errorFullName = $error[0].Exception.GetType().FullName
            $errorDesc     = $error[0]
            Logtofile -message "File was not removed possibly because it is being used: $tsFile : $errorFullname `n$errorDesc" -type Error
        }
        #Catch any other errors
        catch {
            #Log error message to file
            $errorFullName = $error[0].Exception.GetType().FullName
            $errorDesc     = $error[0]
            Logtofile -message "Unknown Error : $errorFullname `n$errorDesc" -type Error
        }
    }
}