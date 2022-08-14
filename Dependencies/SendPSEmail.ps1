<#
  .synopsis
    Send text emails

  .Description
    SendEmails.ps1 sends email to specified recipients.

  .Inputs
    Static arguments are imported from config file.
    To: email addres to whom email will be sent to
    Subject: Email's subject
    Body: The text that will be sent in the body of email
    Attachment: Files attachment that need to be sent withing the email

  .Outputs
    Email message

  .Example
    Send-email -Subject "Test1" -Body "This is the message"

  .Notes
    Version: 1.0
    Author: Erik Flores
    Date Created: 20170713

  Changelog:
    1.0.1
      ~ Change
      + New Feature
      ~ Added Try-catch to log any errors
      ~ Added logging when message is sent
      ~ Added Priority and Delivery notification
      ~updated config file to include username and password. 
      ~created object to hold credentials. Get-gredentials | import-clixml doens't work. 
#>
#Variables to store errors. 
$errorFullName = $error[0].Exception.GetType().FullName
$errorDesc     = $error[0]

function Send-email{
    param(
        [Parameter ()][string]$From       = $myConfig.myEmail.From,
        [Parameter ()][String]$To         = $myConfig.myEmail.to,
        [Parameter ()][String]$SMTPServer = $myConfig.myEmail.Server,
        [Parameter ()][String]$SMTPPort   = $myConfig.myEmail.Port,
        [Parameter ()][String]$Priority   = "Normal",
        [Parameter ()][String]$DelNotify  = "OnFailure",
        [Parameter (Mandatory = $true)][String]$Subject,
        [Parameter (Mandatory = $true)][String]$Body,
        [Parameter (Mandatory = $false)][String]$Attachment
    )

    try {
      #Following line is to prevent error Send-MailMessage : The remote certificate is invalid according to the validation procedure.
      [System.Net.ServicePointManager]::ServerCertificateValidationCallback = { return $true }

      $SmtpUser = $myConfig.myemail.SmtpUser
      $smtpPassword = $myConfig.myemail.smtpPassword
      $Credentials = New-Object System.Management.Automation.PSCredential -ArgumentList $SmtpUser, $($smtpPassword | ConvertTo-SecureString -AsPlainText -Force)
      Send-MailMessage -From $From -to $To -Subject $Subject -Body $Body -SmtpServer $SMTPServer -port $SMTPPort `
      -UseSsl -Priority $Priority -DeliveryNotificationOption $DelNotify -Credential ($Credentials)-ErrorAction Continue -WarningAction Continue  #-Attachments $Attachment
      
      #$Attachment.Dispose()

      #Add record to log file
      add-log -message "Email was sent [To:$To] [Subject:$Subject] [Body:$Body]" -type info
    }

    #Catch any errors while sending email.
    catch {
      #Add record to log file
      add-log -message "Something went wrong with sending email: $errorFullname `n$errorDesc" -type Error
    }
}
