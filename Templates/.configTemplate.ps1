<#
  .synopsis
    synopsis

  .Description
    description
  
  .Inputs
    input

  .Outputs
    output
  
  .Example
    example

  .Notes
    Version: 1.0
    Author: Erik Flores
    Date Created: 20170713

  Changelog:
    1.0.1 
      ~ Change
      + New Feature
      ~ added myLogging - RetentionDays
#>

$myConfig = @{
  Home = ""

  #Path to save xml file containing secure string credentials for Windows only.
  credsfile = $env:USERPROFILE + "\Documents"  + "\mycreds.xml"

  #Enable or disable Oh-My-Posh on Powershell. When off, the backup propt will be utilized. 
  #Winget install JanDeDobbeleer.OhMyPosh or Winget_install.ps1 can be utilized to install module.
  EnableOhMyPosh = "Yes"
  
  #Parameters needed to be able to send emails using sendEmail.ps1.
  myEmail = @{       
    From    = "The.IT.Monkeys@hotmail.com"
    To      = "The.IT.Monkeys@hotmail.com"
    Server  = "smtp-mail.outlook.com"
    Port    = "25"
    SmtpUser = $emailcreds.username
    smtpPassword = $emailcreds.password
  }
  
  #Logging.ps1 parameters
  Logging =@{
    #Number of days a file will be retain before being purge. 
    RetentionDays   = "-30" 
    #Path to save transcripsts. Strongly suggested to place them inside one drive 
    tsPath  = $env:OneDrive + "\PSTranscript"
    lPath     = $env:USERPROFILE + "\Documents\PSLogs"
  }

  #Proxy information
  myConnections = @{
    Proxy = ""
    User = ""
    Args = ""
   
  }

}