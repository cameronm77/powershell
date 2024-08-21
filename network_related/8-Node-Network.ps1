g###################################################################
#                      8NODE SETTINGS                             #
###################################################################

#Rename NetAdapters
Rename-NetAdapter -name "JOE" -NewName "Left100GbE" or "Right100GbE"

#Create VMSwitch TEam to tie in left and right
Set-VMSwitchTeam -name "100GbETeam"

#Create the Main VMSwitch


New-VMSwitch -name "100 GbE Connection" -netAdaptorName "100GbETeam"

#VLAN Port Adapters
#on the 4NODE the VLAN ids are HOSTMGNT:210,EZDPM-BACKUP:219,HC-StorageSync:211
#on the 8NODE the VLAN ids are HOSTMGNT:220,EZDPM-BACKUP:229,HC-StorageSync:221

Add-VMNetworkAdapter -SwitchName "100 GbE Connection" -Name HostMgnt -ManagementOS
Set-VMNetworkAdapterVlan -VMNetworkAdapterName "HostMgnt" -ManagementOS -Access -VlanId 220


Add-VMNetworkAdapter -SwitchName "100 GbE Connection" -Name EZDPM-Backup -ManagementOS
Set-VMNetworkAdapterVlan -VMNetworkAdapterName "EZDPM-Backup" -ManagementOS -Access -VlanId 229


Add-VMNetworkAdapter -SwitchName "100 GbE Connection" -Name HC-StorageSync -ManagementOS
Set-VMNetworkAdapterVlan -VMNetworkworkAdapterName "HC-StorageSync" -ManagementOS -Access -VlanId 221


#SET IP on the Virtual Adapters
#on the 4NODE  HOSTMGNT:172.20.10.X,EZDPM-BACKUP:192.168.19.x,HC-StorageSync:192.168.11.x
#on the 8NODE  HOSTMGNT:172.20.20.X,EZDPM-BACKUP:192.168.29.x,HC-StorageSync:192.168.21.x


#All Guest VMS will need to point to 100 GbE Connection
