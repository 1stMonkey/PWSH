<#
Name: Unclok_Form
Date: 10.17.16
Programmer: Erik Flores
Purpose: To unlock users from AD
Create a shortcut with C:\powershell.exe -WindowStyle Hidden -File c:\Unlock_form.ps1 to hide CLI. 
#>

Add-Type -AssemblyName System.Windows.forms
Import-module ActiveDirectory

#Function to update list of locked userds
function Getuserslist()
{
Foreach ($i in Search-ADAccount -usersonly -LockedOut | Select SamAccountName)
    {
    [void] $lbUsers.Items.Add($i.SamAccountName)
    }
}


#Form
$Form =New-Object System.Windows.Forms.Form
$Form.Text="User Unlocker"
$form.Size = New-Object System.Drawing.Size(250,150)

#lbSelect
$lbSelect=New-Object System.Windows.Forms.Label
$lbSelect.text="Please select user to be unlocked"
$lbSelect.AutoSize=$true
$Form.Controls.Add($lbSelect)

#Unlock button
$bntUnlock = New-Object System.Windows.Forms.Button
$bntUnlock.Text="Unlock"
$bntUnlock.Location =New-Object System.Drawing.Size(0,20)
$form.controls.Add($bntUnlock)

#Update list Button
$bntUpdate = New-Object System.Windows.Forms.Button
$bntUpdate.Text="Update"
$bntUpdate.Location =New-Object System.Drawing.Size(0,40)
$form.controls.Add($bntUpdate)

#Listbox
$lbUsers = New-Object System.windows.forms.Listbox
$lbUsers.location = new-object System.Drawing.size(80,20)
$lbUsers.height =80
$Form.controls.Add($lbUsers)

#Button Action
$bntUnlock.add_click(
    {if($lbUsers.SelectedItem -ne $null)
        {$x=$lbUsers.SelectedItem
        Unlock-ADAccount -identity $x -credential 
        $lbUsers.items.Remove($lbUsers.SelectedItem)
        }
    $lbUsers.items.clear
    $bntUnlock.Visible=$false
    $bntUpdate.Visible=$true
})

#Update locked users by clicking button 
$bntUpdate.add_click(
    {Getuserslist
        if ($lbusers.Items.Count -ge 1 )
            {
            $bntUpdate.Visible=$false
            $bntUnlock.Visible=$true
            }    
})

#Display Form
$bntUnlock.Visible=$false
$Form.TopMost=$true
$Form.showdialog()