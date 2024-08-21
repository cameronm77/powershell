Rename-NetAdapter -name "Ethernet 2"

Remove-VMSwitch -name "HostVlan"

New-VMSwitch -Name HostVlan -NetAdapterName "21","22" -AllowManagementOS $true -EnableEmbeddedTeaming $true       
Set-vmswitchteam -Name "HostVlan" -loadbalancingalgorithm Dynamic


##you should be able to use set-vmswitch -name HostVlan -netadaptername ".21",".22"  

## hopefully that makes sense.     Ip address for HostVlan
##is 192.168.21.2X/24 (X is the node number)  (you can double check the HostVlan IP on 6 to make sure it is a .21.2X/24 )   No GW   
