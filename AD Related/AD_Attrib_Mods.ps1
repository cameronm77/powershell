$OUpath = 'ou=OU,dc=DOMAIN,dc=corp'
Get-ADUser -Filter * -SearchBase $OUpath | Set-ADUser  -Replace @{c="US";co="United States";countrycode=840}
