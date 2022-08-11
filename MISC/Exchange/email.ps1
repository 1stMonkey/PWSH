<#
  .synopsis

  .Description

  .Notes
    Version: 1.0
    Author: Erik Flores
    Date Created: 20170714

Changelog:
  1.0.1 
    ~ Change
    + New Feature


#>
$toEmailAddress = ""
$fromEmailAddress = ""
$emailSubject = "Test email 1"
$emailBody = "This is the first test of sending and email."
function sendmail {
$oCredential = New-Object System.Management.Automation.PSCredential ("anonymous", $(ConvertTo-SecureString "anonymous" -AsPlainText -Force))
  Send-Mailmessage -To $toEmailAddress`
    -From $fromEmailAddress`
    -Subject $emailSubject`
    -Body $emailBody `
    -SmtpServer "" `
    -Credential $oCredential
}