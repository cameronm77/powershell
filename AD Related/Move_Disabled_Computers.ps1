$disabledcomputers = Search-ADAccount -AccountDisabled -ComputersOnly | Select DistinguishedName

foreach($computer in $disabledcomputers)
{

Move-ADObject -Identity $computer.DistinguishedName -TargetPath "OU=DisabledAccounts,DC=DOMAIN,DC=corp" 

}
