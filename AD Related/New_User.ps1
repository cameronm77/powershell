
function New-SWRandomPassword {
    <#
    .Synopsis
       Generates one or more complex passwords designed to fulfill the requirements for Active Directory
    .DESCRIPTION
       Generates one or more complex passwords designed to fulfill the requirements for Active Directory
    .EXAMPLE
       New-SWRandomPassword
       C&3SX6Kn

       Will generate one password with a length between 8  and 12 chars.
    .EXAMPLE
       New-SWRandomPassword -MinPasswordLength 8 -MaxPasswordLength 12 -Count 4
       7d&5cnaB
       !Bh776T"Fw
       9"C"RxKcY
       %mtM7#9LQ9h

       Will generate four passwords, each with a length of between 8 and 12 chars.
    .EXAMPLE
       New-SWRandomPassword -InputStrings abc, ABC, 123 -PasswordLength 4
       3ABa

       Generates a password with a length of 4 containing atleast one char from each InputString
    .EXAMPLE
       New-SWRandomPassword -InputStrings abc, ABC, 123 -PasswordLength 4 -FirstChar abcdefghijkmnpqrstuvwxyzABCEFGHJKLMNPQRSTUVWXYZ
       3ABa

       Generates a password with a length of 4 containing atleast one char from each InputString that will start with a letter from 
       the string specified with the parameter FirstChar
    .OUTPUTS
       [String]
    .NOTES
       Written by Simon Wåhlin, blog.simonw.se
       I take no responsibility for any issues caused by this script.
    .FUNCTIONALITY
       Generates random passwords
    .LINK
       http://blog.simonw.se/powershell-generating-random-password-for-active-directory/
   
    #>
    [CmdletBinding(DefaultParameterSetName='FixedLength',ConfirmImpact='None')]
    [OutputType([String])]
    Param
    (
        # Specifies minimum password length
        [Parameter(Mandatory=$false,
                   ParameterSetName='RandomLength')]
        [ValidateScript({$_ -gt 0})]
        [Alias('Min')] 
        [int]$MinPasswordLength = 8,
        
        # Specifies maximum password length
        [Parameter(Mandatory=$false,
                   ParameterSetName='RandomLength')]
        [ValidateScript({
                if($_ -ge $MinPasswordLength){$true}
                else{Throw 'Max value cannot be lesser than min value.'}})]
        [Alias('Max')]
        [int]$MaxPasswordLength = 12,

        # Specifies a fixed password length
        [Parameter(Mandatory=$false,
                   ParameterSetName='FixedLength')]
        [ValidateRange(1,2147483647)]
        [int]$PasswordLength = 8,
        
        # Specifies an array of strings containing charactergroups from which the password will be generated.
        # At least one char from each group (string) will be used.
        [String[]]$InputStrings = @('abcdefghijkmnpqrstuvwxyz', 'ABCEFGHJKLMNPQRSTUVWXYZ', '23456789', '!"#%&'),

        # Specifies a string containing a character group from which the first character in the password will be generated.
        # Useful for systems which requires first char in password to be alphabetic.
        [String] $FirstChar,
        
        # Specifies number of passwords to generate.
        [ValidateRange(1,2147483647)]
        [int]$Count = 1
    )
    Begin {
        Function Get-Seed{
            # Generate a seed for randomization
            $RandomBytes = New-Object -TypeName 'System.Byte[]' 4
            $Random = New-Object -TypeName 'System.Security.Cryptography.RNGCryptoServiceProvider'
            $Random.GetBytes($RandomBytes)
            [BitConverter]::ToUInt32($RandomBytes, 0)
        }
    }
    Process {
        For($iteration = 1;$iteration -le $Count; $iteration++){
            $Password = @{}
            # Create char arrays containing groups of possible chars
            [char[][]]$CharGroups = $InputStrings

            # Create char array containing all chars
            $AllChars = $CharGroups | ForEach-Object {[Char[]]$_}

            # Set password length
            if($PSCmdlet.ParameterSetName -eq 'RandomLength')
            {
                if($MinPasswordLength -eq $MaxPasswordLength) {
                    # If password length is set, use set length
                    $PasswordLength = $MinPasswordLength
                }
                else {
                    # Otherwise randomize password length
                    $PasswordLength = ((Get-Seed) % ($MaxPasswordLength + 1 - $MinPasswordLength)) + $MinPasswordLength
                }
            }

            # If FirstChar is defined, randomize first char in password from that string.
            if($PSBoundParameters.ContainsKey('FirstChar')){
                $Password.Add(0,$FirstChar[((Get-Seed) % $FirstChar.Length)])
            }
            # Randomize one char from each group
            Foreach($Group in $CharGroups) {
                if($Password.Count -lt $PasswordLength) {
                    $Index = Get-Seed
                    While ($Password.ContainsKey($Index)){
                        $Index = Get-Seed                        
                    }
                    $Password.Add($Index,$Group[((Get-Seed) % $Group.Count)])
                }
            }

            # Fill out with chars from $AllChars
            for($i=$Password.Count;$i -lt $PasswordLength;$i++) {
                $Index = Get-Seed
                While ($Password.ContainsKey($Index)){
                    $Index = Get-Seed                        
                }
                $Password.Add($Index,$AllChars[((Get-Seed) % $AllChars.Count)])
            }
            Write-Output -InputObject $(-join ($Password.GetEnumerator() | Sort-Object -Property Name | Select-Object -ExpandProperty Value))
        }
    }
}

Function Convert-ToFriendlyName{param ($Text)
    $SpecChars = '!', '"', '£', '$', '%', '&', '^', '*', '(', ')', '@', '=', '+', '¬', '`', '\', '<', '>', '.', '?', '/', ':', ';', '#', '~', "'", '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '-', ' '
    $remspecchars = [string]::join('|', ($SpecChars | % {[regex]::escape($_)}))
    $name = (Get-Culture).textinfo.totitlecase(“$Text”.tolower())
    $name = $name -replace $remspecchars, ""
    $name
}
##########################################################################################
#                                                                                        #
#   Phase 01 - Set Variables                                                             #
#                                                                                        #
#   01. Get Admin credentials                                                            #
#   02. Set arrays to map departments to OU's and template accounts                      #
#   03. Load function to clean spaces and punctuation from strings                       #
#   04. Get users first name                                                             #
#   05. Get users last name                                                              #
#   06. Set display name to first + last name                                            #
#   07. Set AD username from first and last name                                         #
#   08. Change AD username to lowercase                                                  #
#   09. Set email address                                                                #
#   10. Get job title                                                                    #
#   11. Display department array to receive numerical input to map correctly to arrays   #
#   12. Get user's manager AD account                                                    #
#   13. Set manager email address                                                        #
#   14. Get CRM/Intellibid access variables                                              #
#   15. Set template object to copy AD info from                                         #
#   16. Set distinguished name                                                           #
#   17. Set password                                                                     #
#   18. Continue to Phase 02                                                             #
#                                                                                        #
##########################################################################################

$objAdminCred = Get-Credential
$arrDepartments = @("Accounting", 
                   #Add More Departments 
                    ")
$arrDepartmentsNum = @("1 - Accounting and Finance", 
                    #Add More Departments
                       "")
$arrDeptTemplates = @("_Accounting_Template", 
                    # Add More Department Templates
                    "")
$arrPathLocation = @("OU=OU,OU=OU,OU=OU,DC=DOMAIN,DC=corp", 
                   #Add All other OU's for arr'
                   "")

$strFirstName = Read-Host -Prompt "What is the employee's first name?"
$strLastName = Read-Host -Prompt "What is the employee's last name?"
$strDisplayName = $strFirstName + " " + $strLastName
$strLastNameClean = Convert-ToFriendlyName $strLastName
$strADUN = $strFirstName.Substring(0,1) + $strLastNameClean 
$strADUN = $strADUN.ToLower()
$strEmail = $strADUN + "@DOMAIN.com"
$strJobTitle = Read-Host -Prompt "What is the employee's job title?"
$arrDepartmentsNum
$intDept = Read-Host -Prompt "Please select the number department that the employee belongs to."
$intDept = $intDept - 1
$strMgr = Read-Host -Prompt "Enter the AD username of the employee's manager."
$strMgrEmail = $strMgr + "@DOMAIN.com"
$strCRM = Read-Host -Prompt "Is CRM access required? (y/n)"
$strIB = Read-Host -Prompt "Is SOFTWARE access required? (y/n)"
$objUserInstance = Get-ADUser -Identity $arrDeptTemplates[$intDept]
$objParentDN = $objUserInstance.distinguishedname
##$strPass = New-SWRandomPassword -MinPasswordLength 8 -MaxPasswordLength 12 -FirstChar abcdefghijklmnopqrstuvwxyz
$strCompany = "COMPANY"
$strUPN = $strADUN + "@DOMAIN.corp"

If ($intDept -eq 20){
$strEmail = "ID" + $strFirstName.Tolower() + "@DOMAIN.com"
$strCompany = "COMPANY"
}
else {
$strEmail = $strADUN + "@DOMAIN.com"
}


##########################################################################################
#                                                                                        #
#   Phase 02 - Confirm Variable Input                                                    #
#                                                                                        #
#   01. Write back all variables                                                         #
#   02. Prompt for confirmation                                                          #
#   03. If confirmation == yes                                                           #
#       -- A -- Continue                                                                 #
#   04. If confirmation == no                                                            #
#       -- B -- Exit Script                                                              #
#   05. Continue to Phase 03                                                             #
#                                                                                        #
##########################################################################################

Write-Host ("")
Write-Host ("")
Write-Host ("")
Write-Host ("Display Name = " + $strDisplayName)
Write-Host ("SamAccountName = " + $strADUN)
Write-Host ("First Name = " + $strFirstName)
Write-Host ("Last Name = " + $strLastName)
Write-Host ("Name = " + $strDisplayName)
Write-Host ("Instance = " + $objParentDN)
Write-Host ("Path = " + $arrPathLocation[$intDept])
Write-Host ("Password = " + $strPass)
Write-Host ("Title = " + $strJobTitle)
$strMgrName = Get-ADUser -Identity $strMgr
Write-Host ("Manager = " + $strMgrName.name)
Write-Host ("Department = " + $arrDepartments[$intDept])
Write-Host ("Email = " + $strEmail)
Write-Host ("Company = " + $strCompany)
Write-Host ("User Principle Name = " + $strUPN)
Write-Host ("Enabled = " + "True")
Write-Host ("")
$strConfirmNewUser = Read-Host -Prompt "Is all of this information correct? (y/n)"
if($strConfirmNewUser -ne "y"){
    exit
}

##########################################################################################
#                                                                                        #
#   Phase 03 - Activate Active Directory Object                                          #
#                                                                                        #
#   01. Check if AD account exists                                                       #
#   02. If AD account exists                                                             #
#       -- A -- Prompt to enable user                                                    #
#          --- If yes, enable AD account. Continue on Step 06                            #
#          --- If no, exit script                                                        #
#   03. If AD account doesn't exist                                                      #
#       -- B -- Continue to step 4                                                       #
#   04. Create new AD account from variable in Phase 01                                  #
#   05. Sleep for 30 seconds                                                             #
#   06. Continue to Phase 04                                                             #
#                                                                                        #
##########################################################################################

Try{
    Get-ADUser -Identity $strADUN
    Write-Host ("")
    $strExists = Read-Host -Prompt "User already exists. Would you like to activate them? (y/n) (selecting no will exit the sctipt)"
    if($strExists -eq "y"){
        Enable-ADAccount -Identity $strADUN
        Write-Host ("")
        Write-Host ($stradun + " account enabled.")
        Write-Host ("")
        Write-Host ("")
    }
    else{
        exit
    }
    Write-Host ("")
}
Catch{
    Write-Host ("")
    Write-Host ("Creating AD User Account......")
    Write-Host ("")
    New-ADUser -DisplayName $strDisplayName `
               -SamAccountName $strADUN `
               -Name $strDisplayName `
               -Instance $objUserInstance `
               -Path $arrPathLocation[$intDept] `
               -AccountPassword (ConvertTo-SecureString -AsPlainText $strPass -Force) `
               -ChangePasswordAtLogon $True `
               -Title $strJobTitle `
               -Manager $strMgr `
               -Department $arrDepartments[$intDept] `
               -EmailAddress $strEmail `
               -GivenName $strFirstName `
               -Surname $strLastName `
               -Company $strCompany `
               -UserPrincipalName $strUPN `
               -Enabled $True

    Get-ADUser -Identity $objUserInstance -Properties memberof |
    Select-Object -ExpandProperty memberof |
    Add-ADGroupMember -Members $strADUN -PassThru |
    Select-Object -Property SamAccountName
    Write-Host ("")
    Write-Host ("")
    Write-Host ("AD User Created Successfully.....")
    Write-Host ("")
    Write-Host ("")
}
Start-Sleep -s 10

##########################################################################################
#                                                                                        #
#   Phase 04 - Establish User Z Drive                                                    #
#                                                                                        #
#   01. Set user directory                                                               #
#   02. Append domain prefix to AD name to create user variable                          #
#   03. Set security access object variable                                              #
#   04. Check if directory exists                                                        #
#   05. If directory exists                                                              #
#       -- A -- Write to host notifying admin                                            #
#   06. If directory doesn't exist                                                       #
#       -- B -- Continue to step 07                                                      #
#   07. Create user directory                                                            #
#   08. Grant full access permissions to user directory                                  #
#   09. Sleep for 30 seconds                                                             #
#   10. Continue to Phase 05                                                             #
#                                                                                        #
##########################################################################################

If ($arrDepartmentsNum -ne 21){
$strCorpSharePath = "\\SERVER.corp\corpshares\Users\" + $strADUN
$strUser = "DOMAIN\" + $strADUN
$objFullAccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule ($strUser, "FullControl", "ContainerInherit, ObjectInherit", "None", "Allow")
$boolDirExists = Test-Path $strCorpSharePath
if($boolDirExists -eq $True){
    Write-Host ("User's Z drive already exists.....")
    Write-Host ("")
    Write-Host ("")
}
else{
    Write-Host ("Creating " + $strDisplayName + "'s Z drive.....")
    New-Item -Path $strCorpSharePath  -ItemType directory -Force
    $objACL = Get-Acl $strCorpSharePath
    $objACL.AddAccessRule($objFullAccessRule) 
    Set-Acl -AclObject $objACL $strCorpSharePath

    Write-Host ($strDisplayName + "'s Z drive was created successfully.....") 
    Write-Host ("")
    Write-Host ("")
}
Start-Sleep -s 10
}

##########################################################################################
#                                                                                        #
#   Phase 05 - Create User's Mailbox                                                     #
#                                                                                        #
#   01. Try Block - If no error                                                          #
#       -- A -- Proceed to step 03                                                       #
#   02. Catch Block - If error                                                           #
#       -- B -- Proceed to step 09                                                       #
#   03. Create Exchange session variable                                                 #
#   04. Import Exchange session                                                          #
#   05. Create object variable of all mailbox databases starting with "PM-MDB"           #
#   06. Execute Find Small Database Loop (For each database in databases object)         #
#       -- A --  Get current mailboxes sizes by summing the size of all mailboxes and    #
#                "Deleted Items" in the database                                         #
#       -- B --  Compare the sizes to find the smallest DB                               #
#       -- C --  Go back to 05-A and repeat until the smallest DB is found               #
#       -- D --  Set variable with the smallest database's name                          #
#   07. Create mailbox for existing user                                                 #
#   08. Remove Exchange session - Continue to step 10                                    #
#   09. Notify Admin that the mailbox needs to be create manually. Pause                 #
#   10. Continue to Phase 06                                                             #
#                                                                                        #
##########################################################################################


<# 

Try{
    $objPowerShellSession = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri http://mail.DOMAIN.com/PowerShell/ -Authentication Kerberos -Credential $objAdminCred
    Import-PSSession $objPowerShellSession
    Write-Host ("Connecting to remote Exchange Server......")
    $MBXDbs = Get-MailboxDatabase | Where-Object {$_.Identity -like "PM-MDB*"}
    ForEach ($MBXDB in $MBXDbs) {
        $TotalItemSize = Get-MailboxStatistics -Database $MBXDB | %{$_.TotalItemSize.Value.ToMB()} | Measure-Object -sum
        $TotalDeletedItemSize = Get-MailboxStatistics -Database $MBXDB.DistinguishedName | %{$_.TotalDeletedItemSize.Value.ToMB()} | Measure-Object -sum
        $TotalDBSize = $TotalItemSize.Sum + $TotalDeletedItemSize.Sum
        Write-Host ("")
        Write-Host ("")
        Write-Host ("Database: " + $MBXDB + " is " + $TotalDBSize)
        Write-Host ("")
        Write-Host ("")
        If (($TotalDBSize -lt $SmallestDBsize) -or ($SmallestDBsize -eq $null)){
            $SmallestDBsize = $DBsize
            $SmallestDB = $MBXDB
            }
        }
    Write-host "Smallest DB: " $SmallestDB
    Write-Host ("")
    Write-Host ("") 
    
    $SmallestDB = "PM-MDB-D"
    Enable-Mailbox -Identity $strADUN `
                   -Alias $strADUN `
                   -DisplayName $strDisplayName `
                   -Database $SmallestDB 
    Remove-PSSession $objPowerShellSession
    Write-Host ("User Mailbox Created Successfully.....")
    Write-Host ("")
    Write-Host ("")
}
Catch{
    Remove-PSSession $objPowerShellSession
    Write-Host ("There was an error connecting to Exchange. Please create the user's mailbox manually.") 
    Write-Host ("")
    Write-Host ("")
    Pause  
}

#>

##########################################################################################
#                                                                                        #
#   Phase 06 - Identify and Address CRM/Intellibid Access Requirements                   #
#                                                                                        #
#   01. Set CRM/IB admin email address variable                                          #
#   02. Set SMTP mail address variable                                                   #
#   03. Email CRM/IB admin appropriately based on access requirements                    #
#   04. Write to host that the script has completed                                      #
#   05. Pause to allow admin to review output                                            #
#                                                                                        #
##########################################################################################



$strCRMIBadminEmail = "erp@DOMAIN.com"
$strCC = "mis@DOMAIN.com"
$strSMTP = "mail.DOMAIN.com"
if($strCRM -eq "y" -and $strIB -eq "y"){
    $strBody = "Please grant " + $strDisplayName + " access to CRM and intellibid. Department is " + $strJobTitle + ". Manager is " + $strMgrName
    Send-MailMessage -To $strCRMIBadminEmail -From "mis@DOMAIN.com" -Subject "CRM and Intellibid Access" -Body $strBody -SmtpServer $strSMTP 
}
elseif($strCRM -eq "y"){
    $strBody = "Please grant " + $strDisplayName + " access to CRM. Position is " + $strJobTitle + ". Manager is " + $strMgrName.Name + "."
    Send-MailMessage -To $strCRMIBadminEmail -From "mis@DOMAIN.com" -Subject "CRM Access" -Body $strBody -SmtpServer $strSMTP
}
elseif($strIB -eq "y"){
    $strBody = "Please grant " + $strDisplayName + " access to intellibid."
    Send-MailMessage -To $strCRMIBadminEmail -From "mis@DOMAIN.com" -Subject "Intellibid Access" -Body $strBody -SmtpServer $strSMTP
}

# Email password to manager.
$strBody = "Account: " + $strADUN + " has been created for " + $strDisplayName + ". Password is: " + $strPass + " Please contact MIS if you need further assistance with this user."
$strSubject = "Account for " + $strADUN + " has been created."
Send-MailMessage -To $strMgrEmail -From "mis@DOMAIN.com" -Subject $strSubject -Body $strBody -SmtpServer $strSMTP


Write-Host ("The automated processes have completed. Please add the user in connectwise, and activate their key fob.")   
# Start-Sleep -s 600
pause
