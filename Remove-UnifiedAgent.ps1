<#
	===========================================================================
	 Created with:	PowerShell ISE (Win10 17134)
	 Revision:		2018.12.18.01
	 Last Modified:	18 Dec 2018
	 Created by:	Jay Harper (github.com/thecatdidit/powershellusefulscripts)
	 Organizaiton:	Happy Days Are Here Again
	 Filename:		Remove-Unified Agent
	===========================================================================
	.CHANGELOG
		REV. 2018.12.18.01]
		Script initial creation.
	.SYNOPSIS
		This script is designed to manually terminate Blue Coat Unified Agent
		components and remove remnants of the application.
		The intende
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
		
		Steps:
		
		1. 'bcua-service.exe' and 'bcua-notifier.exe' are forcefully terminated
		2. The application's registry entries are deleted
			a. 'bcua-service' Service registration
			b. Remove Write Filter Protection service registration [REGISTRY]
			c. Remove Software entry (e.g. Programs and Features [REGISTRY]
			d. Remove installer Features and Classes [REGISTRY]
			e. Delete installation directly under 'C:\Program Files'
			f. Delete installation folder under 'C:\ProgramData'
			g. Remove files related to Windows driver registration
		Afterward, reboot the system. If desired, ou should be able to install
		whatever BCUA version is needed.
		A log file is created to log details of the agent removal. To set it
		to another directory, update the $logFile variable
	.USAGE
		PS> Remove-UnifiedAgent.ps1
	.INPUTS
		NONE
	.OUTPUTS
		The script with output results of each step to the console. It will also
		store the entirety of the process to a logfile.
	.NOTES
		A forthcoming revision will provide some parameters for 
		settings such as logfile location.
#>



##
# Configure logfile settings and set logfile header
# formatting for easier reference
##
function Get-Timestamp {

Return $(get-date -UFormat "[%a %d %b %y] [%H:%M:%S]:`t")

}

$timeStamp = Get-Timestamp
$logFile = "C:\Temp\BCUA_REMOVAL_LOG_$timeStamp.log"
Start-Transcript -Path $logFile -Force

##
# Set variables for application components
# Registry entries
##
$regDriverStore = gci 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DIFx\DriverStore' -Recurse | foreach { gp $_.PSPath } | where DisplayName -eq 'Unified Agent'
$regDriverComponent = gci 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DIFxApp\Components' | foreach { gp $_.PSPath } | Where DriverStore -Like "*bcua*"
$regBCUAClasses = gci 'HKLM:\SOFTWARE\Classes\Installer\Features\' | Where Property -like "*bcua*"
$regAppEntry = gci 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall' | foreach { gp $_.PSPath } | Where DisplayName -eq "Unified Agent"
$regService = "HKLM:\SYSTEM\CurrentControlSet\Services\bcua-service"
$regWFP = "HKLM:\SYSTEM\CurrentControlSet\Services\bcua-wfp"
$regBC = "HKLM:\SOFTWARE\Blue Coat Systems"
$regProgramData = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Installer\Folders"
$regComponent1 = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Installer\UserData\S-1-5-18\Components\1702FCBC0EAA3FE4F966E6D20AAE5186'
$regComponent2 = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Installer\UserData\S-1-5-18\Components\2F0BBE479BF57F54CA5E397E939B9998'
$regComponent3 = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Installer\UserData\S-1-5-18\Components\B1DC94812FAEE4650B036B3C91949C11'
$regComponent4 = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Installer\UserData\S-1-5-18\Components\F9796423B18448D42B32A2CABCE3DF59'

##
# Application directories
##
$dirBCUA = "C:\ProgramData\bcua\"
$dirBlueCoat = "C:\Program Files\Blue Coat Systems\"
$dirBCDriver = "C:\Windows\System32\drivers\bcua-wfp.sys"
$dirBCDrvStore = gci C:\windows\system32\drvstore | Where Name -like "*bcua*"

$timeStamp = Get-Timestamp
Write-Output "$timeStamp Stopping all BlueCoat Services"
Get-Process -name "bcua*" | Stop-Process -Force -Confirm

if (Test-Path $regService)
{
    $timeStamp = Get-Timestamp
    Write-Output "$timeStamp BCUA-Service Key Found. Removing..."
    Remove-Item $regService -Recurse -Force -Verbose
}

if (Test-Path $regWFP)
{
    $timeStamp = Get-Timestamp
    Write-Output "$timeStamp BCUA-WFP Key Found. Removing"
    Remove-Item $regWFP -Recurse -Force -Verbose
}

if (Test-Path $regBC)
{
    $timeStamp = Get-Timestamp
    Write-Output "$timeStamp Blue Coat Key Found. Removing"
    Remove-Item $regBC -Recurse -Force -Verbose
}
if (Test-Path $regBCUAClasses) {
    
    $timeStamp = Get-Timestamp
    Write-Output "$timeStamp Blue Coat installer classes found. Removing"
    Remove-Item ($regBCUAClasses.PSPath) -Recurse -Force -Verbose
}

if (Test-Path $dirBCUA)
{
    $timeStamp = Get-Timestamp
    Write-Output "$timeStamp Found ProgramData\bcua directory. Removing"
    Remove-Item $dirBCUA -Recurse -Force -Verbose
}

try

{
if (Get-ItemProperty -Path $regProgramData -Name $dirBCUA)
{
    $timeStamp = Get-Timestamp
    Write-Output "$timeStamp Found ProgramData\BCUA registry key. Removing"
    Remove-ItemProperty -Path $regProgramData -Name $dirBCUA -Force -Verbose
}
}
catch
{
    $timeStamp = Get-Timestamp
    Write-Output "$timeStamp $regProgramData does not exist"
}

if (Test-Path $dirBlueCoat)
{
    $timeStamp = Get-Timestamp
    Write-Output "$timeStamp Found Blue Coat Program Files Directory. Removing"
    Remove-Item $dirBlueCoat -Recurse -Force -Verbose
}

if (Test-Path $dirBCDriver)
{
    $timeStamp = Get-Timestamp
    Write-Output "$timeStamp Found Blue Coat Driver. Removing"
    Remove-Item $dirBCDriver -Force <#
	===========================================================================
	 Created with:	PowerShell ISE (Win10 17134)
	 Revision:		2018.12.18.01
	 Last Modified:	18 Dec 2018
	 Created by:	Jay Harper (github.com/thecatdidit/powershellusefulscripts)
	 Organizaiton:	Happy Days Are Here Again
	 Filename:		Remove-Unified Agent
	===========================================================================
	.CHANGELOG
		REV. 2018.12.18.01]
		Script initial creation.
	.SYNOPSIS
		This script is designed to manually terminate Blue Coat Unified Agent
		components and remove remnants of the application.
		The intende
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
		
		Steps:
		
		1. 'bcua-service.exe' and 'bcua-notifier.exe' are forcefully terminated
		2. The application's registry entries are deleted
			a. 'bcua-service' Service registration
			b. Remove Write Filter Protection service registration [REGISTRY]
			c. Remove Software entry (e.g. Programs and Features [REGISTRY]
			d. Remove installer Features and Classes [REGISTRY]
			e. Delete installation directly under 'C:\Program Files'
			f. Delete installation folder under 'C:\ProgramData'
			g. Remove files related to Windows driver registration
		Afterward, reboot the system. If desired, ou should be able to install
		whatever BCUA version is needed.
		A log file is created to log details of the agent removal. To set it
		to another directory, update the $logFile variable
	.USAGE
		PS> Remove-UnifiedAgent.ps1
	.INPUTS
		NONE
	.OUTPUTS
		The script with output results of each step to the console. It will also
		store the entirety of the process to a logfile.
	.NOTES
		A forthcoming revision will provide some parameters for 
		settings such as logfile location.
#>



##
# Configure logfile settings and set logfile header
# formatting for easier reference
##
function Get-Timestamp {

Return $(get-date -UFormat "[%a %d %b %y] [%H:%M:%S]:`t")

}

$timeStamp = Get-Timestamp
$logFile = "C:\Temp\BCUA_REMOVAL_LOG_$timeStamp.log"
Start-Transcript -Path $logFile -Force

##
# Set variables for application components
# Registry entries
##
$regDriverStore = gci 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DIFx\DriverStore' -Recurse | foreach { gp $_.PSPath } | where DisplayName -eq 'Unified Agent'
$regDriverComponent = gci 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DIFxApp\Components' | foreach { gp $_.PSPath } | Where DriverStore -Like "*bcua*"
$regBCUAClasses = gci 'HKLM:\SOFTWARE\Classes\Installer\Features\' | Where Property -like "*bcua*"
$regAppEntry = gci 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall' | foreach { gp $_.PSPath } | Where DisplayName -eq "Unified Agent"
$regService = "HKLM:\SYSTEM\CurrentControlSet\Services\bcua-service"
$regWFP = "HKLM:\SYSTEM\CurrentControlSet\Services\bcua-wfp"
$regBC = "HKLM:\SOFTWARE\Blue Coat Systems"
$regProgramData = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Installer\Folders"
$regComponent1 = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Installer\UserData\S-1-5-18\Components\1702FCBC0EAA3FE4F966E6D20AAE5186'
$regComponent2 = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Installer\UserData\S-1-5-18\Components\2F0BBE479BF57F54CA5E397E939B9998'
$regComponent3 = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Installer\UserData\S-1-5-18\Components\B1DC94812FAEE4650B036B3C91949C11'
$regComponent4 = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Installer\UserData\S-1-5-18\Components\F9796423B18448D42B32A2CABCE3DF59'

##
# Application directories
##
$dirBCUA = "C:\ProgramData\bcua\"
$dirBlueCoat = "C:\Program Files\Blue Coat Systems\"
$dirBCDriver = "C:\Windows\System32\drivers\bcua-wfp.sys"
$dirBCDrvStore = gci C:\windows\system32\drvstore | Where Name -like "*bcua*"

$timeStamp = Get-Timestamp
Write-Output "$timeStamp Stopping all BlueCoat Services"
Get-Process -name "bcua*" | Stop-Process -Force -Confirm

if (Test-Path $regService)
{
    $timeStamp = Get-Timestamp
    Write-Output "$timeStamp BCUA-Service Key Found. Removing..."
    Remove-Item $regService -Recurse -Force -Verbose
}

if (Test-Path $regWFP)
{
    $timeStamp = Get-Timestamp
    Write-Output "$timeStamp BCUA-WFP Key Found. Removing"
    Remove-Item $regWFP -Recurse -Force -Verbose
}

if (Test-Path $regBC)
{
    $timeStamp = Get-Timestamp
    Write-Output "$timeStamp Blue Coat Key Found. Removing"
    Remove-Item $regBC -Recurse -Force -Verbose
}
if (Test-Path $regBCUAClasses)

{
    $timeStamp = Get-Timestamp
    Write-Output "$timeStamp Blue Coat installer classes found. Removing"
    Remove-Item ($regBCUAClasses.PSPath) -Recurse -Force -Verbose
}

if (Test-Path $dirBCUA)
{
    $timeStamp = Get-Timestamp
    Write-Output "$timeStamp Found ProgramData\bcua directory. Removing"
    Remove-Item $dirBCUA -Recurse -Force -Verbose -ErrorAction SilentlyContinue
}

try

{
if (Get-ItemProperty -Path $regProgramData -Name $dirBCUA)
{
    $timeStamp = Get-Timestamp
    Write-Output "$timeStamp Found ProgramData\BCUA registry key. Removing"
    Remove-ItemProperty -Path $regProgramData -Name $dirBCUA -Force -Verbose -ErrorAction SilentlyContinue
}
}
catch
{
    $timeStamp = Get-Timestamp
    Write-Output "$timeStamp $regProgramData does not exist"
}

if (Test-Path $dirBlueCoat)
{
    $timeStamp = Get-Timestamp
    Write-Output "$timeStamp Found Blue Coat Program Files Directory. Removing"
    Remove-Item $dirBlueCoat -Recurse -Force -Verbose -ErrorAction SilentlyContinue
}

if (Test-Path $dirBCDriver)
{
    $timeStamp = Get-Timestamp
    Write-Output "$timeStamp Found Blue Coat Driver. Removing"
    Remove-Item $dirBCDriver -Force -Verbose -ErrorAction SilentlyContinue
}

if (Get-Service -Name bcua-service)
{
    $timeStamp = Get-Timestamp
    Write-Output "$timeStamp Service still installed. Removing"
    Stop-Service bcua-service -Force
}
Stop-Transcript
Verbose
}

if (Get-Service -Name bcua-service)
{
    $timeStamp = Get-Timestamp
    Write-Output "$timeStamp Service still installed. Removing"
    Stop-Service bcua-service -Force
}
Stop-Transcript
