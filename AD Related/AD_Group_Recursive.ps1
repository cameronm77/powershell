#Need this to pull the names of the groups then pass the recursive look on to output to excel




param([Parameter(Mandatory = $true)][String]$groupname)

 

$groupsHT = @{} # This is our group cache 
$membersHT = @{} 
#$groupname = @{} 
 #foreach($group in $Groups){
       #Get-ADGroup -Filter * | Select CN,SamAccountName,DistinguishedName
       #$groups.Add($groupname)
       
       #}

function groupShouldNotBeResolved {     
    param($member)     
 
    $groupsToNotResolve = @( # These are CNs! Make sure that your sAMAccountNames and CNs match!         
    "Domain Users" # Feel free to edit these!         
    "SomeGroup"     
    )     
    foreach($group in $groupsToNotResolve) { # We iterate through our list of groups...         
        if($member.StartsWith(("CN=" + $group + ","), "CurrentCultureIgnoreCase") -eq $true) { # ...and check if our member matches             
            $groupToNotResolveAD = Get-ADObject -Identity $member # If we find a match, we get it from AD             
            $groupsHT.Add($member, $groupToNotResolveAD) # And add it to our list of groups, so we know it next time             
            return $true # Let caller know this group should not be resolved         
        }     
    }     
    return $false # This group should be resolved! 
} 
 
function resolve-members-recursive {     
    param($members) # The input is a list of members (distinguishedNames)     
    
    foreach($member in $members) { # We look at each member / distinguishedName         
        if($membersHT.Contains($member) -eq $true) { # If the distinguishedName is already in our list of members, we skip it             
            continue         
        }         
        elseif((groupShouldNotBeResolved $member) -eq $true) { # If the member is a group that should not be resolved....             
            $membersHT.Add($member, $groupsHT.$member) # We add it to our members list         
        }         
        elseif($groupsHT.Contains($member) -eq $true) { # If the distinguishedName is already in our group cache...             
            resolve-members-recursive $groupsHT.$member # Resolve its members recursively!         
        }         
        else { # If the distinguishedName is in neither cache, we find out what it is...             
            $memberAD = Get-ADObject -Identity $member -Properties member # ... from AD!             
            if($memberAD.objectClass -eq "group") { # If it's a group...                 
                $groupsHT.Add($memberAD.distinguishedName, $memberAD.member) # We add it to our group cache                 
                resolve-members-recursive $groupsHT.$member # And resolve its members recursively             
            }             
            else { # If it's not a group, it must be a user...                 
                $membersHT.Add($member, $memberAD) # So we add it to our members list             
            }         
        }     
    } 
} 
 
$groupToResolve = Get-ADObject -LDAPFilter ("(&(objectClass=group)(objectCategory=group)(sAMAccountName=" + $groupName + "))") -Properties member 
if($groupToResolve -eq $null) {     
    Write-Host ($groupname + " could not be found in AD!")     
    return $null 
} 
else {     
    resolve-members-recursive $groupToResolve.member     
    return $membersHT 
} 
Export-csv C:\POWERSHELL\ADGroups2.csv # These are our members
