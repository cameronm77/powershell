$OUpath = 'OU=OU,OU=OU,OU=OU,dc=DOMAIN,dc=corp' 
$ExportPath = 'C:\Users\<USERNAME>Documents\PS-Scripts\Output\service.csv' 
Get-ADUser -Filter * -SearchBase $OUpath -ResultPageSize 0 -Prop CN,samaccountname,lastLogonTimestamp,lastlogon,Enabled | 
Select CN,samaccountname,@{n="lastLogonDate";e={[datetime]::FromFileTime($_.lastLogonTimestamp)}},@{n="lastLogon";e={[datetime]::FromFileTime($_.lastLogonTimestamp)}},Enabled | Export-CSV -NoType $ExportPath
