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
#>


Write-Host "90 Days Disabled Users /n"
Search-ADAccount -SearchBase "OU=90 Days,OU=LegalHold,OU=Disabled Accounts,DC=uconnect,DC=local" -AccountInactive -TimeSpan 70.00:00:00 |FT name, samaccountname, Lastlogondate -A
Write-Host "180 Days Disabled Users /n"
Search-ADAccount -SearchBase "OU=180 Days,OU=LegalHold,OU=Disabled Accounts,DC=uconnect,DC=local" -AccountInactive -TimeSpan 160.00:00:00 |FT name, samaccountname, Lastlogondate -A
Write-Host "360 Days Disabled Users /n"
Search-ADAccount -SearchBase "OU=365 Days,OU=LegalHold,OU=Disabled Accounts,DC=uconnect,DC=local" -AccountInactive -TimeSpan 300.00:00:00 |FT name, samaccountname, Lastlogondate -A