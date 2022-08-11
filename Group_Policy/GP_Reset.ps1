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

[CmdletBinding()]
param(

)

$GPpaths = @("C:\Windows\System32\GroupPolicy", "C:\Windows\System32\GroupPolicyUsers")


try {
  #Check if folder exists. 
    ForEach ($folder in $GPpaths) {
      If (test-path $folder){
        #Delete folder
        Write-output "Foder $folder will be deleted. "
        Remove-Item $folder -force -Recurse -ErrorAction stop 
    }
  }
}

catch [System.UnauthorizedAccessException]{
  #Log error message to file if access has been denied. 
  $errorFullName = $error[0].Exception.GetType().FullName
  $errorDesc     = $error[0]
write-host "Elevated permissions are required: `n$errorFullname `n$errorDesc"
}

catch {
  #Log error message to file
  $errorFullName = $error[0].Exception.GetType().FullName
  $errorDesc     = $error[0]
  write-host "Something went wrong with script: `n$errorFullname `n$errorDesc" 
}

#Rung GPUpdate if the folders don't exits after trying to delete them. 
if (!(Test-path $GPpaths[0])){
  GPupdate /force
}