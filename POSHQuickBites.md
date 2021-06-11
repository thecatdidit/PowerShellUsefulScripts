## PowerShell Quick Bites
### Get all Windows Updates installed on a machine, output to Grid View for eace of access
```(new-object -com "Microsoft.Update.Searcher").QueryHistory(2,$wu.gettotalhistorycount()) | where Title -Match "KB" | select Date, Title, Description | Out-GridView```

### Get a list of all Automatic services currently Stopped
```Get-Service | select Name, Status, StartType, DisplayName | where StartType -Match "Automatic" | where Status -Match "Stopped"```
