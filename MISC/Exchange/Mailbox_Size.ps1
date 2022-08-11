<#
Name: Mailbox_Size
Date: 7.18.15
Programmer: Erik Flores
Purpose: To obtain a list of mailboxes sizes and save it as a csv file 
#>

#explain file location and name requirement
write-host "This script will output a file containing all mailboxes and their sizes. Specified file location and name needs to have csv extention specified explicitly. e.g. list.csv or \\server\share\list.csv"

#Get filename location and name from users
$FileLocation = Read-Host -Prompt 'Where do you want to save the file. Default value Mailbox_Size_list.csv'
$DToday = get-date -format g

#If user did not specify a file location and name assign default file name
if ($FileLocation -eq '') { $FileLocation = 'Mailbox_Size_list.csv'} 

#Databases into an array
$MailDatabase = @("Staff", "Support", "leadership", "Management", "IT")

Try {
    $DToday > $FileLocation
    
    foreach ($MailDatabase in $MailDatabase) {
                                            Get-MailboxDatabase $MailDatabase |Get-MailboxStatistics |Sort totalitemsize -desc |ft displayname, @{label=”Total Size (MB)”;expression={$_.TotalItemSize.Value.ToMB()}},@{label=”Items”;expression={$_.ItemCount}}, @{label=”Storage Limit”;expression={$_.StorageLimitStatus}} >> $FileLocation
                                            }
    }
Catch [System.exception]{ "caught a system exception"}
Finally{"End of script"}
