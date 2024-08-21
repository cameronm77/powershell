#This is a PowerShell script to install software and configure settings for consistant deployment
#Created By Cameron
#Date Created 8/15/14
#Date Last Modified 8/20/14
#Revision .24


#Menu Choices
$menu = @"
[1] Location 1 
[2] Location 2
[3] Location 3
[q] Quit
Select a Location by number or Q to Quit
"@


Do {

#use a Switch construct to take action depending on what menu choice is selected.
Switch (Read-Host $menu "Location Selections") 
	{
		#Location 1 section
		"1" {
    	    Write-Host "Installing Location's Package" -ForegroundColor Yellow
        	$newName = Read-Host -Prompt "Enter New Computer Name"
			$domain = Read-Host -Prompt "Enter Domain Name"
			$user = Read-Host -Prompt "Enter Domain user name"
			$password = Read-Host -Prompt "Enter password for $user" -AsSecureString 
			$username = "DOMAIN\$user" 
			$credential = New-Object System.Management.Automation.PSCredential($username,$password) 
    		
    		#change directory to Root of C
    		cd \
    		
    		#Make a new folder called Dell
    		md dell
    		
    		#Add permissions of everyone full control on the dell folder 
    		cacls dell /e /p everyone:F
    		
    		#Mapping Z drive to Mars to copy files to the dell folder
    		New-PSDrive -Name Z -PSProvider FileSystem -Root "\\Server\MEDIA\Imaging\Pakage to Copy to Dell-W8" -Persist -Credential $credential
    
    		#xcopy files from network to local dell folder
    		xcopy "z:\" "c:\dell\" /e /y
    		
    		#copy user account pictures to appropriate locations
			Copy-Item "c:\dell\User Tile\ProgramData\Microsoft\User Account Pictures\LOCATION\*.*" "c:\programdata\Microsoft\User Account Pictures\" -Force

			#copy desktop and lockscreens to proper location
			Copy-Item c:\dell\desktop\LOCATION\* c:\dell -Force
            
			#copy group policy to local computer
            Copy-Item c:\dell\policy\*.* c:\windows\system32\grouppolicy\ -Force
			
            #copy xml files to Root for Start Menu 
			Copy-Item c:\dell\start-sm.xml c:\ -Force

			#coping wabbit reg to all startup
			Copy-Item c:\dell\wabbit.bat "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\StartUp\" -Force
            
			#copy app associations to C:
            Copy-Item c:\dell\AppAssoc.xml c:\ -Force

			#Remove shared drive
			Remove-PSDrive -Name Z -Force
			
			#Change directory back to the dell folder
			cd \dell
			
			#Installation of  programs
			
			#Java Install
			.\java.com /s
			
			#Chrome Install
			msiexec /q /i "c:\dell\chrome.msi" |out-null

			#Adobe Acrobat Install
			msiexec /i "c:\dell\reader\AcroRead.msi" TRANSFORMS="c:\dell\reader\AcroRead.mst" /qn |out-null

			#Adobe Flash install
			msiexec /i "c:\dell\flash.msi" REBOOT=ReallySuppress ALLUSERS=1 /qn |out-null
			
			#Adobe Flash config file to stop updates
            Copy-Item c:\dell\mms.cfg  c:\windows\system32\macromed\flash\ -Force |out-null
			
            #Adobe shockwave install
			msiexec /i "c:\dell\shockwave.msi" REBOOT=ReallySuppress AllUSERS=1 /qn |out-null

			#Apple Itunes and support applications install
			msiexec /i "c:\dell\AppleApplicationSupport.msi" /qn |out-null
			msiexec /i "C:\dellAppleMobileDeviceSupport.msi" /qn |out-null
			msiexec /i "C:\dell\Bonjour.msi" /qn |out-null
			msiexec /i "C:\dell\itunes.msi" /qn |out-null
			msiexec /i "C:\dell\quicktime.msi" /qn |out-null
			
			#Map netowrk drive to install certian software over network
			New-PSDrive -Name X -PSProvider FileSystem -Root "\\SERVER\MEDIA\Imaging\software" -Persist -Credential $credential

			#Change folder to network share
			x:
			#change folder to the cyberlink dvd software and install
			cd cyberpower
			.\setup.exe |out-null
			
			#change directory back to z
			cd ..
			
			#change directory to office install
			cd office
			.\setup.exe /adminfile x:\office\updates\office_custom.msp |out-null
    		
    		#Remove shared drive
			Remove-PSDrive -Name X -Force
    		
    		#change back to root of c
    		c:
    		
    		#change to dell folder
    		cd \dell
    		
    		#Delete existing shortcuts on public desktop
			Remove-Item c:\users\public\desktop\*.lnk  -Force -Recurse

			#Copying new Shortcuts to desktop
			Copy-Item  c:\dell\*.url  c:\users\public\desktop\  -Force 
 			Copy-Item  c:\dell\*.lnk  c:\users\public\desktop\  -Force 

			#Importing registry settings

			#Changes the start tile to premade arrangement
			regedit /S "C:\dell\User Tile\tile.reg"
			
			#Disable java updates
			regedit /S "C:\dell\java.reg"

			#configure wabbit virtual calculator 
			regedit /S "C:\dell\wabbit.reg"

			#set the starttiles to use new layout
			regedit /S "C:\dell\starttiles.reg"

			#disables windows firstrun on login
			regedit /S "C:\dell\disablefirstrun.reg"
			
			#turns off UAC to never notify
			regedit /S "C:\dell\UAC_Never_Notify.reg"
			
			#imports cleanmgr settings 
			regedit /S "C:\dell\cleanmgr.reg"

			#changes lock screen picture 
			regedit /S "C:\dell\lock.jpg"

			#force group policy update
			gpupdate /force
    		
    		#remove DEP for compatibility issues
			bcdedit.exe /set '{current}' nx AlwaysOff

			#Activate Windows
			cscript //B c:\windows\system32\slmgr.vbs -ipk CD_KEY_GOES_HERE

			#Activate Office
			cscript //B c:\windows\system32\slmgr.vbs -ipk CD_KEY_GOES_HERE /ato

			#Install .net 3.5 on system
			DISM.exe /Online /Enable-Feature /FeatureName:NetFx3 /All 

			#Import App Associations
			Dism.exe /Online /Import-DefaultAppAssociations:c:\AppAssoc.xml

			#Run disk clean up to remove unneeded files
			cleanmgr.exe /sagerun:1 |out-null

			#Runs a service pack and update ackup file removal and cleans up Windows
			Dism.exe /online /Cleanup-Image /StartComponentCleanup /ResetBase

			#deletes sysprep answer files
            Remove-Item -LiteralPath c:\windows\system32\sysprep\unattend.xml -Force

            Remove-Item -LiteralPath c:\windows\panther\unattend.xml -Force
			
            #Imports start screen layout
			Copy-Item c:\dell\start-sm.bin c:\
			cd \
			Import-StartLayout -LayoutPath start-sm.bin -MountPath c:

			#Renames Computer to specified name and joins domain
			Add-Computer -DomainName DOMAIN.local -NewName "$newName" -Credential $credential

			#Disable Certain Services not needed 
			sc.exe config AdobeARMservice start= disabled
			sc.exe config AdobeFlashPlayerUpdateSvc start= disabled
			sc.exe config gupdate start= disabled
			sc.exe config gupdatem start= disabled

			#Copy master preference file for chrome
			Copy-Item c:\dell\master_preferences "C:\Program Files\Google\Chrome\Application\"

			#Install Deepfreeze
			cd \dell
			msiexec /i dfmedia.msi /qn |out-null
    		
    		}
    	
    	#Location 2 section	
		"2" {
    	    Write-Host "Installing Location's Package" -ForegroundColor Yellow
        	$newName = Read-Host -Prompt "Enter New Computer Name"
			$domain = Read-Host -Prompt "Enter Domain Name"
			$user = Read-Host -Prompt "Enter Domain user name"
			$password = Read-Host -Prompt "Enter password for $user" -AsSecureString 
			$username = "DOMAIN\$user" 
			$credential = New-Object System.Management.Automation.PSCredential($username,$password) 
    		
    		#change directory to Root of C
    		cd \
    		
    		#Make a new folder called Dell
    		md dell
    		
    		#Add permissions of everyone full control on the dell folder 
    		cacls dell /e /p everyone:F
    		
    		#Mapping Z drive to Mars to copy files to the dell folder
    		New-PSDrive -Name Z -PSProvider FileSystem -Root "\\Server\MEDIA\Imaging\Pakage to Copy to Dell-W8" -Persist -Credential $credential
    
    		#xcopy files from network to local dell folder
    		xcopy "z:\" "c:\dell\" /e /y
    		
    		#copy user account pictures to appropriate locations
			Copy-Item "c:\dell\User Tile\ProgramData\Microsoft\User Account Pictures\LOCATION\*.*" "c:\programdata\Microsoft\User Account Pictures\" -Force

			#copy desktop and lockscreens to proper location
			Copy-Item c:\dell\desktop\LOCATION\* c:\dell -Force
            
			#copy group policy to local computer
            Copy-Item c:\dell\policy\*.* c:\windows\system32\grouppolicy\ -Force
			
            #copy xml files to Root for Start Menu 
			Copy-Item c:\dell\start-sm.xml c:\ -Force

			#coping wabbit reg to all startup
			Copy-Item c:\dell\wabbit.bat "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\StartUp\" -Force
            
			#copy app associations to C:
            Copy-Item c:\dell\AppAssoc.xml c:\ -Force

			#Remove shared drive
			Remove-PSDrive -Name Z -Force
			
			#Change directory back to the dell folder
			cd \dell
			
			#Installation of  programs
			
			#Java Install
			.\java.com /s
			
			#Chrome Install
			msiexec /q /i "c:\dell\chrome.msi" |out-null

			#Adobe Acrobat Install
			msiexec /i "c:\dell\reader\AcroRead.msi" TRANSFORMS="c:\dell\reader\AcroRead.mst" /qn |out-null

			#Adobe Flash install
			msiexec /i "c:\dell\flash.msi" REBOOT=ReallySuppress ALLUSERS=1 /qn |out-null
			
			#Adobe Flash config file to stop updates
            Copy-Item c:\dell\mms.cfg  c:\windows\system32\macromed\flash\ -Force |out-null
			
            #Adobe shockwave install
			msiexec /i "c:\dell\shockwave.msi" REBOOT=ReallySuppress AllUSERS=1 /qn |out-null

			#Apple Itunes and support applications install
			msiexec /i "c:\dell\AppleApplicationSupport.msi" /qn |out-null
			msiexec /i "C:\dellAppleMobileDeviceSupport.msi" /qn |out-null
			msiexec /i "C:\dell\Bonjour.msi" /qn |out-null
			msiexec /i "C:\dell\itunes.msi" /qn |out-null
			msiexec /i "C:\dell\quicktime.msi" /qn |out-null
			
			#Map netowrk drive to install certian software over network
			New-PSDrive -Name X -PSProvider FileSystem -Root "\\SERVER\MEDIA\Imaging\software" -Persist -Credential $credential

			#Change folder to network share
			x:
			#change folder to the cyberlink dvd software and install
			cd cyberpower
			.\setup.exe |out-null
			
			#change directory back to z
			cd ..
			
			#change directory to office install
			cd office
			.\setup.exe /adminfile x:\office\updates\office_custom.msp |out-null
    		
    		#Remove shared drive
			Remove-PSDrive -Name X -Force
    		
    		#change back to root of c
    		c:
    		
    		#change to dell folder
    		cd \dell
    		
    		#Delete existing shortcuts on public desktop
			Remove-Item c:\users\public\desktop\*.lnk  -Force -Recurse

			#Copying new Shortcuts to desktop
			Copy-Item  c:\dell\*.url  c:\users\public\desktop\  -Force 
 			Copy-Item  c:\dell\*.lnk  c:\users\public\desktop\  -Force 

			#Importing registry settings

			#Changes the start tile to premade arrangement
			regedit /S "C:\dell\User Tile\tile.reg"
			
			#Disable java updates
			regedit /S "C:\dell\java.reg"

			#configure wabbit virtual calculator 
			regedit /S "C:\dell\wabbit.reg"

			#set the starttiles to use new layout
			regedit /S "C:\dell\starttiles.reg"

			#disables windows firstrun on login
			regedit /S "C:\dell\disablefirstrun.reg"
			
			#turns off UAC to never notify
			regedit /S "C:\dell\UAC_Never_Notify.reg"
			
			#imports cleanmgr settings 
			regedit /S "C:\dell\cleanmgr.reg"

			#changes lock screen picture 
			regedit /S "C:\dell\lock.jpg"

			#force group policy update
			gpupdate /force
    		
    		#remove DEP for compatibility issues
			bcdedit.exe /set '{current}' nx AlwaysOff

			#Activate Windows
			cscript //B c:\windows\system32\slmgr.vbs -ipk CD_KEY_GOES_HERE

			#Activate Office
			cscript //B c:\windows\system32\slmgr.vbs -ipk CD_KEY_GOES_HERE /ato

			#Install .net 3.5 on system
			DISM.exe /Online /Enable-Feature /FeatureName:NetFx3 /All 

			#Import App Associations
			Dism.exe /Online /Import-DefaultAppAssociations:c:\AppAssoc.xml

			#Run disk clean up to remove unneeded files
			cleanmgr.exe /sagerun:1 |out-null

			#Runs a service pack and update ackup file removal and cleans up Windows
			Dism.exe /online /Cleanup-Image /StartComponentCleanup /ResetBase

			#deletes sysprep answer files
            Remove-Item -LiteralPath c:\windows\system32\sysprep\unattend.xml -Force

            Remove-Item -LiteralPath c:\windows\panther\unattend.xml -Force
			
            #Imports start screen layout
			Copy-Item c:\dell\start-sm.bin c:\
			cd \
			Import-StartLayout -LayoutPath start-sm.bin -MountPath c:

			#Renames Computer to specified name and joins domain
			Add-Computer -DomainName DOMAIN.local -NewName "$newName" -Credential $credential

			#Disable Certain Services not needed 
			sc.exe config AdobeARMservice start= disabled
			sc.exe config AdobeFlashPlayerUpdateSvc start= disabled
			sc.exe config gupdate start= disabled
			sc.exe config gupdatem start= disabled

			#Copy master preference file for chrome
			Copy-Item c:\dell\master_preferences "C:\Program Files\Google\Chrome\Application\"

			#Install Deepfreeze
			cd \dell
			msiexec /i dfmedia.msi /qn |out-null
    		
    		}
    	
    	
    	#Location 3 Section	
		"3" {
    	    Write-Host "Installing Location's Package" -ForegroundColor Yellow
        	$newName = Read-Host -Prompt "Enter New Computer Name"
			$domain = Read-Host -Prompt "Enter Domain Name"
			$user = Read-Host -Prompt "Enter Domain user name"
			$password = Read-Host -Prompt "Enter password for $user" -AsSecureString 
			$username = "DOMAIN\$user" 
			$credential = New-Object System.Management.Automation.PSCredential($username,$password) 
    		
    		#change directory to Root of C
    		cd \
    		
    		#Make a new folder called Dell
    		md dell
    		
    		#Add permissions of everyone full control on the dell folder 
    		cacls dell /e /p everyone:F
    		
    		#Mapping Z drive to Mars to copy files to the dell folder
    		New-PSDrive -Name Z -PSProvider FileSystem -Root "\\Server\MEDIA\Imaging\Pakage to Copy to Dell-W8" -Persist -Credential $credential
    
    		#xcopy files from network to local dell folder
    		xcopy "z:\" "c:\dell\" /e /y
    		
    		#copy user account pictures to appropriate locations
			Copy-Item "c:\dell\User Tile\ProgramData\Microsoft\User Account Pictures\LOCATION\*.*" "c:\programdata\Microsoft\User Account Pictures\" -Force

			#copy desktop and lockscreens to proper location
			Copy-Item c:\dell\desktop\LOCATION\* c:\dell -Force
            
			#copy group policy to local computer
            Copy-Item c:\dell\policy\*.* c:\windows\system32\grouppolicy\ -Force
			
            #copy xml files to Root for Start Menu 
			Copy-Item c:\dell\start-sm.xml c:\ -Force

			#coping wabbit reg to all startup
			Copy-Item c:\dell\wabbit.bat "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\StartUp\" -Force
            
			#copy app associations to C:
            Copy-Item c:\dell\AppAssoc.xml c:\ -Force

			#Remove shared drive
			Remove-PSDrive -Name Z -Force
			
			#Change directory back to the dell folder
			cd \dell
			
			#Installation of  programs
			
			#Java Install
			.\java.com /s
			
			#Chrome Install
			msiexec /q /i "c:\dell\chrome.msi" |out-null

			#Adobe Acrobat Install
			msiexec /i "c:\dell\reader\AcroRead.msi" TRANSFORMS="c:\dell\reader\AcroRead.mst" /qn |out-null

			#Adobe Flash install
			msiexec /i "c:\dell\flash.msi" REBOOT=ReallySuppress ALLUSERS=1 /qn |out-null
			
			#Adobe Flash config file to stop updates
            Copy-Item c:\dell\mms.cfg  c:\windows\system32\macromed\flash\ -Force |out-null
			
            #Adobe shockwave install
			msiexec /i "c:\dell\shockwave.msi" REBOOT=ReallySuppress AllUSERS=1 /qn |out-null

			#Apple Itunes and support applications install
			msiexec /i "c:\dell\AppleApplicationSupport.msi" /qn |out-null
			msiexec /i "C:\dellAppleMobileDeviceSupport.msi" /qn |out-null
			msiexec /i "C:\dell\Bonjour.msi" /qn |out-null
			msiexec /i "C:\dell\itunes.msi" /qn |out-null
			msiexec /i "C:\dell\quicktime.msi" /qn |out-null
			
			#Map netowrk drive to install certian software over network
			New-PSDrive -Name X -PSProvider FileSystem -Root "\\SERVER\MEDIA\Imaging\software" -Persist -Credential $credential

			#Change folder to network share
			x:
			#change folder to the cyberlink dvd software and install
			cd cyberpower
			.\setup.exe |out-null
			
			#change directory back to z
			cd ..
			
			#change directory to office install
			cd office
			.\setup.exe /adminfile x:\office\updates\office_custom.msp |out-null
    		
    		#Remove shared drive
			Remove-PSDrive -Name X -Force
    		
    		#change back to root of c
    		c:
    		
    		#change to dell folder
    		cd \dell
    		
    		#Delete existing shortcuts on public desktop
			Remove-Item c:\users\public\desktop\*.lnk  -Force -Recurse

			#Copying new Shortcuts to desktop
			Copy-Item  c:\dell\*.url  c:\users\public\desktop\  -Force 
 			Copy-Item  c:\dell\*.lnk  c:\users\public\desktop\  -Force 

			#Importing registry settings

			#Changes the start tile to premade arrangement
			regedit /S "C:\dell\User Tile\tile.reg"
			
			#Disable java updates
			regedit /S "C:\dell\java.reg"

			#configure wabbit virtual calculator 
			regedit /S "C:\dell\wabbit.reg"

			#set the starttiles to use new layout
			regedit /S "C:\dell\starttiles.reg"

			#disables windows firstrun on login
			regedit /S "C:\dell\disablefirstrun.reg"
			
			#turns off UAC to never notify
			regedit /S "C:\dell\UAC_Never_Notify.reg"
			
			#imports cleanmgr settings 
			regedit /S "C:\dell\cleanmgr.reg"

			#changes lock screen picture 
			regedit /S "C:\dell\lock.jpg"

			#force group policy update
			gpupdate /force
    		
    		#remove DEP for compatibility issues
			bcdedit.exe /set '{current}' nx AlwaysOff

			#Activate Windows
			cscript //B c:\windows\system32\slmgr.vbs -ipk CD_KEY_GOES_HERE

			#Activate Office
			cscript //B c:\windows\system32\slmgr.vbs -ipk CD_KEY_GOES_HERE /ato

			#Install .net 3.5 on system
			DISM.exe /Online /Enable-Feature /FeatureName:NetFx3 /All 

			#Import App Associations
			Dism.exe /Online /Import-DefaultAppAssociations:c:\AppAssoc.xml

			#Run disk clean up to remove unneeded files
			cleanmgr.exe /sagerun:1 |out-null

			#Runs a service pack and update ackup file removal and cleans up Windows
			Dism.exe /online /Cleanup-Image /StartComponentCleanup /ResetBase

			#deletes sysprep answer files
            Remove-Item -LiteralPath c:\windows\system32\sysprep\unattend.xml -Force

            Remove-Item -LiteralPath c:\windows\panther\unattend.xml -Force
			
            #Imports start screen layout
			Copy-Item c:\dell\start-sm.bin c:\
			cd \
			Import-StartLayout -LayoutPath start-sm.bin -MountPath c:

			#Renames Computer to specified name and joins domain
			Add-Computer -DomainName DOMAIN.local -NewName "$newName" -Credential $credential

			#Disable Certain Services not needed 
			sc.exe config AdobeARMservice start= disabled
			sc.exe config AdobeFlashPlayerUpdateSvc start= disabled
			sc.exe config gupdate start= disabled
			sc.exe config gupdatem start= disabled

			#Copy master preference file for chrome
			Copy-Item c:\dell\master_preferences "C:\Program Files\Google\Chrome\Application\"

			#Install Deepfreeze
			cd \dell
			msiexec /i dfmedia.msi /qn |out-null
    		
    		}
    	
		
		#Exit program
		"Q" {Write-Host "Goodbye" -ForegroundColor Cyan
			Return
			}
		
		#Error if not selecting proper menu choice
		Default {Write-Warning "Invalid Choice. Try again."}
	
	} #switch

} While ($True)


