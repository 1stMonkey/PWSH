$users = Get-aduser -Filter * - -Properties *

$NewUser =[pscustomobject]@{
usurname = ""
uGivenName = ""
uSamAccountName =""
uDepartment = ""
uMemberof = ""
}


foreach ($user in $users) {
$NewUser.usurname = $user.sn
$NewUser.uGivenName = $user.GivenName
$NewUser.uSamAccountName = $user.SamAccountName
$NewUser.uDepartment = $user.Department
$NewUser.uMemberof = $user | Select-Object -ExpandProperty memberof | Out-String
$NewUser | Export-Csv users.csv -Append 
}

