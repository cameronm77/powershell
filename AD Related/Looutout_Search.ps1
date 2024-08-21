#Search-ADAccount -LockedOut | Select Name, LockedOut, LastLogonDate | Sort-Object -Property Name | Export-csv C:\Users\UserName\Desktop\users_lastlogon.csv



$disabledcomputers = Search-ADAccount -AccountDisabled -UsersOnly | Select DistinguishedName

foreach($computer in $disabledcomputers)
{

Move-ADObject -Identity $computer.DistinguishedName -TargetPath "OU=DisabledAccounts,DC=DOMAIN,DC=corp" 

}


$users = get-aduser -filter * -SearchBase "OU=DisabledAccounts,DC=DOMAIN,DC=corp"

foreach($user in $users)
{

Set-ADUser -Identity $user.SamAccountName -Manager $null

}

