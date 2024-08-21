
<#
.Synopsis
   Search, Remove and Repalce Inffiles
.DESCRIPTION
   Search for a network device and delete or replace the inf used by the device.
.EXAMPLE
   Update-Driver.ps1 -search Ethernet -ReplacePath C:\Drivers\Network\Driver.inf
.EXAMPLE
   Update-Driver.ps1 -search Ethernet -ReplacePath C:\Drivers\Network\*.inf
#>

Param(
 [Parameter(Mandatory=$true)]
 $Search,

 [Parameter()]
 $ReplacePath,

 [Parameter()]
 [Switch]$Delete
)
#Get current wokring paths
$CurrentDirectory = split-path $MyInvocation.MyCommand.Path
$ScriptName = $MyInvocation.MyCommand.Name

#Verify OS
If ([environment]::Is64BitOperatingSystem -eq $True) {
  $DevCon = "x64\devcon.exe"
  $PNPUtil = "C:\Windows\sysnative\pnputil.exe"
}
Else { 
  $DevCon = "x86\devcon.exe"
  $PnPUtil = "C:\Windows\System32\pnputil.exe"
}

Write-Host "Current Path: $CurrentDirectory"
Write-Host "Current Scriptname: $ScriptName"

#Verify DevCon exsits
If (!(Test-path "$CurrentDirectory\$DevCon")) {
  Write-Warning "Missing $DevCon, cannot continue"
  Exit $LASTEXITCODE
}


#Get inf Name
$Adapter = Get-WmiObject -Class win32_networkadapter | where { $_.name -like "*$Search*" }
If (!$Adapter) {
  Write-Warning "No Adapter found matching searchcriteria"
  Exit "666"
}
ElseIf ($Adapter.Count -ge "1") {
  Write-Warning "More than one adapter found cannot continue"
  Exit "666"
}

$AdapterName = $Adapter.Name
$PnpID = $Adapter.PNPDeviceID -replace("&","*")
$PnpID = $PnpID.Substring(0,40) + "*"

$DriverFiles = cmd /c  "$CurrentDirectory\$DevCon driverfiles $PnpID"
$Path = Select-String -InputObject $DriverFiles -Pattern '.inf'
$InfName = (($Path.Line) -replace (".*Driver installed from ","")) -replace(".inf .*",".inf")
$InfName = $InfName.Split("\")
$InfName = $InfName[$($InfName.Count - 1)]

Write-Host ""
Write-Host "AdapterName: $AdapterName"
If (!$InfName) {
  Write-Host "No inf specified"
}
Else {
  Write-host "Inf FileName: $InfName"
}

IF ($Delete) {
  cmd/c "$PnPUtil -f -d $InfName"
}

If ($ReplacePath) {
  If ((Test-Path $ReplacePath)) {
    cmd /c "$PnPUtil -f -d $InfName"
    cmd /c "$PnPUtil -i -a $ReplacePath"
  }
  Else {
    Write-Warning "Path $ReplacePath not Found!"
    Exit "666"
  }
}nono
