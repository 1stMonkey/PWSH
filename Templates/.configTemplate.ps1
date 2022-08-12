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
  credsfile = $env:USERPROFILE + "\Documents"  + "\mycreds.xml"
  
  #Parameters needed to be able to send emails using sendEmail.ps1.
  myEmail = @{       
    From    = #"The.IT.Monkeys@hotmail.com"
    To      = #"The.IT.Monkeys@hotmail.com"
    Server  = #"smtp-mail.outlook.com"
    Port    = #"25"
    SmtpUser = ''
    smtpPassword = ''
  }
  
  #Logging.ps1 parameters
  myLogging =@{
    #Number of days a file will be retain before being purge. 
    RetentionDays   = #"-30" 
    #Path to save transcripsts. Strongly suggested to place them inside one drive 
    transcriptPath  = #$env:OneDrive + "PSTranscript"
    loggingPath     = #$env:USERPROFILE + "\Documents\PSLogs"
  }

  #Proxy information
  myConnections = @{
    Proxy = ""
    User = ""
    Args = ""
   
  }

}