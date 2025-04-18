<# This script searches for Intel Wifi adapters on a system, and it sets the preferred wifi band to 5GHz. I will get this formalized in my template soon -JH 020322 
   Full credit for this script goes to https://www.theictguy.co.uk/set-intel-wi-fi-preferred-band-via-script/
#>

Get-ChildItem HKLM:\SYSTEM\CurrentControlSet\Control\Class -Recurse -ErrorAction silentlyContinue | Get-ItemProperty | ForEach-Object {if  ($_.RoamingPreferredBandType -ge 0) {
    $path = $_.pspath
    Set-ItemProperty $path -name "RoamingPreferredBandType" -Value "2"
    write-output $_.pspath
    }
}
