[CmdletBinding()]
param(
    [Parameter()][String]$Path = (Get-Location),
    [Parameter()][String]$FileInclusion = "*idx",
    [Parameter(Mandatory = $true)][int]$MemberNumber

)


Get-ChildItem -Path $Path -Include $FileInclusion -Recurse | Select-String -Pattern $MemberNumber