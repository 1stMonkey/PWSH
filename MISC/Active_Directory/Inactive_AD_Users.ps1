<#
  .synopsis
    Script will generate a small report of accounts that are located in the "Disable" OU and have been modified between 90 and 120 days. 
  .Description
  
  .Notes
    Version: 1.0
    Author: Erik Flores
    Date Created: 20170713

Changelog:
  1.0.1 
    ~ Fixded a bug where the report would be empty because the timeafter and time before were reversed.
  1.0.2
    + The report has been rewritten to have a better presentation and has been assigned to a variable rather than outputting stream to screen. 
    + add the fuction to email report. 
    


#>
Param (
  [parameter(Mandatory)] [string]$Toemail,
  [parameter(Mandatory)] [string]$Fromemail,
  [parameter(Mandatory)] [string]$server
)

function Get-InactiveUsers{
  $timeBefore = (get-date).AddDays(-120) # This is how many days before the account has been changed
  $timeAfter = (get-date).AddDays(-90) # This how many days after the account has been changed
  $disabledUsers = Get-ADUser -filter {WhenChanged -gt $timeBefore -and WhenChanged -lt $timeAfter} -SearchBase "OU=Disabled Accounts,DC=uconnect,DC=local" `
    -SearchScope OneLevel -Properties Whenchanged | Select-object Name, WhenChanged |Out-String

  $Message = "This is the list of users that have been disabled for more than 90 days. `nInformation should be used to delete AD accounts, inboxes and home drives. `n`n`n"
  $report = $message + $disabledUsers
  Return $report
}

function Send-mail ($toEmailAddress, $Fromemailaddress, $emailserver, $emailBody1) {
    $emailSubject = "Inactive Users"
  
    $oCredential = New-Object System.Management.Automation.PSCredential ("anonymous", $(ConvertTo-SecureString "anonymous" -AsPlainText -Force))

      Send-Mailmessage -To $toEmailAddress `
        -From $fromEmailAddress `
        -Subject $emailSubject `
        -Body $emailBody1 `
        -SmtpServer $emailserver `
        #-Credential $oCred$entials
}
Clear-Host
$report
$emailBody = Get-InactiveUsers



Send-mail $toemail $Fromemail $server $emailbody



