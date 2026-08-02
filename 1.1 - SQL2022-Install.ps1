<#
.Synopsis
   Automating SQL Server installation helps ensure consistency and saves time when deploying multiple instances across different environments.
.DESCRIPTION
   Automating SQL Server installation can be achieved using various methods, and one common approach is to use a configuration file and command-line options. 
.EXAMPLE
   setup.exe /Q /ACTION=Install /IAcceptSQLServerLicenseTerms /IAcceptSQLServerLicenseTerms /ConfigurationFile=ConfigurationFile.ini
.INPUTS
   Server name, SQL Server Password, SQL Agent Password, SA Password
.OUTPUTS
   SQL Installtion Summary from the server. 
.NOTES
   ===========================================================================
   Created on:   	2024-03-01
   Created by:   	dave.rodriguez@dliflc.edu
   Organization: 	DCSIT DevOps
   Filename: 		1.0 - SQL2022-Install.ps1
   Modified on:   	2024-04-19
   Modified by:   	dave.rodriguez@dliflc.edu
   Description:   	Added option to install localy or remotely. 
   ==========================================================================
   Filename: 		1.1 - SQL2022-Install.ps1
   Modified on:   	2024-06-08
   Modified by:   	dave.rodriguez@dliflc.edu
   Description:   	Ommit SA password set and option, Add Integration Service
   ===========================================================================
.COMPONENT
   The component this cmdlet belongs to
.ROLE
   The role this cmdlet belongs to
.FUNCTIONALITY
   Automate the installation 
#>

$cred = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
Write-Output $cred
$continue = Read-Host -Prompt "Continue with current logged in user [y/n]"

#Need to put domain into service account
$dom = $env:userdomain
write-Output "Domain:"  $dom

#add in full fdnq server.
$serv = Read-Host "Please enter target server: " #-AsSecureString
Write-Output $serv
#ENTER SERVER NAME 
$sysinfo = Get-WmiObject -Class Win32_ComputerSystem -ComputerName $serv

$continue = Read-Host -Prompt "Continue with  [y/n]"
if (($continue -eq 'n' ) -or ($continue -eq 'no'))  { 
	Exit
	}									
		
$s = New-PSSession -computerName $serv -credential $cred
#CHECK THE DRIVE IS 64K and LABELED CORRECTLY

#CREATE DATA DIRECTORY
If (Invoke-Command -session $s -Scriptblock {test-path -path "D:\DBDATA\"}) { 
	Write-Output "Path: D:\DBDATA\ exist."
	} else
    {
	Invoke-Command -session $s -Scriptblock {New-Item -type directory -path D:\DBDATA\} 
	}
If (Invoke-Command -session $s -Scriptblock {test-path -path "L:\DBLOGS\"}) {
	Write-output "Path: L:\DBLOGS\ exist."
	} else 
    {
    #CREATE LOG DIRECTORY
    Invoke-Command -Session $s -Scriptblock {New-Item -type directory -path L:\DBLOGS\ }
    }
If (Invoke-Command -session $s -Scriptblock {test-path -path "T:\DBTEMP\"}) {
	Write-output "Path: T:\DBTEMP\ exist."
	} else 
	{
	#CREATE DATA DIRECTORY
	Invoke-Command -Session $s -Scriptblock {New-Item -type directory -path T:\DBTEMP\ }
	}

#Prompt for MSSQL Engine password
$sqlinst = Read-Host "Please enter the SVC.SQL.MSSQL_INST password" #-AsSecureString
#Write-Output $sqlinst
#Prompt for MSSQL Agent password
$sqlagt = Read-Host "Please enter the SVC.SQL.MSSQL_AGT password" #-AsSecureString
#Write-Output $sqlagt
#Prompt for MSSQL Agent password
$sqlssis = Read-Host "Please enter the SVC.SQL.MSSQL_SSIS password" #-AsSecureString
#Write-Output $sqlssis

# Prompt for SysAdmin password
# 240608 Ommit from input to switch to Windows only authentication
# $sysadmin = Read-Host "Please enter the SysAdmin(SA) password" #-AsSecureString
# Write-Output $sysadmin
#
# Validate credentials
[System.Reflection.Assembly]::LoadWithPartialName("System.DirectoryServices.AccountManagement")
$principalContext = New-Object System.DirectoryServices.AccountManagement.PrincipalContext([System.DirectoryServices.AccountManagement.ContextType]::Domain, 'pom')
IF ($principalContext.ValidateCredentials('svc.sql.mssql.inst', $sqlinst)) {
	write-Output "svc.sql.mssql.inst password passed!"
	} 
    else 
	{
		write-Output "Incorrect svc.sql.mssql.inst password."
	}	

IF ($principalContext.ValidateCredentials('svc.sql.mssql.agt', $sqlagt)) {
		write-Output "svc.sql.mssql.agt password passed!"
	} else 
	{
		write-Output "Incorrect svc.sql.mssql.agt password."
	}

IF ($principalContext.ValidateCredentials('svc.sql.mssql.ssis', $sqlssis)) {
		write-Output "svc.sql.mssql.ssis password passed!"
	} else 
	{
		write-Output "Incorrect svc.sql.mssql.ssis password."
	}
#
$filepath = "1.1 - SQL2022-Install-Config-prd.ini"
# 
write-output "-------------------------------------------"
write-output "Taget Server:$serv"
write-Output "SVC.SQL.MSSQL_Inst Password:$sqlinst"
Write-Output "SVC.SQL.MSSQL_Agt Password:$sqlagt"
Write-Output "SVC.SQL.MSSQL_SSIS Password:$sqlssis"
# Ommit because switching to Windows Authentication
# Write-Output "SysAdmin Password:$sysadmin"
write-output "SQL Config File:$filepath"
write-output "-------------------------------------------"

#ENTER SERVER NAME 
$continue = Read-Host -Prompt "Continue with following parameters [y/n]"

if (($continue -eq 'n') -or ($continue -eq 'no')) { 
	Exit
	}

# Removed to run config from temp folder
# Copy over config file to temp on target server
# Copy-Item -Path $filepath -Destination "C:\temp\" -verbose

#change this to the location of your configuration file
# 240608 Ommit /SAPWD 
#  $command = "E:\setup.exe /Q /IAcceptSQLServerLicenseTerms /IAcceptSQLServerLicenseTerms " + "/SAPWD=""" + $sysadmin + """ /SQLSVCPASSWORD=""" + $sqlinst + """ /AGTSVCPASSWORD=""" + $sqlagt + """ /ConfigurationFile=""" + "C:\Temp\" + $filepath + """ /INDICATEPROGRESS"
$command = "E:\setup.exe /Q /IAcceptSQLServerLicenseTerms /IAcceptSQLServerLicenseTerms " + " /SQLSVCPASSWORD=""" + $sqlinst + """ /AGTSVCPASSWORD=""" + $sqlagt + """ /ISSVCPASSWORD=""" + $sqlssis + """ /ConfigurationFile=""" + "C:\Temp\" + $filepath + """ /INDICATEPROGRESS"
$command = "'" + $command + "'"
#$sysinfo = Get-WmiObject -Class Win32_ComputerSystem -ComputerName $serv
Write-Output $command

Invoke-Command -Session $s -Scriptblock {start-process -filepath E:\setup.exe -arguementlist $command -wait -verbose} 

Invoke-command -Session $s -Scriptblock {notepad.exe}

start-process -filepath 
#REMOVE PSSESSION 
Remove-PSSession $s

#DOWNLOAD ssmsfullsetup
$continue = Read-Host -Prompt "Download the latestSQL Server Managment Studio [y/n]"

if (($continue -eq 'y') -or ($continue -eq 'yes')) { 
$url = 'https://aka.ms/ssmsfullsetup'
invoke-webrequest $url -OutFile ssms-latest.exe
} else 
	{exit
	}

#
If (-not (Get-WindowsFeature -ComputerName $serv -name Failover-Clustering)) {

    Install-WindowsFeature -ComputerName $serv -Name Failover-Clustering -IncludeManagementTools
    }