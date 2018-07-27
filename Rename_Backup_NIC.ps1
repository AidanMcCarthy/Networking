<#
.SYNOPSIS
    Rename Backup NIC

.LINK
    http://github.aidan.nz

.DESCRIPTION
    Script to change the name of the backup NIC on a server

.PARAMETER Example
    Example Parameter

.INPUTS
    None

.OUTPUTS
    Log file stored in C:\Windows\Temp\<name>.log

.NOTES
    Version:            1.1
    Creation Date:      01/01/2012
    Modified Date:      06/29/2018
    Purpose/Change:
    Author:             Aidan J. McCarthy (info@aidan.nz)

	Version 1.1 - Uploaded to GitHub. Updated formatting
	Version 1.0 - Initial script

.EXAMPLE


#>
#-------------------------------------------------------[Initialisations]----------------------------------------------------------


###---------------------------------------###
##  Select CSV containing list of servers  ##
#-------------------------------------------#

	$csv = Import-Csv C:\server.csv

###-----------------------###
##  Get Admin Credentials  ##
#---------------------------#


	$username = "domain\user"

	$Pass = ""
	$Password = ""

	# NIC Settings

	$NewInterfaceName = "Production Network"


###-------------------------###
##  Process list of servers  ##
#-----------------------------#

#	ForEach ($line in $csv)
#		{
#		$server = $line.Server
#		$backup_ip = $line.NewIP
		$server = "server.domain.local"
		$backup_ip = "10.0.0.1"

# Rename Network Adapter

#		If (Test-Connection -computer $server -count 2 -quiet) 
#			{
			Write-Host "Server online and responding to ICMP..." -ForegroundColor DarkGreen
			Write-Host "Attempting connection to  "$server"..." -ForegroundColor DarkGreen
			Write-Host "Successfully connected to "$server"..." -BackgroundColor DarkGreen -ForegroundColor White

			Write-Host
			Write-Host "   Identifying Network adapter to rename...   "

			$BackupNIC = Get-WMIObject Win32_NetworkAdapterConfiguration -ComputerName $server -| where {$_.IPAddress -eq "$backup_ip"}
			$NetworkAdapterID = Get-WmiObject Win32_NetworkAdapter -ComputerName $server | ? {$_.index -eq ($BackupNIC).index}
			$OldInterfaceName = ($NetworkAdapterID).netconnectionID

			Write-Host "   The network adapter named '$OldInterfaceName' will be renamed to '$NewInterfaceName'   "
			Write-Host 
			$arguments = @(([String]::Format("\\{0}",$server)),"/accepteula",([String]::Format("-u {0}",$username)),([String]::Format("-p {0}",$pass)),"cmd.exe /c netsh interface set interface",([String]::Format("`"{0}`"",$OldInterfaceName)),([String]::Format("newname=""`{0}`"",$NewInterfaceName)))

			start-process psexec.exe -ArgumentList $arguments -NoNewWindow -wait

			Write-Host "   * Network adapter successfully renamed...   "
			Write-Host
			Write-Host
			Write-Host
			Write-Host
#			}

<#
## Rename Network Adapter

		Write-Host "Identifying Network adapter to rename...   "

		$BackupNIC = Get-WMIObject Win32_NetworkAdapterConfiguration -ComputerName $server -Credential $admincredential | where {$_.IPAddress -eq "$backup_ip"}
		$NetworkAdapterID = Get-WmiObject Win32_NetworkAdapter -ComputerName $server -Credential $admincredential | ? {$_.index -eq ($BackupNIC).index}
		$OldInterfaceName = ($NetworkAdapterID).netconnectionID

		Write-Host "The network adapter named '$OldInterfaceName' will be renamed to '$NewInterfaceName'   "
		Write-Host 
		$arguments = @(([String]::Format("\\{0}",$server)),([String]::Format("-u {0}",$username)),([String]::Format("-p {0}",$pass)),"cmd.exe /c netsh interface set interface",([String]::Format("`"{0}`"",$OldInterfaceName)),([String]::Format("newname=""`{0}`"",$NewInterfaceName)))

		start-process psexec.exe -ArgumentList $arguments -NoNewWindow -Wait

		Write-Host "   * Network adapter successfully renamed...   "
		Write-Host
		Write-Host		

###------------------------###
##  Unreachable servers...  ##
#----------------------------#

		Else
			{
			Write-Host	
			Write-Host $server not responding... -BackgroundColor Red -ForegroundColor White
			Write-Host
			}
		}
#>