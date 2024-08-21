## Add AD Subnets to sites and services ##
## Add Reverse lookup zones to DNS AD intergrated on Domain ##


#Add-DnsServerPrimaryZone -ComputerName "<Computer Name>" -NetworkID "172.17.194/24" -ReplicationScope Domain
#New-ADReplicationSubnet -name "172.17.192.0/24" -Site "Default-First-Site-Name"
