## PowerShell Quick Bites
### Get all Windows Updates installed on a machine, output to Grid View for eace of access
```(new-object -com "Microsoft.Update.Searcher").QueryHistory(2,$wu.gettotalhistorycount()) | where Title -Match "KB" | select Date, Title, Description | Out-GridView```

### Get a list of all Automatic services currently Stopped
```Get-Service | select Name, Status, StartType, DisplayName | where StartType -Match "Automatic" | where Status -Match "Stopped"```

### Get a list of all x64 applications installed
```(Get-ChildItem 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall' |  select $_.PSPath | Get-ItemProperty) | select DisplayName, InstallDate, UninstallString```

### Get information on the latest version of Firefox
```(Invoke-WebRequest -Uri "https://product-details.mozilla.org/1.0/firefox_versions.json" -UseBasicParsing | ConvertFrom-json) | select LAST_RELEASE_DATE, LATEST_FIREFOX_VERSION```
