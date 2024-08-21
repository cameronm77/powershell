if (-NOT (Test-Path "C:\Program Files\Laps\CSE"))
{
	
	((Write-Host "LAPS Directory not found, creating C:\Program Files\LAPS directory structure"))
	New-Item -itemtype directory -force -Path "C:\Program Files\LAPS\CSE"
	(Copy-Item "\\ComputerName\e$\WDS\Applications\LAPS\AdmPwd.dll" -Destination "C:\program files\LAPS\CSE\")
	((Set-Location "c:\program files\laps\cse\"))
	((regsvr32.exe admpwd.dll /s))
	
	
	
}
