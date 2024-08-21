Import-Module ActiveDirectory

#Set your working domain
$DomainID= 'DC=DOMAIN,DC=LOCAL'
$fARMID = 'DOMAIN'

# Add FARM Layout and FG Groups
New-ADOrganizationalUnit -Name "FARM" -Path "$DomainID" -ProtectedFromAccidentalDeletion $true
New-ADOrganizationalUnit -Name "FARM-Servers" -Path "OU=FARM,$DomainID" -ProtectedFromAccidentalDeletion $true
New-ADOrganizationalUnit -Name "FARM-Groups" -Path "OU=FARM,$DomainID" -ProtectedFromAccidentalDeletion $true
New-ADOrganizationalUnit -Name "FARM-ServiceAccounts" -Path "OU=FARM,$DomainID" -ProtectedFromAccidentalDeletion $true
New-ADGroup -Name "FG_${FARMID}_SA_USERS" -DisplayName "FG_${FARMID}_SA_USERS" -GroupScope Universal -GroupCategory Security  -Path "OU=Farm-Groups,OU=FARM,$DomainID"
#new-ADGroup -Name "FG_${FARMID}_FA_USERS" -DisplayName "FG_${FARMID}_FA_USERS" -GroupScope Universal -GroupCategory Security  -Path "OU=Farm-Groups,OU=FARM,$DomainID"
#New-ADGroup -Name "FG_${FARMID}_LA_USERS" -DisplayName "FG_${FARMID}_LA_USERS" -GroupScope Universal -GroupCategory Security  -Path "OU=Farm-Groups,OU=FARM,$DomainID"
New-ADGroup -Name "FG_${FARMID}_DA_USERS" -DisplayName "FG_${FARMID}_DA_USERS" -GroupScope Universal -GroupCategory Security  -Path "OU=Farm-Groups,OU=FARM,$DomainID"

#Add Farm Staff Layout
New-ADOrganizationalUnit -Name "Staff Farms" -Path "$DomainID" -ProtectedFromAccidentalDeletion $true

New-ADOrganizationalUnit -Name "MIS" -Path "OU=Staff Farms,$DomainID" -ProtectedFromAccidentalDeletion $true
New-ADOrganizationalUnit -Name "MIS-Users" -Path "OU=MIS,OU=Staff Farms,$DomainID" -ProtectedFromAccidentalDeletion $true
New-ADOrganizationalUnit -Name "MIS-Groups" -Path "OU=MIS,OU=Staff Farms,$DomainID" -ProtectedFromAccidentalDeletion $true
New-ADOrganizationalUnit -Name "MIS-ServiceAccounts" -Path "OU=MIS,OU=Staff Farms,$DomainID" -ProtectedFromAccidentalDeletion $true
#Create MIS Accounts
#Create MIS Accounts
#New-ADUser -Name UserName-${FARMID} -samaccountname cmilani-${FARMID} -Path "OU=MIS-Users,OU=MIS,OU=Staff Farms,$DomainID" -AccountPassword (ConvertTo-SecureString -AsPlainText "P@ssw0rd1234" -Force) -Enabled $true
New-ADUser -Name UserName-${FARMID} -SamAccountName jellis-${FARMID} -Path "OU=MIS-Users,OU=MIS,OU=Staff Farms,$DomainID" -AccountPassword (ConvertTo-SecureString -AsPlainText "P@ssw0rd1234" -Force) -Enabled $true
New-ADUser -Name UserName-${FARMID} -SamAccountName tsawyer-${FARMID} -Path "OU=MIS-Users,OU=MIS,OU=Staff Farms,$DomainID" -AccountPassword (ConvertTo-SecureString -AsPlainText "P@ssw0rd1234" -Force) -Enabled $true
New-ADUser -Name UserName-${FARMID} -SamAccountName sminer-${FARMID} -Path "OU=MIS-Users,OU=MIS,OU=Staff Farms,$DomainID" -AccountPassword (ConvertTo-SecureString -AsPlainText "P@ssw0rd1234" -Force) -Enabled $true
New-ADUser -Name UserName-${FARMID} -SamAccountName dvollenweider-${FARMID} -Path "OU=MIS-Users,OU=MIS,OU=Staff Farms,$DomainID" -AccountPassword (ConvertTo-SecureString -AsPlainText "P@ssw0rd1234" -Force) -Enabled $true
New-ADUser -Name UserName-${FARMID} -SamAccountName jjohnson-${FARMID} -Path "OU=MIS-Users,OU=MIS,OU=Staff Farms,$DomainID" -AccountPassword (ConvertTo-SecureString -AsPlainText "P@ssw0rd1234" -Force) -Enabled $true

#Add MIS User to Domain Admins
$MISUsers = get-aduser -SearchBase "OU=MIS-Users,OU=MIS,OU=Staff Farms,$DomainID" -Filter *  | select SamAccountName
foreach($user in $MISUsers)
{
  Add-ADGroupMember -Identity "Domain Admins" -Members $user.samaccountname -ErrorAction SilentlyContinue
  Add-ADGroupMember -Identity "FG_${FARMID}_DA_USERS" -Members $user.samaccountname -ErrorAction SilentlyContinue
}



#Create Security Operations
New-ADOrganizationalUnit -Name "SOP" -Path "OU=Staff Farms,$DomainID" -ProtectedFromAccidentalDeletion $true
New-ADOrganizationalUnit -Name "SOP-Users" -Path "OU=SOP,OU=Staff Farms,$DomainID" -ProtectedFromAccidentalDeletion $true
New-ADOrganizationalUnit -Name "SOP-Groups" -Path "OU=SOP,OU=Staff Farms,$DomainID" -ProtectedFromAccidentalDeletion $true
New-ADOrganizationalUnit -Name "SOP-ServiceAccounts" -Path "OU=SOP,OU=Staff Farms,$DomainID" -ProtectedFromAccidentalDeletion $true
#$SOPUsers = get-aduser -SearchBase "OU=SOP-Users,OU=SOP,OU=Staff Farms,$DomainID" -Filter *  | select SamAccountName
#foreach($user in $SOPUsers)
#{
  #Add-ADGroupMember -Identity "SecOPS-Staff-Sec" -Members $user.samaccountname -ErrorAction SilentlyContinue
#}
#Add Staff Group and Add to Remote Desktop User
New-ADGroup -Name "SecOPS-Staff-Sec" -Path "OU=SOP-Groups,OU=SOP,OU=Staff Farms,$DomainID"  -SamAccountName "SecOPS-Staff-Sec" -GroupCategory Security -GroupScope Global -DisplayName "SecOPS-Staff-Sec" -Description "Contains Members of the Engineering Team" 
Add-ADGroupMember -Identity "Remote Desktop Users" -Members "SecOps-Staff-Sec"
#Add Security Adminis to the Fortigate VPN Acess Group
Add-ADGroupMember -Identity "FG_${FARMID}_SA_USERS" -members "SecOPS-Staff-Sec"


###############################################################################################################################################################
#                                                                                                                                                             #
#                  Run the top part first if this is an exisiting domain. Then move users and run the rest.                                                   #
############################################################################################################################################################### 
#New-ADUser -Name fg_ldap_auth_${FARMID} -Path "OU=FARM-ServiceAccounts,OU=Farm,$DomainID" -AccountPassword (ConvertTo-SecureString -AsPlainText "Q63Fd#6V1C!oJW2" -Force) -Enabled $true

#Add Farm Admins users
#add-ADGroupMember -Identity "FG_${FARMID}_FA_USERS"  -members "sjames-${FARMID}","ljackson-${FARMID}"

#Add Users
#New-ADUser -Name kmerrill-${FARMID} -Path "OU=ENG-Users,OU=ENG,OU=Staff Farms,$DomainID" -AccountPassword (ConvertTo-SecureString -AsPlainText "P@ssw0rd1234" -Force) -Enabled $true

#New-ADOrganizationalUnit -Name "NOC" -Path "OU=Staff Farms,$DomainID" -ProtectedFromAccidentalDeletion $true
#New-ADOrganizationalUnit -Name "NOC-Users" -Path "OU=NOC,OU=Staff Farms,$DomainID" -ProtectedFromAccidentalDeletion $true
#New-ADOrganizationalUnit -Name "NOC-Groups" -Path "OU=NOC,OU=Staff Farms,$DomainID" -ProtectedFromAccidentalDeletion $true
#New-ADOrganizationalUnit -Name "NOC-ServiceAccounts" -Path "OU=NOC,OU=Staff Farms,$DomainID" -ProtectedFromAccidentalDeletion $true
#New-ADOrganizationalUnit -Name "NOC-1" -Path "OU=NOC-Users,OU=NOC,OU=Staff Farms,$DomainID" -ProtectedFromAccidentalDeletion $true
#New-ADOrganizationalUnit -Name "NOC-2" -Path "OU=NOC-Users,OU=NOC,OU=Staff Farms,$DomainID" -ProtectedFromAccidentalDeletion $true
#New-ADOrganizationalUnit -Name "NOC-3" -Path "OU=NOC-Users,OU=NOC,OU=Staff Farms,$DomainID" -ProtectedFromAccidentalDeletion $true
#New-ADOrganizationalUnit -Name "NOC-Eng" -Path "OU=NOC-Users,OU=NOC,OU=Staff Farms,$DomainID" -ProtectedFromAccidentalDeletion $true
#New-ADOrganizationalUnit -Name "NOC-Staff" -Path "OU=NOC-Users,OU=Staff Farms,$DomainID" -ProtectedFromAccidentalDeletion $true

#New-ADOrganizationalUnit -Name "MON" -Path "OU=Staff Farms,$DomainID" -ProtectedFromAccidentalDeletion $true
#New-ADOrganizationalUnit -Name "MON-Users" -Path "OU=MON,OU=Staff Farms,$DomainID" -ProtectedFromAccidentalDeletion $true
#New-ADOrganizationalUnit -Name "MON-Groups" -Path "OU=MON,OU=Staff Farms,$DomainID" -ProtectedFromAccidentalDeletion $true
#New-ADOrganizationalUnit -Name "MON-ServiceAccounts" -Path "OU=MON,OU=Staff Farms,$DomainID" -ProtectedFromAccidentalDeletion $true

#New-ADOrganizationalUnit -Name "DEV" -Path "OU=Staff Farms,$DomainID" -ProtectedFromAccidentalDeletion $true
#New-ADOrganizationalUnit -Name "DEV-Users" -Path "OU=DEV,OU=Staff Farms,$DomainID" -ProtectedFromAccidentalDeletion $true
#New-ADOrganizationalUnit -Name "DEV-Groups" -Path "OU=DEV,OU=Staff Farms,$DomainID" -ProtectedFromAccidentalDeletion $true
#New-ADOrganizationalUnit -Name "DEV-ServiceAccounts" -Path "OU=DEV,OU=Staff Farms,$DomainID" -ProtectedFromAccidentalDeletion $true

#New-ADOrganizationalUnit -Name "ENG" -Path "OU=Staff Farms,$DomainID" -ProtectedFromAccidentalDeletion $true
#New-ADOrganizationalUnit -Name "ENG-Users" -Path "OU=ENG,OU=Staff Farms,$DomainID" -ProtectedFromAccidentalDeletion $true
#New-ADOrganizationalUnit -Name "ENG-Groups" -Path "OU=ENG,OU=Staff Farms,$DomainID" -ProtectedFromAccidentalDeletion $true
#New-ADOrganizationalUnit -Name "ENG-ServiceAccounts" -Path "OU=ENG,OU=Staff Farms,$DomainID" -ProtectedFromAccidentalDeletion $true



#Individual User Creation

$username= Read-host -Prompt 'Input the First Intial and Last Name'
$firstname= Read-host -Prompt 'Input the Users First Name'
$lastname= Read-host -Prompt 'Input the Users Last Name'

$DomainID= 'DC=DOMAIN,DC=LOCAL'
$fARMID = 'DOMAIN'

New-ADUser -GivenName $firstname -Surname $lastname -Name "$firstname $lastname" -SamAccountName $username-${FARMID} -UserPrincipalName $username-${FARMID}@${FARMID}.local -Path "OU=SOP-Users,OU=SOP,OU=Staff Farms,$DomainID" -AccountPassword (ConvertTo-SecureString -AsPlainText "P@ssw0rd1234" -Force) -Enabled $true

$SOPUsers = get-aduser -SearchBase "OU=SOP-Users,OU=SOP,OU=Staff Farms,$DomainID" -Filter *  | select SamAccountName
foreach($user in $SOPUsers)
{
  Add-ADGroupMember -Identity "SecOPS-Staff-Sec" -Members $user.samaccountname -ErrorAction SilentlyContinue
  Add-ADGroupMember -Identity "FG_${FARMID}_SA_USERS" -Members $user.samaccountname -ErrorAction SilentlyContinue
  Add-ADGroupMember -Identity "Remote Desktop Users" -Members "SecOps-Staff-Sec"
}
