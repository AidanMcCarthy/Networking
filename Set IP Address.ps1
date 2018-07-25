###-------------------------------------------------------------------###
#																		#
#	Powershell script to set the IP address for the new backup			#
#	network adapter...													#
#																		#
#	Author:		Aidan McCarthy											#
#	Date:		June 4, 2013											#
#	Version:	1.0														#
#																		#
#	Requirements:	.CSV with headers matching 'Server' and 'BackupIP'	#
#																		#
###-------------------------------------------------------------------###

	CLS
	
###--------------#
##  Log Output  ##
#--------------###

#	Start-Transcript 


###------------------------------###
##  Display Open File Dialog Box  ##
#----------------------------------#

	Function Get-FileName($initialDirectory)
		{   
		 [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") |
		 Out-Null

		 $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
		 $OpenFileDialog.initialDirectory = $initialDirectory
		 $OpenFileDialog.filter = "Comma Separated Files (*.csv)|*.csv|All Files (*.*)|*.*"
		 $OpenFileDialog.ShowDialog() | Out-Null
		 $OpenFileDialog.filename
		} #end function Get-FileName

###---------------------------------------###
##  Select CSV containing list of servers  ##
#-------------------------------------------#

	$csv = Import-Csv (Get-FileName -initialDirectory "%homepath%")

###-----------------------###
##  Get Admin Credentials  ##
#---------------------------#

#	$username = "domain\user"
#	$password = cat C:\servers.txt | convertto-securestring
#	$admincredential = new-object -typename System.Management.Automation.PSCredential `
#	         -argumentlist $username, $password
	$admincredential = Get-Credential

###-------------------------###
##  Process list of servers  ##
#-----------------------------#

	ForEach ($line in $csv){

		$server = $line.Server
		$backup_ip = $line.BackupIP
		$new_dns = "IP","IP"

###--------------------------------###
##  Verify connection to server...  ##
#------------------------------------#

	If (Test-Connection -computer $server -count 1 -quiet) 
	{
		
		Write-Host "Server online and responding to ICMP..." -ForegroundColor DarkGreen
		Write-Host "Attempting connection to  "$server"..." -ForegroundColor DarkGreen
		Write-Host "Successfully connected to "$server"..." -BackgroundColor DarkGreen -ForegroundColor White

###---------------------------------------###
##  Perform Network Adapter modifications  ##
#-------------------------------------------#

 {$_.IPEnabled -eq "TRUE" -and $_.DHCPEnabled -eq "TRUE"}

	If	($NIC = Get-WMIObject Win32_NetworkAdapterConfiguration -ComputerName $server -Credential $admincredential | where {$_.IPAddress -eq "$backup_ip"})

		{
			If ($NIC.EnableStatic("$backup_ip", "255.255.0.0") | Where {$_.ReturnValue -eq "0"}){
				Write-Host "   * Static IP set..."}
				Else{
				Write-Host "   *** ERROR ***   Failed to configure static IP   " -BackgroundColor Red -ForegroundColor White}
				
			If ($NIC.SetDynamicDNSRegistration($false,$false) | Where {$_.ReturnValue -eq "0"}){
				Write-Host "   * Dynamic DNS Registration set..."}
				Else{
				Write-Host "   *** ERROR ***   Failed to configure Dynamic DNS Registration   " -BackgroundColor Red -ForegroundColor White}

			If ($NIC.SetDNSDomain("sub.domain.name") | Where {$_.ReturnValue -eq "0"}){
				Write-Host "   * DNS Domain set..."}
				Else{
				Write-Host "   *** ERROR ***   Failed to configure DNS Domain   " -BackgroundColor Red -ForegroundColor White}
				
			If ($NIC.SetDNSServerSearchOrder($new_dns) | Where {$_.ReturnValue -eq "0"}){
				Write-Host "   * DNS Server Search Order set..."}
				Else{
				Write-Host "   *** ERROR ***   Failed to configure DNS Server Search Order   " -BackgroundColor Red -ForegroundColor White}			
		}
			Else
				{Write-Host
				Write-Host "   *** ERROR ***   No DHCP enabled adapters found on $server...   " -BackgroundColor Red -ForegroundColor Yellow
				Write-Host
				Write-Host}
	}
		
###------------------------###
##  Unreachable servers...  ##
#----------------------------#

	Else{
		Write-Host	
		Write-Host $server not responding... -BackgroundColor Red -ForegroundColor White
		Write-Host
		}				
}