#This will download the latest version of the HP Script Library, Install it and confirm it's installed.

[CmdletBinding()]
    Param (
		    #Download to Server Share or Local Temp (Probably Local temp if you're going to install)
            [Parameter(Mandatory=$true,Position=1,HelpMessage="Run Method")]
            [ValidateNotNullOrEmpty()]
            [ValidateSet("Local", "Server")]
		    $RunMethod = "Local",
		    
            #Install will Install, otherwise it will download only
            [Parameter(Mandatory=$true,Position=1,HelpMessage="Install App")]
            [ValidateNotNullOrEmpty()]
            [ValidateSet($true, $false)]
		    $Install = $false
 	    )

#Borrowed from internet... this was the only way I was able to "query" if it was installed.
Function Get-Software  {
  [OutputType('System.Software.Inventory')]
  [Cmdletbinding()] 
  Param( 
  [Parameter(ValueFromPipeline=$True,ValueFromPipelineByPropertyName=$True)] 
  [String[]]$Computername=$env:COMPUTERNAME
  )         
  Begin {
  }
  Process  {     
  ForEach  ($Computer in  $Computername){ 
  If  (Test-Connection -ComputerName  $Computer -Count  1 -Quiet) {
  $Paths  = @("SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Uninstall","SOFTWARE\\Wow6432node\\Microsoft\\Windows\\CurrentVersion\\Uninstall")         
  ForEach($Path in $Paths) { 
  Write-Verbose  "Checking Path: $Path"
  #  Create an instance of the Registry Object and open the HKLM base key 
  Try  { 
  $reg=[microsoft.win32.registrykey]::OpenRemoteBaseKey('LocalMachine',$Computer,'Registry64') 
  } Catch  { 
  Write-Error $_ 
  Continue 
  } 
  #  Drill down into the Uninstall key using the OpenSubKey Method 
  Try  {
  $regkey=$reg.OpenSubKey($Path)  
  # Retrieve an array of string that contain all the subkey names 
  $subkeys=$regkey.GetSubKeyNames()      
  # Open each Subkey and use GetValue Method to return the required  values for each 
  ForEach ($key in $subkeys){   
  Write-Verbose "Key: $Key"
  $thisKey=$Path+"\\"+$key 
  Try {  
  $thisSubKey=$reg.OpenSubKey($thisKey)   
  # Prevent Objects with empty DisplayName 
  $DisplayName =  $thisSubKey.getValue("DisplayName")
  If ($DisplayName  -AND $DisplayName  -notmatch '^Update  for|rollup|^Security Update|^Service Pack|^HotFix') {
  $Date = $thisSubKey.GetValue('InstallDate')
  If ($Date) {
  Try {
  $Date = [datetime]::ParseExact($Date, 'yyyyMMdd', $Null)
  } Catch{
  Write-Warning "$($Computer): $_ <$($Date)>"
  $Date = $Null
  }
  } 
  # Create New Object with empty Properties 
  $Publisher =  Try {
  $thisSubKey.GetValue('Publisher').Trim()
  } 
  Catch {
  $thisSubKey.GetValue('Publisher')
  }
  $Version = Try {
  #Some weirdness with trailing [char]0 on some strings
  $thisSubKey.GetValue('DisplayVersion').TrimEnd(([char[]](32,0)))
  } 
  Catch {
  $thisSubKey.GetValue('DisplayVersion')
  }
  $UninstallString =  Try {
  $thisSubKey.GetValue('UninstallString').Trim()
  } 
  Catch {
  $thisSubKey.GetValue('UninstallString')
  }
  $InstallLocation =  Try {
  $thisSubKey.GetValue('InstallLocation').Trim()
  } 
  Catch {
  $thisSubKey.GetValue('InstallLocation')
  }
  $InstallSource =  Try {
  $thisSubKey.GetValue('InstallSource').Trim()
  } 
  Catch {
  $thisSubKey.GetValue('InstallSource')
  }
  $HelpLink = Try {
  $thisSubKey.GetValue('HelpLink').Trim()
  } 
  Catch {
  $thisSubKey.GetValue('HelpLink')
  }
  $Object = [pscustomobject]@{
  Computername = $Computer
  DisplayName = $DisplayName
  Version  = $Version
  InstallDate = $Date
  Publisher = $Publisher
  UninstallString = $UninstallString
  InstallLocation = $InstallLocation
  InstallSource  = $InstallSource
  HelpLink = $thisSubKey.GetValue('HelpLink')
  EstimatedSizeMB = [decimal]([math]::Round(($thisSubKey.GetValue('EstimatedSize')*1024)/1MB,2))
  }
  $Object.pstypenames.insert(0,'System.Software.Inventory')
  Write-Output $Object
  }
  } Catch {
  Write-Warning "$Key : $_"
  }   
  }
  } Catch  {}   
  $reg.Close() 
  }                  
  } Else  {
    Write-Error  "$($Computer): unable to reach remote system!"
}
} 
} 
}  

#region: CMTraceLog Function formats logging in CMTrace style
        function CMTraceLog {
         [CmdletBinding()]
    Param (
		    [Parameter(Mandatory=$false)]
		    $Message,
 
		    [Parameter(Mandatory=$false)]
		    $ErrorMessage,
 
		    [Parameter(Mandatory=$false)]
		    $Component = "HP Script Library Installer",
 
		    [Parameter(Mandatory=$false)]
		    [int]$Type,
		
		    [Parameter(Mandatory=$true)]
		    $LogFile
	    )
    <#
    Type: 1 = Normal, 2 = Warning (yellow), 3 = Error (red)
    #>
	    $Time = Get-Date -Format "HH:mm:ss.ffffff"
	    $Date = Get-Date -Format "MM-dd-yyyy"
 
	    if ($ErrorMessage -ne $null) {$Type = 3}
	    if ($Component -eq $null) {$Component = " "}
	    if ($Type -eq $null) {$Type = 1}
 
	    $LogMessage = "<![LOG[$Message $ErrorMessage" + "]LOG]!><time=`"$Time`" date=`"$Date`" component=`"$Component`" context=`"`" type=`"$Type`" thread=`"`" file=`"`">"
	    $LogMessage | Out-File -Append -Encoding UTF8 -FilePath $LogFile
    }

$URL = "https://ftp.hp.com/pub/caps-softpaq/cmit/release/cmsl/hp-cmsl-latest.exe"
$XMLURL = "ftp://ftp.hp.com/pub/caps-softpaq/cmit/release/cmsl/hpcmsl.xml"
$XMLPath = "$PSScriptRoot\hpcmsl.xml"
$LogFile = "$($env:Temp)\HPScriptLibInstaller.log"
$HPScriptLibVer = $null
$scriptName = $MyInvocation.MyCommand.Name

#Set Download location based on Param (Local or Server)
if ($RunMethod -eq "Server"){$DownloadPath = "\\src\src$\Apps\HP\HPScriptLibrary"}
if ($RunMethod -eq "Local"){$DownloadPath = $env:TEMP}

# Future Code for when I have it update the Application in CM
#if  (Test-Path 'C:\Program Files (x86)\Microsoft Configuration Manager\AdminConsole\bin'){Import-Module 'C:\Program Files (x86)\Microsoft Configuration Manager\AdminConsole\bin\ConfigurationManager.psd1'}
#$SiteCode = "PS2"

CMTraceLog -Message "----- Started Script: $scriptName -----" -Type 1 -LogFile $LogFile

# Download HP XML

if ((Test-NetConnection proxy-garytown.com -Port 8080).PingSucceeded -eq $True)
    {
    $UseProxy = $true
    CMTraceLog -Message "Found Proxy Server, using for Downloads" -Type 1 -LogFile $LogFile
    Write-Output "Found Proxy Server, using for Downloads"
    $ProxyServer = "http://proxy-garytown.com:8080"
    $BitsProxyList = @("192.168.1.176:8080, 168.33.22.169:8080, 111.222.214.218.21:8080")
    }
Else 
    {
    $ProxyServer = $null
    CMTraceLog -Message "No Proxy Server Found, continuing without" -Type 1 -LogFile $LogFile
    Write-Output "No Proxy Server Found, continuing without"
    }

If(Test-Path $XMLPath){Remove-Item -Path $XMLPath -Force -Verbose}
Invoke-WebRequest -Uri $XMLURL -OutFile $XMLPath -UseBasicParsing -Verbose -Proxy $ProxyServer
[int32]$n=1
While(!(Test-Path $XMLPath) -and $n -lt '3')
    {
    Invoke-WebRequest -Uri $XMLURL -OutFile $XMLPath -UseBasicParsing -Verbose -Proxy $ProxyServer
    $n++
    }

[xml]$XML = Get-Content $XMLPath -Verbose
$Packages = $XML.'hp-update-catalog'.product.package
$LatestVersion = ($Packages | Measure-Object -Property "Version" -Maximum).Maximum
$LatestPackage = $Packages | Where-Object -FilterScript {$PSitem.Version -eq $LatestVersion}
$LatestFileName = $LatestPackage.url.Split('/')[-1]
$LatestFileDownloadPath = "$($DownloadPath)\$($LatestVersion)\$($LatestFileName)"

#Check if already installed.. and if current
if ($Install -eq $true)
    {
    $Software = Get-Software
    $HPScriptLib = $Software | Where-Object -FilterScript {$_.DisplayName -eq "HP Client Management Script Library"}
    if ($HPScriptLib -ne $null){$HPScriptLibVer = $HPScriptLib.version.substring(0,5)}
    
    if ($HPScriptLibVer -eq $LatestVersion)
        {
        Write-Output "Already Current running version $($HPScriptLibVer)"
        CMTraceLog -Message "Already Current running version $($HPScriptLibVer)" -Type 1 -LogFile $LogFile
        $AlreadyCurrent = $true
        }
    else
        {
        Write-Output "Does not have the Current Version $($LatestVersion) Installed"
        CMTraceLog -Message "Does not have the Current Version $($LatestVersion) Installed" -Type 1 -LogFile $LogFile
        $AlreadyCurrent = $false
        }
    }

#Check if Donwloaded already, if not.. download it
if (($Install -eq $true -and $AlreadyCurrent -ne $true) -or $Install -eq $false)
    {
    if (Test-Path $LatestFileDownloadPath) 
        {
        Write-Output "Already have Latest Version Downloaded"
        CMTraceLog -Message "Already have Latest Version Downloaded" -Type 1 -LogFile $LogFile
        }
    else
        {
        New-Item -Path "$($DownloadPath)\$($LatestVersion)" -ItemType Directory -Force
        CMTraceLog -Message "Downloading ver $($LatestVersion) to $($DownloadPath)" -Type 1 -LogFile $LogFile
        Write-Output "Downloading ver $($LatestVersion) to $($DownloadPath)"
        Invoke-WebRequest -Uri $LatestPackage.url -OutFile $LatestFileDownloadPath -UseBasicParsing -Verbose -Proxy $ProxyServer
        [int32]$n=1
        While(!(Test-Path $LatestFileDownloadPath) -and $n -lt '3')
            {
            Invoke-WebRequest -Uri $LatestPackage.url -OutFile $LatestFileDownloadPath -UseBasicParsing -Verbose -Proxy $ProxyServer
            $n++
            }
         
        }
    }




#Install the Software

if ($Install -eq $true -and $AlreadyCurrent -ne $true)
    {
    CMTraceLog -Message "Triggering Installer: $($LatestFileName) $($LatestPackage.silentuninstall)" -Type 1 -LogFile $LogFile
    Write-Output "Triggering Installer: $($LatestFileName) $($LatestPackage.silentuninstall)"
    Start-Process $LatestFileDownloadPath -ArgumentList "$($LatestPackage.silentinstall)" -Wait
    $Software = Get-Software
    $HPScriptLib = $Software | Where-Object -FilterScript {$_.DisplayName -eq "HP Client Management Script Library"}
    $HPScriptLibVer = $HPScriptLib.version.substring(0,5)
    if ($HPScriptLibVer -eq $LatestVersion)
        {
        Write-Output "Installation Successful"
        CMTraceLog -Message "Installation Successful" -Type 1 -LogFile $LogFile
        }
    Else
        {
        Write-Output "Installation FAILED"
        CMTraceLog -Message "Installation FAILED" -Type 1 -LogFile $LogFile
        }
    }

#Uninstall Command: Start-Process -FilePath $($HPScriptLib.UninstallString) -ArgumentList $($LatestPackage.silentuninstall) -wait

<#Future work on updating the AppModel App in CM.
$AppModelVersion = $LatestVersion
$AppModelSilentInstall = "$LatestFileName $($LatestPackage.silentinstall)"
$AppModelSilentUninstall = "$($HPScriptLib.UninstallString) $($LatestPackage.silentuninstall)"
$AppModelDetectionMethod = "" #Still working on.
#>

 
   CMTraceLog -Message "----- Finished Script: $scriptName -----" -Type 1 -LogFile $LogFile