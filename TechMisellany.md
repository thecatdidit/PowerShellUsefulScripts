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

### Check Bitlocker status of system drive, then enable if needed
```if ((Get-BitLockerVolume -MountPoint ($env:windir)[0] | Select-Object -ExpandProperty ProtectionStatus).Value__ -eq 0) { Resume-BitLocker -MountPoint ($env:windir)[0] }```

### Detect Firefox, and uninstall silently if found
```Start-Process(((Get-ChildItem 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall' | select $_.PSPath | Get-ItemProperty) | where DisplayName -Match "Firefox").UninstallString) /S```

### Get a list of installed Windows Updates - output to Grid View
```(new-object -com "Microsoft.Update.Searcher").QueryHistory(0,((new-object -com "Microsoft.Update.Searcher").gettotalhistorycount()-1)) | where Title -Match "KB" | select Title, Description, Date | Out-GridView```

### Detect Chrome, and uninstall silently if found
```Start-process C:\windows\system32\msiexec.exe ((Get-ChildItem 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall' | select $_.PSPath | Get-ItemProperty | where DisplayName -Match "Chrome").UninstallString).split('')[1], '/qn'```

### Third party application download info
* Google Chrome
** https://dl.google.com/dl/chrome/install/googlechromestandaloneenterprise64.msi 

* Firefox (using v64.0 as example)
  * x64: https://download-origin.cdn.mozilla.net/pub/firefox/releases/64.0/win64/en-US/Firefox%20Setup%2064.0.exe
  * x86: https://download-origin.cdn.mozilla.net/pub/firefox/releases/64.0/win32/en-US/Firefox%20Setup%2064.0.exe 

* Notepad++ (using v7.6.1 as example)
 * x64: https://notepad-plus-plus.org/repository/7.x/7.6.1/npp.7.6.1.Installer.x64.exe
 * x86: https://notepad-plus-plus.org/repository/7.x/7.6.1/npp.7.6.1.Installer.x86.exe

### Websites
* https://prajwaldesai.com/
* https://www.anoopcnair.com/
* https://www.systemcenterdudes.com/
* https://ccmexec.com/
* http://www.scconfigmgr.com/
* http://rzander.azurewebsites.net/
* https://deploymentresearch.com/
* https://deploymentbunny.com/
* http://blog.colemberg.ch/
* https://home.configmgrftw.com/blog/
* https://damgoodadmin.com/
* https://www.andersrodland.com/
* https://www.osdeploy.com/
* https://www.enhansoft.com/blog/author/garth
* https://configgirl.com/
* https://setupconfigmgr.com/
* https://www.cvedetails.com/
* https://ruckzuck.tools/
* http://www.mssccm.com/
* https://www.ghacks.net/category/windows/
* https://www.neowin.net/news/tags/microsoft
* https://www.catalog.update.microsoft.com/Home.asp
* https://www.zerodayinitiative.com/blog
