# This script automatically calls 'Disable-Windows11.ps1' from the PowerShell Useful Scripts repository, then applies it to the machine
Set-ExecutionPolicy Bypass -Scope Process -Force
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
iex ((New-Object System.Net.WebClient).DownloadString(' https://raw.githubusercontent.com/thecatdidit/PowerShellUsefulScripts/master/Disable-Windows11.ps1 '))
