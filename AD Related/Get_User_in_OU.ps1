$searchpath = "OU=OU,OU=OU,OU=OU,OU=OU,dc=DOMAIN,dc=corp"

$export = "C:\Users\UserName\documents\POWERSHELL\Output\Tier3-OPS.csv"

get-aduser -Filter * -SearchBase $searchpath -Properties Description | Select SamAccountName,Name,GivenName,Surname,Department,DistinguishedName | Export-Csv $export 

