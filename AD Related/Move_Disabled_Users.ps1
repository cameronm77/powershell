$disabledusers = Search-ADAccount -AccountDisabled -UsersOnly -SearchBase"OU=OU,DC=DOMAIN,DC=corp"   | Select DistinguishedName

foreach($computer in $disabledcomputers)
{

Move-ADObject -Identity $computer.DistinguishedName -TargetPath "OU=DisabledAccounts,DC=DOMAIN,DC=corp" 

}
