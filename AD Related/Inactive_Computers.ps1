$DaysInactive = 60
$time = (Get-Date).Adddays(-($DaysInactive))
Get-ADComputer -Filter {lastlogontimestamp -lt $time}  -Properties Name,OperatingSystem , lastlogontimestamp| Select Name,OperatingSystem ,@{N='lastlogontimestamp'; E={[DateTime]::FromFileTime($_.lastlogontimestamp)}} | export-csv -NoTypeInformation d:\inactivesystems.csv
