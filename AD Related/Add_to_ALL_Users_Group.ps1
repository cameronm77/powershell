$groupname = "all_users"
$All_USERS = get-aduser -SearchBase "OU=Champaign,DC=pavlovmedia,DC=corp" -Filter *  | ? {$_.DistinguishedName -notlike "*OU=Contractors*"}  | select SamAccountName
foreach($user in $All_USERS)
{
  Add-ADGroupMember -Identity $groupname -Members $user.samaccountname -ErrorAction SilentlyContinue
}
$members = Get-ADGroupMember -Identity $groupname
foreach($member in $members)
{
  if($member.distinguishedName -notlike "*OU=DOMAIN,dc=DOMAIN,dc=corp*")
  {
    Remove-ADGroupMember -Identity $groupname -Member $member.samaccountname
  }
}
