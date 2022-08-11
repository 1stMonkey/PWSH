<#
    .synopsis
        General management of powershell transcript prcess and files.

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
        1.0.1
            ~ Change
            + New Feature
        1.0.2
            ~ Applied filter to get-child to get only files with desired ext and that are a # of days old
#>

function Set-Transcript {
       Param(
    [Parameter (Mandatory = $true)][String]$Today
    )

    #search for OneDrive folder
    if (Test-Path $env:OneDrive) {
        
        #$PSTransFolder  = Join-Path $env:OneDrive -ChildPath '\psTranscripts' #Powershell\psTranscript
        $PSTransFolder=$myConfig.myLogging.transcriptPath

        do {
            #Check if transcript folder exist
            if (test-path $PSTransFolder) {
                $x=0
                #Log the starting of transcript
                LogToFile -message "Transcript is being written" -type Info
        }

            else {
                #Creating PSTrancript folder because one does not exist.
                Write-output 'Creating psTranscript folder' -ForegroundColor yellow
                New-Item -ItemType Directory -Name 'psTranscripts' -Path $env:OneDrive
            }
        }

        #Setting variable to 0 to exit the do loop for verification of folder.
         until ($x -eq 0)
    }

    else {
        Write-output "No Transcript will be recored" -ForegroundColor Red
        #log that no transcript will be recorded because OneDrive is not available.
        LogToFile -message "OneDrive is not setup" -type Info
    }

}

#Set up folders and beging writing transcript to OneDrive
function write-Transcript {
    Param(
    [Parameter (Mandatory = $true)][String]$Today
    )
        #Form path where all Powershell items should be stored
        $tranFileName = 'psTranscript_'+ $env:COMPUTERNAME + '_' + $Today + '_'+ $PID +'.txt' #Name of transcript file
        $PSTransFile  = Join-Path $myConfig.myLogging.transcriptPath -ChildPath $tranFileName

        try {
            #Begin writing transcript
            Start-Transcript -Path ($PSTransFile) -Append -ErrorAction stop -WarningAction Continue

            #Log the starting of transcript
            LogToFile -message "Transcript is being written" -type Info
        }

        #Catch any other errors
        catch {
            #Log error message to file
            $errorFullName = $error[0].Exception.GetType().FullName
            $errorDesc     = $error[0]
            Logtofile -message "Unknown Error : $errorFullname `n$errorDesc" -type Error
        }   

}

#Open transcript for review
function get-Transcript {
    Param(
        [Parameter (Mandatory = $true)][String]$Today
        )
    code (Join-Path $env:OneDrive ('\psTranscripts\psTranscript' + $env:COMPUTERNAME + '_' + $Today + '-'+ $PID +'.txt'))
}

function Remove-Transcript {
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact='Medium')]
    param(
        [Parameter ()][Int]$numberOfDays = $myConfig.myLogging.RetentionDays
    )

    #get all log files from folder filtering folder that are # days old and have ext .txt
    $PSTransFolder = Join-Path $env:OneDrive -ChildPath '\psTranscripts' #Powershell\psTranscript
    $tsFilesList = Get-ChildItem $PSTransFolder | Where-Object {($_.LastWriteTime -lt (Get-Date).AddDays($numberOfDays)) -and ($_.Extension -eq ".txt")}

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