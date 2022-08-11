
'Get statistics on mailbox databases.
	Get-MailboxDatabase "Mailbox Database" |Get-MailboxStatistics |Sort totalitemsize -desc |ft displayname, @{label=�Total Size (MB)�;expression={$_.TotalItemSize.Value.ToMB()}},@{label=�Items�;expression={$_.ItemCount}}, @{label=�Storage Limit�;expression={$_.StorageLimitStatus}} > \\pc00033\C$\Users\erikflores\Desktop\emailsizeReport.txt



'Add personal picture to address book.
	Import-RecipientDataProperty -Identity "Name" -Picture -FileData ([Byte[]]$(Get-Content -Path "C:\users\erikflores\Desktop\Jarmenta.jpg" -Encoding Byte -ReadCount 0))



'Mailbox move request to another database
	New-MoveRequest -Identity Eflores@uconnect.local -TargetDatabase 'IT' -BadItemLimit '10'




'This to remove database from the default email creation list.
	Set-MailboxDatabase -Identity "Mailbox Database 04" -IsExcludedFromProvisioning $true


'This example clears the move request from all mailboxes that have a status of Completed. 


	Get-MoveRequest -MoveStatus Completed | Remove-MoveRequest

