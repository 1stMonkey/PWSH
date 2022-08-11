[CmdletBinding()]
param(
    [Parameter()][String]$Path,
    [Parameter()][String]$Destination,
    [Parameter()][String]$FormType,
    [Parameter()][int]$CurrentDate,
    [Parameter()][int]$LastDate,
    [Parameter()][int]$TrimCharacters = 25
)


$continue = $true
while($continue)
{


    
    $textdate = $CurrentDate.tostring("00000000")
    $rootPath =  join-path "Z:\File Import Studio\History" -ChildPath $textdate
    $FormPath = join-Path "Unidex" -ChildPath $FormType
    $path =   join-path $rootPath -ChildPath $FormPath
    if ($CurrentDate -eq $LastDate){
        Write-host "exiting current date $currentdate Lastdate $lastdate"
        Exit
    }

    if (test-path $path){
        Write-Host "This is the path $path"
        
        if ([console]::KeyAvailable){
            Write-Host "Exit with `"q`"";
            $x = [System.Console]::ReadKey() 

            switch ( $x.key){
                q { $continue = $false }
            }
        } 
        else
        {
            $Filenames = Get-ChildItem -Include *.pdf -Recurse -Path $Path
            foreach ($file in $filenames){
                $NewName = $file.name.substring(0,$file.name.length - ($TrimCharacters)) + '.pdf'
                $NewName
                Copy-Item -Path $file -Destination (Join-Path -Path $Destination -ChildPath $NewName)
                #remove-item (Join-path $Path -ChildPath $file.name)
               
            }
        
            $TextFiles = Get-ChildItem -Path $Path -Include *.idx -Recurse 
        
            foreach ($TextFile in $TextFiles) {
                
                $NewIDXName = $TextFile.name.substring(0,$TextFile.name.length -(36)) + '.idx'

                $NewIDXName

                Copy-Item -Path $TextFile -Destination (Join-Path -Path $Destination -ChildPath $NewIDXName)
                #remove-item (Join-path -Path $path -ChildPath $TextFile.name)
            }
            $CurrentDate = $CurrentDate + 10000

        }
    }
    else{
                    $CurrentDate = $CurrentDate + 10000
            Start-Sleep -Milliseconds 500
    }

}