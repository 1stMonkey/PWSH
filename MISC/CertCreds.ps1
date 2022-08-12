<#
  .synopsis
  synopsis

  .Description
  description
  a
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

#Create certificate request from PKI.

function Request-Cert {
 # Create .INF file for certreq

{[Version]
  Signature = "$Windows NT$"
  
  [Strings]
  szOID_ENHANCED_KEY_USAGE = "2.5.29.37"
  szOID_DOCUMENT_ENCRYPTION = "1.3.6.1.4.1.311.80.1"
  
  [NewRequest]
  Subject = "cn=eflores@aeafcu.org"
  MachineKeySet = false
  KeyLength = 2048
  KeySpec = AT_KEYEXCHANGE
  HashAlgorithm = Sha1
  Exportable = true
  RequestType = Cert
  KeyUsage = "CERT_KEY_ENCIPHERMENT_KEY_USAGE | CERT_DATA_ENCIPHERMENT_KEY_USAGE"
  ValidityPeriod = "Years"
  ValidityPeriodUnits = "1000"
  
  [Extensions]
  %szOID_ENHANCED_KEY_USAGE% = "{text}%szOID_DOCUMENT_ENCRYPTION%"
  } | Out-File -FilePath DocumentEncryption.inf
  Pause
  
  # After you have created your certificate file, run the following command to add the certificate file to the certificate store.Now you are ready to encrypt and decrypt content with the next two examples.
  #certreq -new DocumentEncryption.inf DocumentEncryption.cer
  Remove-Item DocumentEncryption.inf
  
}
function Set-Mycreds {

    #find certificate to use to encrypt password

    $Cert = Get-ChildItem Cert:\CurrentUser\My\ | Where-Object {$_.Subject -eq "CN=eflores@aeafcu.org"}

    #Encrypt password

    #$Password =  read-host -Prompt 'Enter your password ' -AsSecureString
    $Password = (Get-Credential | ConvertTo-Xml)
    

    $Password.Password
   # $EncryptedPwd = 
    Protect-CmsMessage -To $Cert -Content ($Password | convert ) -OutFile Test.cms
    $Password.UserName
    $Password.Password | ConvertFrom-SecureString


    #save hash to file
    #"@'" + $EncryptedPwd + "'@" | Out-File -FilePath (join-path $myconfig.Home -ChildPath 'PSUtilities\test.txt')  -Force



    #https://www.cgoosen.com/2016/05/using-a-certificate-to-encrypt-credentials-in-automated-powershell-scripts-an-update/

}


function Get-MyCreds{
     #decrypt the password
    $Cert = Get-ChildItem Cert:\CurrentUser\My\ | Where-Object {$_.Subject -eq "CN=eflores@aeafcu.org"}
    $EncryptedPwd =  Get-Content -Path Test.cms 
    $DecryptedPwd = $EncryptedPwd | Unprotect-CmsMessage -To $Cert
    $DecryptedPwd 
    #use credentials
    $Username = "uconnect/erikflores"
    $Credentials = New-Object System.Management.Automation.PSCredential -argumentlist $UserName, ($DecryptedPwd | ConvertTo-SecureString)

   #$mycreds = $Credentials
    #$mycreds = ConvertFrom-SecureString $DecryptedPwd

    return $Credentials
}

if ($myCreds -eq $null) {

}
else {
  return $myCreds
}