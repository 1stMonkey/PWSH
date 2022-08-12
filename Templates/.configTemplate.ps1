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

  #Location of mycreds file for export and import
  credsfile = $env:USERPROFILE + "\Documents"  + "\mycreds.xml"
  #sendEmail.ps1
  myEmail = @{       
      From    = ""
      To      = ""
      Server  = "smtp-mail.outlook.com"
      Port    = "25"
      SmtpUser = ''
      smtpPassword = ''
  }
  
  #Logging.ps1 parameters
  myLogging =@{
    RetentionDays   = "-30"
    transcriptPath  = $env:OneDrive + "\PSTranscripts"
    loggingPath     = $env:USERPROFILE + "\Documents\PSLogs"
}
#Proxy information
myConnections = @{
  Proxy = ""
  User = ""
}

}