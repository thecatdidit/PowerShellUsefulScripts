# Tech Miscellany

## PowerShell
### Query for installed applications (x64)
```Get-ChildItem -Name "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\" | foreach { Get-ItemProperty $_.PSPath }```

### Query for installed applications x86)
```Get-ChildItem -Name "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\" | foreach { Get-ItemProperty $_.PSPath }```

### Active Directory users who haven't reset their password after X days
```Get-ADUser -Filter 'Enabled -eq $True' -Properties PasswordLastSet, PasswordNeverExpires | Where-Object {($_.PasswordLastSet -lt (Get-Date).adddays(0-$MinimumDays) -and ($_.PasswordLastSet -gt (Get-Date).adddays(0-$MaximumDays)))}| select Name,SamAccountName,PasswordLastSet, PasswordNeverExpires```

### AD Replication info from a remote server, and place the results in a text file
```Start-Process -FilePath C:\temp\PsExec64.exe -WindowStyle Hidden -RedirectStandardOutput "C:\temp\ad2.txt" -ArgumentList "\\REMOTE_SYSTEM_NAME_HERE `"C:\windows\system32\repadmin`" /replsummary"```

### Windows Server TLS 1.2 fix for SCHANNEL errors
```# Reg2CI (c) 2021 by Roger Zander
if((Test-Path -LiteralPath "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2") -ne $true) {  New-Item "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2" -force -ea SilentlyContinue };
if((Test-Path -LiteralPath "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Client") -ne $true) {  New-Item "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Client" -force -ea SilentlyContinue };
if((Test-Path -LiteralPath "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Server") -ne $true) {  New-Item "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Server" -force -ea SilentlyContinue };
New-ItemProperty -LiteralPath 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Client' -Name 'DisabledByDefault' -Value 0 -PropertyType DWord -Force -ea SilentlyContinue;
New-ItemProperty -LiteralPath 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Client' -Name 'Enabled' -Value 1 -PropertyType DWord -Force -ea SilentlyContinue;
New-ItemProperty -LiteralPath 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Server' -Name 'DisabledByDefault' -Value 0 -PropertyType DWord -Force -ea SilentlyContinue;
New-ItemProperty -LiteralPath 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Server' -Name 'Enabled' -Value 1 -PropertyType DWord -Force -ea SilentlyContinue;

if((Test-Path -LiteralPath "HKLM:\SOFTWARE\Microsoft\.NETFramework\v4.0.30319") -ne $true) {  New-Item "HKLM:\SOFTWARE\Microsoft\.NETFramework\v4.0.30319" -force -ea SilentlyContinue };
if((Test-Path -LiteralPath "HKLM:\SOFTWARE\Wow6432Node\Microsoft\.NETFramework\v4.0.30319") -ne $true) {  New-Item "HKLM:\SOFTWARE\Wow6432Node\Microsoft\.NETFramework\v4.0.30319" -force -ea SilentlyContinue };
New-ItemProperty -LiteralPath 'HKLM:\SOFTWARE\Microsoft\.NETFramework\v4.0.30319' -Name 'SystemDefaultTlsVersions' -Value 1 -PropertyType DWord -Force -ea SilentlyContinue;
New-ItemProperty -LiteralPath 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\.NETFramework\v4.0.30319' -Name 'SystemDefaultTlsVersions' -Value 1 -PropertyType DWord -Force -ea SilentlyContinue;
```

### Install Chocolatey from web
```Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))```
