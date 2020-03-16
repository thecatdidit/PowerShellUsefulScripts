<#
	===========================================================================
	 Created with:	PowerShell ISE (Win10 18362)
	 Revision:		2020.03.16.01
	 Last Modified:	16 March 2020
	 Created by:	Jay Harper (jayharper@gmail.com)
	 Filename:		Uninstall-BlueCoatUnifiedAgent.ps1
	===========================================================================
	.CHANGELOG
		REV. 2018.12.18.01
		Included the final module for uniformed logging as the utility is carried out
		Script initial creation.
		REV. 2019.09.20.1000
		Updated script to cover additional resources where BCUA remnants should be deleted.
		REV. 2019.10.04.1700
        Finessing logging capabilities with a standardized function
        REV. 2020.03.16.01
        Cosmetic adjustments.
	.SYNOPSIS
		This script is designed to manually terminate Blue Coat Unified Agent
		components and remove remnants of the application.
		The steps are based on Symantec's HOWTO for manual uninstallation of UA
		The script should be used ONLY WHEN BLUE COAT UNIFIED AGENT WILL NOT
        UNINSTALL THROUGH STANDARD METHODS.
	.DESCRIPTION   
		This script has been tested on the following versions of Unified Agent (x64):
		4.7.6.198155
		4.8.0.201333
		4.8.3.203405
		4.9.1.208066
		4.9.4.212024
		4.10.1.219990
		
		Functionality:
		
		1. 'bcua-service.exe' and 'bcua-notifier.exe' are forcefully terminated
		2. The application's registry entries are deleted
			a. 'bcua-service' Service registration
			b. Remove Write Filter Protection service registration [REGISTRY]
			c. Remove Software entry (e.g. Programs and Features [REGISTRY]
			d. Remove installer Features and Classes [REGISTRY]
			e. Delete installation directly under 'C:\Program Files'
			f. Delete installation folder under 'C:\ProgramData'
			g. Remove files related to Windows driver registration
		Afterward, it is recommended that you reboot the system. If desired, ou should be able to install
		whatever BCUA version is needed.
		A log file is created to log details of the agent removal. To set it
		to another directory, update the $logFile variable
		
	.USAGE
		PS> Uninstall-BlueCoatUnifiedAgent.ps1
	.INPUTS
		NONE
	.OUTPUTS
		The script with output results of each step to the console. It will also
		store the entirety of the process to a logfile.
	.NOTES
        I will wrap tighter functions to omit repetition of code, when time permits.
        Some parameters will also be added. The origin of this script was need-based,
        so it may look a little rough until some more polish is applied.
        The script has been tested in SCCM/MEM as a package, an application and a
        PSADT instance. There were no unexpected reboots or adverse effects
        observed. YMMV, as always, so use of this script means that you agree
        to deal with any issues that may arise in your world. Just a gentle
        disclaimer.
#>


##
# Configure logfile settings and set logfile header
# formatting for easier reference
##
function Get-Timestamp {

    Return $(get-date -UFormat "%d%b%y%H%M%S")
    
}
    
##
# Define HKEY_CLASSES_ROOT PSObject
##
New-PSDrive -PSProvider registry -Root HKEY_CLASSES_ROOT -Name HKCR -ErrorAction SilentlyContinue
    
$LogTimestamp = (get-date -UFormat "%d%b%y%H%M%S")
$logFile = "C:\Temp\BCUA_REMOVAL_LOG_$LogTimeStamp.log"
Start-Transcript -Path $logFile -Force
    
##
# Set variables for application components
# Registry entries
##
$regDriverStore = gci 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DIFx\DriverStore' -Recurse | foreach { gp $_.PSPath } | where DisplayName -eq 'Unified Agent'
$regDriverComponent = gci 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DIFxApp\Components' | foreach { gp $_.PSPath } | Where DriverStore -Like "*bcua*"
$regBCUAClasses = gci 'HKLM:\SOFTWARE\Classes\Installer\Features\' | Where Property -like "*bcua*"
$regAppEntry = gci 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall' | foreach { gp $_.PSPath } | Where DisplayName -eq "Unified Agent"
$regAppEntry2 = gci 'HKCR:\installer\products' -Recurse | foreach { gp $_.PSPath } | Where ProductName -Match "Unified Agent"
$regAppEntry3 = gci 'HKLM:\SOFTWARE\Classes\installer\Products' | % { gp $_.PSPath } | Where ProductName -Match "Unified Agent"
$regService = "HKLM:\SYSTEM\CurrentControlSet\Services\bcua-service"
$regService2 = "HKLM:\SYSTEM\ControlSet001\Services\bcua-service"
$regWFP = "HKLM:\SYSTEM\CurrentControlSet\Services\bcua-wfp"
$regWFP2 = "HKLM:\SYSTEM\ControlSet001\Services\bcua-wfp"
$regBC = "HKLM:\SOFTWARE\Blue Coat Systems"
$regProgramData = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Installer\Folders"
$regComponent1 = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Installer\UserData\S-1-5-18\Components\1702FCBC0EAA3FE4F966E6D20AAE5186'
$regComponent2 = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Installer\UserData\S-1-5-18\Components\2F0BBE479BF57F54CA5E397E939B9998'
$regComponent3 = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Installer\UserData\S-1-5-18\Components\B1DC94812FAEE4650B036B3C91949C11'
$regComponent4 = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Installer\UserData\S-1-5-18\Components\F9796423B18448D42B32A2CABCE3DF59'
$regComponent5 = 'HKLM:\SOFTWARE\Classes\Installer\Products\230066858F5184B448F8363D511403C5'
$regComponent6 = 'HKCR:\Installer\Products\230066858F5184B448F8363D511403C5'
    
##
# Application directories
##
$dirBCUA = "C:\ProgramData\bcua\"
$dirBlueCoat = "C:\Program Files\Blue Coat Systems\"
$dirBCDriver = "C:\Windows\System32\drivers\bcua-wfp.sys"
$dirBCDrvStore = gci C:\windows\system32\drvstore | Where Name -like "*bcua*" -ErrorAction SilentlyContinue
    
##
#Force stop 'bcua-service.exe' and 'bcua-notifier.exe'
$timeStamp = Get-Timestamp
Write-Output "$timeStamp Stopping all BlueCoat Services"
Get-Process -name "bcua*" | Stop-Process -Force -ErrorAction SilentlyContinue
    
if (Test-Path $regService -ErrorAction SilentlyContinue) {
    $timeStamp = Get-Timestamp
    Write-Output "$timeStamp BCUA-Service Key Found. Removing..."
    Remove-Item $regService -Recurse -Force -Verbose -ErrorAction SilentlyContinue
}
else {
    $timeStamp = Get-Timestamp
    Write-Output "$timeStamp No BCUA Service Key was found"
}
    
if (Test-Path $regService2 -ErrorAction SilentlyContinue) {
    $timeStamp = Get-Timestamp
    Write-Output "$timeStamp BCUA-Service2 Key Found. Removing..."
    Remove-Item $regService2 -Recurse -Force -Verbose -ErrorAction SilentlyContinue
}
    
if (Test-Path $regWFP -ErrorAction SilentlyContinue) {
    $timeStamp = Get-Timestamp
    Write-Output "$timeStamp BCUA-WFP Key Found. Removing"
    Remove-Item $regWFP -Recurse -Force -Verbose -ErrorAction SilentlyContinue
}
    
if (Test-Path $regWFP2 -ErrorAction SilentlyContinue) {
    $timeStamp = Get-Timestamp
    Write-Output "$timeStamp BCUA-WFP2 Key Found. Removing"
    Remove-Item $regWFP2 -Recurse -Force -Verbose -ErrorAction SilentlyContinue
}
if (Test-Path $regBC -ErrorAction SilentlyContinue) {
    $timeStamp = Get-Timestamp
    Write-Output "$timeStamp Blue Coat Key Found. Removing"
    Remove-Item $regBC -Recurse -Force -Verbose -ErrorAction SilentlyContinue
}
if ($regBCUAClasses) {    
    $timeStamp = Get-Timestamp
    Write-Output "$timeStamp Blue Coat installer classes found. Removing"
    Remove-Item ($regBCUAClasses.PSPath) -Recurse -Force -Verbose -ErrorAction SilentlyContinue
}
    
if (Test-Path $dirBCUA -ErrorAction SilentlyContinue) {
    $timeStamp = Get-Timestamp
    Write-Output "$timeStamp Found ProgramData\bcua directory. Removing"
    Remove-Item $dirBCUA -Recurse -Force -Verbose -ErrorAction SilentlyContinue
}
    
try {
    if (Get-ItemProperty -Path $regProgramData -Name $dirBCUA -ErrorAction SilentlyContinue) {
        $timeStamp = Get-Timestamp
        Write-Output "$timeStamp Found ProgramData\BCUA registry key. Removing"
        Remove-ItemProperty -Path $regProgramData -Name $dirBCUA -Force -Verbose -ErrorAction SilentlyContinue
    }
}
    
catch {
    $timeStamp = Get-Timestamp
    Write-Output "$timeStamp $regProgramData does not exist"
}
    
    
if (Test-Path $dirBlueCoat -ErrorAction SilentlyContinue) {
    $timeStamp = Get-Timestamp
    Write-Output "$timeStamp Found Blue Coat Program Files Directory. Removing"
    Remove-Item $dirBlueCoat -Recurse -Force -Verbose -ErrorAction SilentlyContinue
}
    
if (Test-Path $dirBCDriver -ErrorAction SilentlyContinue) {
    $timeStamp = Get-Timestamp
    Write-Output "$timeStamp Found Blue Coat Driver. Removing"
    Remove-Item $dirBCDriver -Force -Verbose -ErrorAction SilentlyContinue
}
    
if (Get-Service -Name bcua-service -ErrorAction SilentlyContinue) {
    $timeStamp = Get-Timestamp
    Write-Output "$timeStamp Service still installed. Removing"
    Stop-Service bcua-service -Force -ErrorAction SilentlyContinue
}
    
Remove-Item $regComponent1 -Force -ErrorAction SilentlyContinue
Remove-Item $regComponent2 -Force -ErrorAction SilentlyContinue
Remove-Item $regComponent3 -Force -ErrorAction SilentlyContinue
Remove-Item $regComponent4 -Force -ErrorAction SilentlyContinue
Remove-Item $regComponent5 -Force -ErrorAction SilentlyContinue
Remove-Item $regComponent6 -Force -ErrorAction SilentlyContinue
Remove-Item $regAppEntry.PSPath -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item $regAppEntry2.PSPath -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item $regAppEntry3.PSPath -Recurse -Force -ErrorAction SilentlyContinue
Stop-Transcript