#Install-Module -Name AzureAD
#Connect-AzureAD
#Connect-MsolService

#Get-AzureADUser -ObjectID <sign-in name of the user account>
#Get-AzureADUser | Select-Object * | Export-Csv C:\Users\UserName\Desktop\mol.csv
#Get-MsOlUser -All | Select-Object * | Export-Csv C:\Users\UserName\Desktop\SGT_l.csv
#Get-MsolUser -UserPrincipalName UserFQDN.Licenses[<LicenseIndexNumber>].ServiceStatus
Get-MsolUser -All | where {$_.isLicensed -eq $true}| cExport-Csv C:\Users\UserName\Desktop\SGT_2.csv

#$role=get-msolrole -RoleName "Company Administrator"
#Get-MsolRoleMember -RoleObjectId $role.objectid
