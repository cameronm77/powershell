# Setting up 2019 HV Server Core
#
#
#Add HV Tools
Install-WindowsFeature RSAT-Role-Tools -IncludeAllSubFeature
Install-WindowsFeature Failover-Clustering
Install-WindowsFeature RSAT-Clustering -IncludeManagementTools -IncludeAllSubFeature
#Add-WindowsCapability -Online -Name ServerCore.AppCompatibility~~~~0.0.1.0
$AdminGroupAdded="DOMAIN\(GROUP OR USER)"

#Setup the Local Groups in the Administrators Group
#net localgroup administrators "$AdminGroupAdded /add

#Get-ADComputer -LDapFilter "(name=*HV*)" -SearchBase "dc=DOMAIN,dc=corp" | Out-GridView
