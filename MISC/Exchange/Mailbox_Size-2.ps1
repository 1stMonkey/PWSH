
<#
  .synopsis

  .Description
    To obtain a list of mailboxes size
  .Notes
    Version: 1.1
    Author: Erik Flores
    Date Created: 20150718

Changelog:
  1.1.0 
    + Report will be emailed instead of stored. 
  1.1.1
  ~ email server and addres have been added as parameters instead of static variables


#>

Param (
  [parameter(Mandatory)] [string]$Toemail,
  [parameter(Mandatory)] [string]$Fromemail,
  [parameter(Mandatory)] [string]$server
)
function Get-Emailsize{
  $data = Invoke-Command -ComputerName mailcent1 -ScriptBlock {
    add-pssnapin Microsoft.Exchange.Management.PowerShell.E2010
    #Get filename location and name from users
    $DToday = get-date -format g
    #Databases into an array
    $MailDatabase = @("Staff", "Support", "leadership", "Management", "IT")

    Try {
        $DToday
        $MailSize =  foreach ($MailDatabase in $MailDatabase) {
        Get-MailboxDatabase $MailDatabase | Get-MailboxStatistics `
        | Sort-Object TotalItemSize -Descending | Format-table -AutoSize `
        @{label = "User";expression = {$_.displayname}; Width = 15}, `
        @{label = "Total Size (MB)"; expression={($_.TotalItemSize.Value.ToMB())}}, `
        @{label = "Item"; expression={$_.ItemCount}}, `
        @{label = "Storage Limit" ; expression={$_.StorageLimitStatus}}
        }
    }

    Catch [System.exception]{ "caught a system exception"}
    Finally{"End of script"}

    Return $MailSize

  }
  return $data

}


function Send-mail ($toEmailAddress, $Fromemailaddress, $emailserver, $emailBody1) {
    $emailSubject = "Inbox Size"
  
    $oCredential = New-Object System.Management.Automation.PSCredential ("anonymous", $(ConvertTo-SecureString "anonymous" -AsPlainText -Force))

      Send-Mailmessage -To $toEmailAddress `
        -From $fromEmailAddress `
        -Subject $emailSubject `
        -Body $emailBody1 `
        -SmtpServer $emailserver `
        #-Credential $oCred$entials
}
Clear-Host
$emailbody = Get-Emailsize

Send-mail $toemail $Fromemail $server ($emailbody | Out-String)

