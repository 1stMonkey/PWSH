[CmdletBinding()]
    Param(
        [parameter(ValueFromPipeline=$true)]
        [string[]]$Users
    )

    BEGIN{
        # . source sc_trans.ps1
        . ("C:\My_Fuctions\sc_trans.ps1")

        $My_sc_name = Split-Path $MyInvocation.InvocationName.Replace(".ps1","") -Leaf

        New_Trans $My_sc_name
     }

    Process{
        Foreach ($user in $Users){
            Set-MailboxFolderPermission -Identity "$($User):\Calendar" -User default -AccessRights limiteddetails
        }
    }

    end{
        Stop-Transcript
    }


<#
#$user = Get-Mailbox -Identity rperez -RecipientTypeDetails UserMailbox

#$user | ForEach {Set-MailboxFolderPermission -Identity "$($_.alias):\Calendar" -User default -AccessRights limiteddetails}


Owner: Allows full rights to the Mailbox/Folder/Calendar, including assigning permissions; you should consider this carefully before assigning this role to anyone besides yourself.
Publishing Editor: Create, read, edit, and delete all items; create subfolders
Editor: Create, read, edit, and delete all items
Publishing Author: Create and read items; create subfolders; edit and delete items they've created
Author: Create and read items; edit and delete items they've created
Non-editing Author: Create and read items; delete items they've created
Reviewer: Read items
Contributor: Create items
None: Gives no permissions for the selected accounts on the specified folder
#>
