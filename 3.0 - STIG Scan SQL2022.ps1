<#
This script will apply STIG requirements that can be used with System Center to SQL Server 2019.
Written by: Thomas Cook
Updated by: Joseph Schaff
Last Updated: 28 Mar 2019
Updated by: Dave Rodriguez
Last Updated: 28 Dec 2022
Description: Updated the key path for SQL2022 from MSSQL15 to MSSQL16. 
#>
#Disable Adhoc Access
$foregroundcolor = "white"
$backgroundcolor = "green"
$currenterror = $error[0]

$currentkey = "HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Lsa\FipsAlgorithmPolicy\"
Get-ItemProperty -Path $currentkey 
$currentkey = "HKLM:\Software\Microsoft\Microsoft SQL Server\MSSQL16.MSSQLSERVER\Providers\ADSDSOObject"
get-ItemProperty -Path $currentkey -Name DisallowAdHocAccess -Value 1 -Type DWord
IF ($error[0] -eq $currenterror) {Write-Host ADSDSOObject adhoc access disabled -foregroundcolor $foregroundcolor -backgroundcolor $backgroundcolor}
$currenterror = $error[0]
$currentkey = "HKLM:\Software\Microsoft\Microsoft SQL Server\MSSQL16.MSSQLSERVER\Providers\DB2OLEDB"
get-ItemProperty -Path $currentkey -Name DisallowAdHocAccess -Value 1 -Type DWord
IF ($error[0] -eq $currenterror) {Write-Host DB2OLEDB adhoc access disabled -foregroundcolor $foregroundcolor -backgroundcolor $backgroundcolor}
$currenterror = $error[0]
$currentkey = "HKLM:\Software\Microsoft\Microsoft SQL Server\MSSQL16.MSSQLSERVER\Providers\MSDAOSP"
IF (-not (test-path $currentkey)) {New-Item -path $currentkey | out-null}
get-ItemProperty -Path $currentkey -Name DisallowAdHocAccess -Value 1 -Type DWord
IF ($error[0] -eq $currenterror) {Write-Host MSDAOSP adhoc access disabled -foregroundcolor $foregroundcolor -backgroundcolor $backgroundcolor}
$currenterror = $error[0]
$currentkey = "HKLM:\Software\Microsoft\Microsoft SQL Server\MSSQL16.MSSQLSERVER\Providers\MSDASQL"
get-ItemProperty -Path $currentkey -Name DisallowAdHocAccess -Value 1 -Type DWord
IF ($error[0] -eq $currenterror) {Write-Host MSDASQL adhoc access disabled -foregroundcolor $foregroundcolor -backgroundcolor $backgroundcolor}
$currenterror = $error[0]
$currentkey = "HKLM:\Software\Microsoft\Microsoft SQL Server\MSSQL16.MSSQLSERVER\Providers\MSIDXS"
get-ItemProperty -Path $currentkey -Name DisallowAdHocAccess -Value 1 -Type DWord
IF ($error[0] -eq $currenterror) {Write-Host MSIDXS adhoc access disabled -foregroundcolor $foregroundcolor -backgroundcolor $backgroundcolor}
$currenterror = $error[0]
$currentkey = "HKLM:\Software\Microsoft\Microsoft SQL Server\MSSQL16.MSSQLSERVER\Providers\MSOLAP"
get-ItemProperty -Path $currentkey -Name DisallowAdHocAccess -Value 1 -Type DWord
IF ($error[0] -eq $currenterror) {Write-Host MSOLAP adhoc access disabled -foregroundcolor $foregroundcolor -backgroundcolor $backgroundcolor}
$currenterror = $error[0]
$currentkey = "HKLM:\Software\Microsoft\Microsoft SQL Server\MSSQL15.MSSQLSERVER\Providers\SQLNCLI11"
get-ItemProperty -Path $currentkey -Name DisallowAdHocAccess -Value 1 -Type DWord
IF ($error[0] -eq $currenterror) {Write-Host SQLNCLI10 adhoc access disabled -foregroundcolor $foregroundcolor -backgroundcolor $backgroundcolor}
$currenterror = $error[0]
$currentkey = "HKLM:\Software\Microsoft\Microsoft SQL Server\MSSQL15.MSSQLSERVER\Providers\SQLOLEDB"
IF (-not (test-path $currentkey)) {New-Item -path $currentkey | out-null}
get-ItemProperty -Path $currentkey -Name DisallowAdHocAccess -Value 1 -Type DWord
IF ($error[0] -eq $currenterror) {Write-Host SQLOLEDB adhoc access disabled -foregroundcolor $foregroundcolor -backgroundcolor $backgroundcolor}

