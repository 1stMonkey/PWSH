<#
  .synopsis
    Powershell's profile

  .Description
    Microsoft.PowerShell.profile.ps1 makes changes to the look and feel of the Posh terminal.
    Additionally, it starts Posh transcript, runs fuctions to delete transcript and log files
    past the number of retention days, dot sources other utilities scripts.

  .Inputs
    None

  .Outputs
   None

  .Example
    .$PROFILE
    ll
    cd
    runadmin
    connect-proxy
    $mycreds

  .Notes
    Version: 1.0.1
    Author: Erik Flores
    Date Created: 20170713

  Changelog:
    1.0.1
      ~ Change
      + New Feature
      ~ moved all cmdlets to utilities.ps1
      + moved ll, cd, run admin, connect-proxy into $profile from separate scripts.
      ~ cleaded up spacing of the script to make easier to read. 
      + moved dot sourcing files into $profile from seprate script. 
      ~ added for each to dot source all files under Dependencies folder. 
      ~ modified the checking of configuration file to ensure it is available before using and to renove redundant code. 
      ~ modified the checking of credentials file to ensure it is available and that OS is Windows. 
      - Remove redundant code to create credentials files. 
      + Added feature to enable or disable Oh-My-Posh based on configuration file property. 
      ~ modified code to allow prompt modification as a backup if Oh-My-Posh is not enabled. 
      ~ move Oh-My-Posh dependencies files to Dependencies folder and changed paths in code. 
      + Added file validation before dot sourcing configuration file. 

#>
$yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes","Description."
$no = New-Object System.Management.Automation.Host.ChoiceDescription "&No","Description."
$cancel = New-Object System.Management.Automation.Host.ChoiceDescription "&Cancel","Description."
$options = [System.Management.Automation.Host.ChoiceDescription[]]($yes, $no, $cancel)

#Remove alias for CD because replacement has been created Ref# function cd
if (test-path alias:cd ) { remove-item alias:cd}

function cd {
  Param(
    [Parameter(Position=0)][string]$literalPath = $env:OneDrive
    )

  #Change location and list files afterwards.     
  Set-Location $literalPath ; ll
}

#Enchance display of get-child by providing the size in Mb. 
function ll{
  Param(
    [Parameter(Position=0)][string]$literalPath
    )

    #Check if path is null and if it is make it the current path.
    if($null -eq $literalPath) {$literalPath = "."}
    get-childitem $literalPath | Select-object BaseName, Extension, @{Name='size(Mb)'; Expression={[math]::Round($_.Length/1024/1024,2)}}, Mode
}

#Run powershell in administrative mode. 
function runadmin{
  #Checking if Powershell is running with administrative provilege
  If (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)){
    Start-Process powershell -Verb runAs #-ArgumentList $arguments
  }
}

#Function to simplify connecting to proxy on a separare window. 
function connect-proxy {
  if (Test-Connection $myConfig.myConnections.proxy -count 1){
    $myArguments = $myconfig.myConnections.Args
    #Start new powershell window.
    Start-Process -filepath "pwsh" -ArgumentList ($myArguments)
  }
  Else {
    $eMessage=$Error[0].Exception.Message
    LogtoFile -message "Tried connecting to Proxy. Somthing went wrong. $eMessage" -type Error 
  }
}

#Function to create configuration file. 
Function createConfigFile ($Filepath) {
  # Use the following each time your want to prompt the use
  $title = "Config File" 
  $message = "Do you want to create a config file?"
  $result = $host.ui.PromptForChoice($title, $message, $options, 1)

  switch ($result) {
    0{
      try {
        #This will copy the config file template and save it to OneDrive with host name included on file name. 
        Copy-Item ".\Templates\.configTemplate.ps1" -Destination $FilePath
        
        #Open file for editing. 
        notepad $FilePath | Out-Null

        #Let the user know where the configuration file is located. 
        write-host "`nA new configuration file has been created:`n  $env:OneDrive\$FilePath `n"
      }

      catch {
        #Catch any errors. 
        $errorDesc     = $error[0]
        $errorFullName = $error[0].Exception.GetType().FullName
        #Logtofile -message "Unknown Error : `n$errorDesc $errorFullname" -type Error
        Write-Host "Error creating file. Error: $errorDesc`n $errorFullName"
      }
    }

  1{
    #Option to not create a config file. 
    Write-host "Configuration file will not be created."
  }
 }
}

#Fuction to modify the default prompt of Powershell windows. This will only show if Oh-My-Posh is not enabled and serves as a backup. 
function Prompt {
  $myIdentity = [Security.Principal.WindowsIdentity]::GetCurrent()
  $securityPrincipal  = [security.Principal.WindowsPrincipal] $myIdentity

  $(if (Test-Path variable.:/PSDebugContext) {'[DBG]: '}
    elseif($securityPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {"[ADMIN]: "}
    else{' '}

    $PromptString = (get-date -Format "HH:mm") +"------------------------------------------- `n" + $env:COMPUTERNAME + "  |" + (Get-Location) + "`n=>"
    Write-Host $PromptString -ForegroundColor Yellow -NoNewline
  )
  Return ' '
}

#Function to capture credentials and save the securestring to xml. 
function Set-MySuperCreds {
  # Use the following each time your want to prompt the use
  $title = "Credentials file" 
  $message = "Do you want to create an encrypted file containing your credentials?"
  $result = $host.ui.PromptForChoice($title, $message, $options, 1)

  switch ($result) {
   0{
    #Getting credentials and saving them 
     Get-Credential | Export-Clixml $myConfig.credsfile
   }

   1{
    #Warning of no file creation. 
    Write-Host "No credentials file will be created. "
    Logtofile -message "Credentilas file was not created : $errorFullname `n$errorDesc" -type Info
   }
  }
}

#Check if Default Path folder exist and set the working directory containing Powershell scripts.
$childPath = "PS"

$DefaultPath = Join-Path $env:OneDrive -ChildPath $childPath
If (test-path $DefaultPath){
  Set-Location $DefaultPath
}
  
else {
  #Create folder when it does not exist inside OneDrive. 
  New-item -path $DefaultPath -ItemType Directory
}

#The configuration file contains parameters utilized by the scripts and must be modified for each system. 
#Configuration File
$configFileName = $env:COMPUTERNAME + "_config.ps1"


#Check if file exitst. 
if (!(test-path $configFileName)) {
  #Call fuction to create configuraiton file when it does not exits. 
  createConfigFile $configFileName
}

#Appending ".\" to the cofiguration name variable to be able to dot source the file as PowerShell does not load commands from the current location by default.  
$Dotme = ".\" + $configFileName
  
#Dot source the configuraiton file to be available. 
If (test-path $Dotme){. $Dotme}

#Dot source all the scripts on the dependencies folder. 
Get-ChildItem -Path .\Dependencies\ -Filter *.ps1 | ForEach-Object { . $_.FullName}

#Begin transcript
$Today = get-date -Format yyyyMMdd
write-Transcript $Today

#Purge logs and transcript files of a given age in days. Retention is managed from configuraiton file. 
./start-purge.ps1 -Path $myconfig.Logging.lPath  -numberOfDays $myconfig.Logging.RetentionDays
./start-purge.ps1 -Path $myconfig.Logging.tsPath  -numberOfDays $myconfig.Logging.RetentionDays
#Import stored credentials to variable. 

#Verify file exist. 
if (!(test-path $myConfig.credsfile) ){
  #Verify OS is Windows as credentials are saved as secured string only on Windows. 
  if ($IsWindows){
    #Call fucntion to ask for creadentials and saved them to XML file as a secure string. 
    Set-MySuperCreds
  }
  
  else {
    #Inform the user that credentials will not be saved due to security issue of credentials saving as plain text on linux and Mac OS. 
    Write-host "The credentials cannot be saved on a secure string on a non-windows environment."
  }

}

#Import credentials into variable from file. 
if (test-path $myConfig.credsfile){$myCreds = Import-Clixml $myConfig.credsfile}
 
#Check if the Oh-my-posh module is installed and load configuration. 
if ($myConfig.EnableOhMyPosh -eq "Yes"){
  oh-my-posh --init --shell pwsh --config .\PS\Dependencies\atomic.omp.json| Invoke-Expression
  #Winget install JanDeDobbeleer.OhMyPosh or Winget_install.ps1 can be utilized to install module.
}
