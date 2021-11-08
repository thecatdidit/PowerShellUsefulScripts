# This script will prevent Windows 11 from being foisted upon a Windows 10 workstation
if((Test-Path -LiteralPath "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate") -ne $true) {  New-Item "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" -force -ErrorAction SilentlyContinue };
if((Test-Path -LiteralPath "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU") -ne $true) {  New-Item "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -force -ErrorAction SilentlyContinue };
New-ItemProperty -LiteralPath 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate' -Name 'TargetReleaseVersion' -Value 1 -PropertyType DWord -Force -ErrorAction SilentlyContinue;
New-ItemProperty -LiteralPath 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate' -Name 'ProductVersion' -Value '' -PropertyType String -Force -ErrorAction SilentlyContinue;
New-ItemProperty -LiteralPath 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate' -Name 'TargetReleaseVersionInfo' -Value '21H1' -PropertyType String -Force -ErrorAction SilentlyContinue;
