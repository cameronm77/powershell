<# 
script name: GetServerInfoAndCpuCount.ps1
 
Writes SQL Server name, version, edition, Service Pack level, CU level, version number, number of sockets, number of 
cores per socket and number of cores from a list of SQL Servers specified in a file to a .csv file.
#>
 
$workdir = 'C:\scripts\GetServerInfoAndCpuCount' # change if you're using a directory other than C:\scripts\GetCpuCount
$outfile = 'ServerInfoAndCpuCount.csv'           # output file name
$servers = '.\servers.txt'                       # list of your SQL Servers
 
$EmailOn = 'n'                                   # y to email logs (case insensitive)
 
# $Email variables must be populated if $EmailOn = 'y'  
$PSEmailServer = 'smtp.mymailserver.com'  # mail server 
$EmailFrom = 'mailfrom@ mymailserver.com' # mail from - must be populated with properly formatted (name@domain.ext) but doesn't have to be real 
$EmailTo = 'mailfrom@ mymailserver.com '  # mail to
$EmailSubject = 'ServerInfoAndCpuCount'   # mail subject
 
Set-Location $workdir
$sqlservers = Get-Content $servers | Sort-Object # read in and sort to order output 
 
# sql query
$sql = "
DECLARE @ProductVersion NVARCHAR(30)
 
SET @ProductVersion = CONVERT(NVARCHAR(20),SERVERPROPERTY('ProductVersion')) 
 
SELECT @ProductVersion = 
      CASE SUBSTRING(@ProductVersion,1,4)
         WHEN '15.0' THEN 'SQL Server 2019'
         WHEN '14.0' THEN 'SQL Server 2017' 
         WHEN '13.0' THEN 'SQL Server 2016' 
         WHEN '12.0' THEN 'SQL Server 2014' 
         WHEN '11.0' THEN 'SQL Server 2012' 
         WHEN '10.5' THEN 'SQL Server 2008 R2' 
         WHEN '10.0' THEN 'SQL Server 2008'  
      END
 
SELECT @@SERVERNAME AS SQLServerName, 
       @ProductVersion AS ProductVersion,
       SERVERPROPERTY('Edition') AS Edition,
       SERVERPROPERTY('ProductLevel') AS ProductLevel,
       SERVERPROPERTY('ProductUpdateLevel') AS ProductUpdateLevel,
       SERVERPROPERTY('ProductVersion') AS Version,
       cpu_count/hyperthread_ratio AS [Sockets], 
       hyperthread_ratio AS [CoresPerSocket], 
       cpu_count AS [Cores] 
FROM sys.dm_os_sys_info
GO
"
 
# delete old output file if it exists
If (Test-Path $outfile){Remove-Item $outfile}
 
# gather info from each server in file and export to .csv
Foreach ($ss in $sqlservers) 
{
   Invoke-Sqlcmd -ServerInstance $ss -Query $sql | Export-Csv $outfile -NoTypeInformation -Append
}
 
# email $outfile
If ($EmailOn -eq 'y') 
{
   Send-MailMessage -From "$EmailFrom" -To "$EmailTo" -Subject "$EmailSubject" -Attachments "$outfile"
}
