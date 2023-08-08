<#
    .NOTES
	===========================================================================
	 Created with:   PowerShell ISE (Win10 19042)
	 Revision:       v3
	 Last Modified:  14 July 2021
	 Created by:     Jay Harper (jayharper@gmail.com)
	 Filename:       Uninstall-BlueCoatUnifiedAgent.ps1
	===========================================================================
    .CHANGELOG
        [08 Aug 2023]
	Formatting and grammar cleanup of some comments
	[14 Jul 2021]
	Cleaned up script formatting
    .SYNOPSIS
        This script forces a manual uninstall of Blue Coat Unified Agent. The process
        is based upon Symantec's official HOWTO for removing the agent. 
    .DESCRIPTION
        This script has been tested on the following versions of Unified Agent (x64):
        4.7.6.198155
        4.8.0.201333
        4.8.3.203405
        4.9.1.208066
        4.9.4.212024
        4.10.1.219990
        
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
    .EXAMPLE
        PS C:\> Uninstall-BlueCoatUnifiedAgent.ps1
    .INPUTS
        NONE
    .OUTPUTS
        The script will output the results of each step to the console. It will also
        store the entirety of the process to a logfile.
    .NOTES
        This was a need-based script. I am no longer in the sphere of BCUA. YMMV
#>

##
# Configure logfile settings
# Create readble logfile headers
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
$regDriverStore = Get-ChildItem 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DIFx\DriverStore' -Recurse | foreach { Get-ItemProperty $_.PSPath } | where DisplayName -eq 'Unified Agent'
$regDriverComponent = Get-ChildItem 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DIFxApp\Components' | foreach { Get-ItemProperty $_.PSPath } | Where DriverStore -Like "*bcua*"
$regBCUAClasses = Get-ChildItem 'HKLM:\SOFTWARE\Classes\Installer\Features\' | Where Property -like "*bcua*"
$regAppEntry = Get-ChildItem 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall' | foreach { Get-ItemProperty $_.PSPath } | Where DisplayName -eq "Unified Agent"
$regAppEntry2 = Get-ChildItem 'HKCR:\installer\products' -Recurse | foreach { Get-ItemProperty $_.PSPath } | Where ProductName -Match "Unified Agent"
$regAppEntry3 = Get-ChildItem 'HKLM:\SOFTWARE\Classes\installer\Products' | % { Get-ItemProperty $_.PSPath } | Where ProductName -Match "Unified Agent"
$regService = "HKLM:\SYSTEM\CurrentControlSet\Services\bcua-service"
$regService2 = "HKLM:\SYSTEM\ControlSet001\Services\bcua-service"
$regWFP = "HKLM:\SYSTEM\CurrentControlSet\Services\bcua-wfp"
$regWFP2 = "HKLM:\SYSTEM\ControlSet001\Services\bcua-wfp"
$regBC = "HKLM:\SOFTWARE\Blue Coat Systems"
$reGet-ItemPropertyrogramData = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Installer\Folders"
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
$dirBCDrvStore = Get-ChildItem C:\windows\system32\drvstore | Where Name -like "*bcua*" -ErrorAction SilentlyContinue
    
##
#Force stop 'bcua-service.exe' and 'bcua-notifier.exe'
##
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
    if (Get-ItemProperty -Path $reGet-ItemPropertyrogramData -Name $dirBCUA -ErrorAction SilentlyContinue) {
        $timeStamp = Get-Timestamp
        Write-Output "$timeStamp Found ProgramData\BCUA registry key. Removing"
        Remove-ItemProperty -Path $reGet-ItemPropertyrogramData -Name $dirBCUA -Force -Verbose -ErrorAction SilentlyContinue
    }
}
    
catch {
    $timeStamp = Get-Timestamp
    Write-Output "$timeStamp $reGet-ItemPropertyrogramData does not exist"
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
