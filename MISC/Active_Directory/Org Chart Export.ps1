Import-Module activedirectory

$OrgChart = ".\ADOrgChart.txt"
$InitialIndent = " |--> "

$TopUser = Read-Host "Please enter Top Level Manager"
$OrgChart = ".\$TopUser-ADOrgChart.txt"
$OrgChartCSV = ".\$TopUser-ADOrgChart.csv"
get-aduser $TopUser -properties * | Select-Object Name,emailaddress,samaccountname,manager,department,@{ Name = 'Reports-to'; Expression = {'Boss' }} | export-csv $OrgChartCSV
function Get-DirectReports {
    param(
        [string]$Manager,
        [string]$Indent,
        [switch]$initial
    )
try{
    $UserResult = get-aduser $Manager -properties DirectReports,emailaddress,department 
    
    if($initial){
        write-output ""  | Tee-Object $OrgChart
        write-output "$($UserResult.name) : $($UserResult.Emailaddress)"  | Tee-Object $OrgChart -Append
        write-output " |"  | Tee-Object $OrgChart -Append

    } 
    if($UserResult.DirectReports) {
            Foreach ($DR in $UserResult.DirectReports){

                $DRObj = get-aduser $DR -properties DirectReports,emailaddress,manager,department
                $managerDetails = Get-ADUser (Get-ADUser $DR -properties manager).manager -properties displayName
                
                if($DRObj.samaccountname -notlike "*-a"){

                    $DRObj | select Name,emailaddress,samaccountname,manager,department,@{ Name = 'Reports-to'; Expression = {  $managerDetails.name }} | export-csv $OrgChartCSV -NoTypeInformation -Append
                    write-output "$Indent$($DRObj.name) : $($DRObj.Emailaddress) : $($DRObj.SamAccountName) : $($DRObj.Department)" | Tee-Object $OrgChart -Append

                if($DRObj.Directreports){

                    $NewIndent = "`t$Indent"
                    Get-DirectReports -Manager $DR -Indent $NewIndent
                
                }
            }
            }
        }
        

    
    } catch {
        Write-Host "No User ID found for $TopUser.  Exiting" -ForegroundColor Red
        break
    }

}


Get-DirectReports -Manager $TopUser -initial -Indent $InitialIndent

Write-host "Please refer to $Orgchart and $OrgChartCSV for results"