<#    
      .NOTES
===========================================================================
      Created with:      PowerShell ISE (17134)
      Revision:          v5
      Last Modified:     20 Mar 2019
      Created by:        Jay Harper (jharper@benefitfocus.com)
      Organizaiton:      BenefitFocus, Inc.
      Filename:          Get-SCCMDailyInfo_v6
===========================================================================
      .DESCRIPTION
             This script is an enhancewment and extension on the original script that
        queried for third party application news. Queries for 3PUP are now being
        directly from the vendor to avoid error and delay.
 
        There will also be some future improvements, including:
 
        * A listing of all current Windows to (Targeted) Build versions
 
        * Current month Security Update KB for each Win10 Build along with statistics
#>
 
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$tabName = "Third Party Software"
#Create Table object
$table = New-Object system.Data.DataTable "$tabName"
 
#Define Columns
$col1 = New-Object system.Data.DataColumn Software
$col2 = New-Object system.Data.DataColumn Version
$col3 = New-Object system.Data.DataColumn DateAdded
$col4 = New-Object system.Data.DataColumn DownloadURL
#Add the Columns
$table.columns.add($col1)
$table.columns.add($col2)
$table.columns.add($col3)
$table.columns.add($col4)
 
#Create a row
$row = $table.NewRow()
 
 
function Get-OnlineVerPostman
{
    [cmdletbinding()]
    param (
        [Parameter(Mandatory=$false,
                   Position=0)]
        [switch]
        $Quiet
    )
 
    begin
    {
        # Initial Variables
        $SoftwareName = 'Postman'
        $URI = 'https://dl.pstmn.io/changelog?channel=stable&platform=win'
            
        $hashtable = [ordered]@{
            'Software_Name'    = $softwareName
            'Software_URL'     = $uri
            'Online_Version'   = 'UNKNOWN' 
            'Online_Date'      = 'UNKNOWN'
            'Download_URL_x64' = 'UNKNOWN'
        }
   
        $swObject = New-Object -TypeName PSObject -Property $hashtable
}
 
 
   Process
    {
        # Get the Version & Release Date
        try
        {
 
        $postmanDetails = (Invoke-WebRequest $uri -UseBasicParsing | ConvertFrom-Json)
        $postmanVersion = $postmanDetails.changelog[0].name
        $postmanDate = $postmandetails.changelog[0].createdAt.Substring(0,10)
        $postmanDownload = $postmanDetails.changelog[0].assets.url
        $postmanDateFix = [datetime]::ParseExact($postmanDate,'yyyy-MM-dd', $null)
            
        $swObject.Online_Date = $postmanDateFix.ToString('MMMM dd, yyyy')
        $swObject.Online_Version = $postmanVersion
        $swObject.Download_URL_x64 = $postmanDownload
         }
        catch
        {
            Write-Verbose -Message "Error accessing the below URL: `n $URI"
            $message = $("Line {0} : {1}" -f $_.InvocationInfo.ScriptLineNumber, $_.exception.message)
            $swObject | Add-Member -MemberType NoteProperty -Name 'ERROR' -Value $message
        }
        finally
        {
  
    }
    }
    End
    {
        # Output to Host
        if ($Quiet)
        {
            Write-Verbose -Message '$Quiet was specified. Returning just the version'
            Return $swObject.Online_Version
        }
        else
        {
            Return $swobject
        }
    }
}  # END Function Get-OnlineVerPostman
$postman = Get-OnlineVerPostman
$row = $table.NewRow()
$softwareName = $postman.Software_Name
$softwareDate = $postman.Online_Date
$softwareVersion = $postman.Online_Version
$downloadURl = $postman.Download_URL_x64
 
$row.Software = [string]$softwareName
$row.Version = $softwareVersion
$row.DateAdded = $softwareDate
$row.DownloadURL = $downloadURl
$table.Rows.Add($row)
 
function Get-OnlineVerGoogleChrome
{
    [cmdletbinding()]
    param (
        [Parameter(Mandatory=$false, 
                   Position=0)]
        [switch]
        $Quiet
    )

    begin
    {
        # Initial Variables
        $SoftwareName = 'GoogleChrome'
        $URI = 'http://feeds.feedburner.com/GoogleChromeReleases'
            
        $hashtable = [ordered]@{
            'Software_Name'    = $softwareName
            'Software_URL'     = $uri
            'Online_Version'   = 'UNKNOWN' 
            'Online_Date'      = 'UNKNOWN'
            'Download_URL_x86' = 'UNKNOWN'
            'Download_URL_x64' = 'UNKNOWN'
        }
    
        $swObject = New-Object -TypeName PSObject -Property $hashtable
    }


   Process
    {
        # Get the Version & Release Date
        try
        {
            Write-Verbose -Message "Attempting to pull info from the below URL: `n $URI"
            $uri = 'http://feeds.feedburner.com/GoogleChromeReleases'
            $rawReq = Invoke-WebRequest -Uri $URI -UseBasicParsing
            [xml]$strReleaseFeed = Invoke-webRequest $uri -UseBasicParsing
            [string]$version = ($strReleaseFeed.feed.entry | Where-object{$_.title.'#text' -match 'Stable'}).content | Select-Object{$_.'#text'} | Where-Object{$_ -match 'Windows'} | ForEach{[version](($_ | Select-string -allmatches '(\d{1,4}\.){3}(\d{1,4})').matches | select-object -first 1 -expandProperty Value)} | Sort-Object -Descending | Select-Object -first 1
            $releaseDate = ($strReleaseFeed.feed.entry | Where-object{$_.title.'#text' -match 'Stable'} | select -First 1).published
            $releaseDate = $releaseDate.Substring(0,10) 

            $swObject.Online_Version = $version
            $swObject.Online_Date = $releaseDate

        }
        catch
        {
            Write-Verbose -Message "Error accessing the below URL: `n $URI"
            $message = $("Line {0} : {1}" -f $_.InvocationInfo.ScriptLineNumber, $_.exception.message)
            $swObject | Add-Member -MemberType NoteProperty -Name 'ERROR' -Value $message
        }
        finally
        {
          

        # Get the Download URLs
        if ($swObject.Online_Version -ne 'UNKNOWN')
        {
            $simpleVer = $version.Replace('.','')
            $swObject.Download_URL_x86 = "https://dl.google.com/dl/chrome/install/googlechromestandaloneenterprise64.msi"
            $swObject.Download_URL_x64 = "https://dl.google.com/dl/chrome/install/googlechromestandaloneenterprise.msi"
        }
    }
    }
    End
    {
        # Output to Host
        if ($Quiet)
        {
            Write-Verbose -Message '$Quiet was specified. Returning just the version'
            Return $swObject.Online_Version
        }
        else
        {
            Return $swobject
        }
    }
}  # END Function Get-OnlineVerGoogleChrome
$googleChrome = Get-OnlineVerGoogleChrome
$row = $table.NewRow()
 
$softwareName = "Google Chrome"
$softwareDate = $googleChrome.Online_Date
$softwareVersion = $googleChrome.Online_Version
$downloadURl = $googleChrome.Download_URL_x64
 
$row.Software = [string]$softwareName
$row.Version = $softwareVersion
$row.DateAdded = $softwareDate
$row.DownloadURL = $downloadURl
$table.Rows.Add($row)
 
<#
	===========================================================================
	 Created with: 	Visual Studio Code 1.32.3/PS ISE 17763
	 Revision:      v1
	 Last Modified: 27 March 2019
	 Created by:   	Jay Harper (github.com/thecatdidit/powershellusefulscripts)
	 Organizaiton: 	Happy Days Are Here Again
	 Filename:     	Get-OnlineVer7Zip.ps1
	===========================================================================
	.CHANGELOG
	[2019.03.27.01]
	Script creation
	.SYNOPSIS
        Queries the 7Zip webside for the current version of
        the app and returns the version, date updated, and
        download URLs if available.
	.DESCRIPTION
	    This function retrieves the latest data associated with 7Zip
        Invoke-WebRequest queries the site to obtain app release date, version and 
        download URLs. This includes x86 and x64.
        It then outputs the information as a
        PSObject to the Host

        App Site: https://www.7-zip.org/

	.EXAMPLE
        PS C:\> Get-OnlineVer7Zip

        Software_Name    : 7Zip
        Software_URL     : https://www.7-zip.org/download.html
        Online_Version   : 19.00
        Online_Date      : 2019-02-21
        Download_URL_x64 : https://www.7-zip.org/a/7z1900-x64.msi
        Download_URL_x86 : https://www.7-zip.org/a/7z1900.msi
    
       	PS C:\> Get-OnlineVer7Zip -Quiet
       	19.00
 
 	.INPUTS
        -Quiet
            Use of this parameter will output just the current version of
            Flash Player instead of the entire object. It will always be the
            last parameter
	    
	.OUTPUTS
            An object containing the following:
            Software Name: Name of the software
            Software URL: The URL info was sourced from
            Online Version: The current version found
            Online Date: The date the version was updated
            Download URL x64: Direct download link for the x64 version
            Download URL x86: Direct download link for the x86 version
    
            If -Quiet is specified then just the value of 'Online Version'
            will be displayed.
	.NOTES
            Resources/Credits:
            https://github.com/itsontheb
#>

function Get-OnlineVer7Zip
{
    [cmdletbinding()]
    param (
        [Parameter(Mandatory=$false, 
                   Position=0)]
        [switch]
        $Quiet
    )

    begin
    {
        # Initial Variables
        $SoftwareName = '7Zip'
        $URI = 'https://www.7-zip.org/download.html'
            
        $hashtable = [ordered]@{
            'Software_Name'    = $softwareName
            'Software_URL'     = $uri
            'Online_Version'   = 'UNKNOWN' 
            'Online_Date'      = 'UNKNOWN'
            'Download_URL_x86' = 'UNKNOWN'
            'Download_URL_x64' = 'UNKNOWN'
        }
    
        $swObject = New-Object -TypeName PSObject -Property $hashtable
    }


   Process
    {
        # Get the Version & Release Date
        try
        {
            Write-Verbose -Message "Attempting to pull info from the below URL: `n $URI"
            $uri = 'https://www.7-zip.org/download.html'
            $7ZipURL = (curl -Uri $uri| Select-Object -ExpandProperty Content)
            $7ZIPURL -match "<P><B>Download 7-Zip (?<version>.*) \((?<date>.*)\) f" | Out-Null
            $7ZipVersion = ($matches['version'])
            $7ZipDate = ($matches['date'])
            
            $swObject.Online_Version = $7ZipVersion
            $swObject.Online_Date = $7ZipDate

        }
        catch
        {
            Write-Verbose -Message "Error accessing the below URL: `n $URI"
            $message = $("Line {0} : {1}" -f $_.InvocationInfo.ScriptLineNumber, $_.exception.message)
            $swObject | Add-Member -MemberType NoteProperty -Name 'ERROR' -Value $message
        }
        finally
        {
          

        # Get the Download URLs
        if ($swObject.Online_Version -ne 'UNKNOWN')
        {
       
            $7ZipDownloadx64 = "https://www.7-zip.org/a/7z"+$7ZipVersion.replace(".","")+"-x64.msi"
            $7ZipDownloadx86 = "https://www.7-zip.org/a/7z"+$7ZipVersion.replace(".","")+".msi"
            
            
            $swObject.Download_URL_x86 = $7ZipDownloadx86
            $swObject.Download_URL_x64 = $7ZipDownloadx64
        }
    }
    }
    End
    {
       # Output to Host
        if ($Quiet)
        {
            Write-Verbose -Message '$Quiet was specified. Returning just the version'
            Return $swObject.Online_Version
        }
        else
        {
            Return $swobject
        }
    }
}  # END Function Get-OnlineVer7Zip

$7zip = Get-OnlineVer7Zip
$row = $table.NewRow()
 
$softwareName = "7Zip"
$softwareDate = $7Zip.Online_Date
$softwareVersion = $7Zip.Online_Version
$downloadURl = $7Zip.Download_URL_x64
 
$row.Software = [string]$softwareName
$row.Version = $softwareVersion
$row.DateAdded = $softwareDate
$row.DownloadURL = $downloadURl
$table.Rows.Add($row)
 
function Get-OnlineVerNotepadPlusPlus
{
    [cmdletbinding()]
    param (
        [Parameter(Mandatory=$false,
                   Position=0)]
        [switch]
        $Quiet
    )
 
    begin
    {
        # Initial Variables
        $SoftwareName = 'NotepadPlusPlus'
        $URI = 'https://notepad-plus-plus.org/download'
           
        $hashtable = [ordered]@{
            'Software_Name'    = $softwareName
            'Software_URL'     = $uri
            'Online_Version'   = 'UNKNOWN'
            'Online_Date'      = 'UNKNOWN'
            'Download_URL_x86' = 'UNKNOWN'
            'Download_URL_x64' = 'UNKNOWN'
        }
   
        $swObject = New-Object -TypeName PSObject -Property $hashtable
    }
 
 
   Process
    {
        # Get the Version & Release Date
        try
        {
            Write-Verbose -Message "Attempting to pull info from the below URL: `n $URI"
            $uri = 'https://notepad-plus-plus.org/download'
            $nppURL = (curl -Uri $uri| Select-Object -ExpandProperty Content)
            $nppURL -match "<title>Notepad\+\+ v(?<content>.*) - Current Version</title>"  | Out-Null
            $nppVersion = ($matches['content'])
            $nppURL -match "<p>Release Date: (?<content>.*)</p>" | Out-Null
            $nppDate = ($matches['content'])
            $nppDateFix = [datetime]::ParseExact($nppDate,'yyyy-MM-dd', $null)
            
            $swObject.Online_Date = $nppDateFix.ToString('MMMM dd, yyyy') 
            $swObject.Online_Version = $nppVersion
           
        }
        catch
        {
            Write-Verbose -Message "Error accessing the below URL: `n $URI"
            $message = $("Line {0} : {1}" -f $_.InvocationInfo.ScriptLineNumber, $_.exception.message)
            $swObject | Add-Member -MemberType NoteProperty -Name 'ERROR' -Value $message
        }
        finally
        {
         
 
        # Get the Download URLs
        if ($swObject.Online_Version -ne 'UNKNOWN')
        {
       
            $nppDownloadx86 = "https://notepad-plus-plus.org/repository/"+$nppVersion[0]+".x/"+$nppVersion+"/"+"npp."+$nppVersion+".Installer.x86.exe"
            $nppDownloadx64 = "https://notepad-plus-plus.org/repository/"+$nppVersion[0]+".x/"+$nppVersion+"/"+"npp."+$nppVersion+".Installer.x64.exe"
           
            $swObject.Download_URL_x86 = $nppDownloadx86
            $swObject.Download_URL_x64 = $nppDownloadx64
        }
    }
    }
    End
    {
       # Output to Host
        if ($Quiet)
        {
            Write-Verbose -Message '$Quiet was specified. Returning just the version'
            Return $swObject.Online_Version
        }
        else
        {
            Return $swobject
        }
    }
} #End Get-OnlineVerNotepadPlusPlus

$npp = Get-OnlineVerNotepadPlusPlus
$row = $table.NewRow()
 
$softwareName = "Notepad++"
$softwareDate = $npp.Online_Date
$softwareVersion = $npp.Online_Version
$downloadURl = $npp.Download_URL_x64
 
$row.Software = [string]$softwareName
$row.Version = $softwareVersion
$row.DateAdded = $softwareDate
$row.DownloadURL = $downloadURl
$table.Rows.Add($row)
 
<#	
	.NOTES
	===========================================================================
	 Created with: 	PowerShell ISE (Win10 17134)
	 Revision:		v5
	 Last Modified: 24 August 2018
	 Created by:   	Jay Harper (github.com/thecatdidit/powershellusefulscripts)
	 Organizaiton: 	Happy Days Are Here Again
	 Filename:     	Get-OnlineVerFlashPlayer.ps1
	===========================================================================
	.Synopsis
        Queries Adobe's Flash Player Website for the current version of
        the app and returns the version, date updated, and
        download URLs if available.
    .DESCRIPTION
	    This function retrieves the latest data associated with Adobe Flash Player
        Invoke-WebRequest queries the site to obtain app release date, version and 
        download URLs. This includes NPAPI, PPAPI and ActiveX
        It then outputs the information as a
        PSObject to the Host.

    .NOTE: 
        At the moment, the release date of Flash Player is being obtained from FileHippo.
        Once I have a bit of spare time, I will try and change this to use of the vendor site.

    .EXAMPLE
        PS C:\> Get-OnlineVerFlashPlayer.ps1

        Software_Name        : Adobe Flash Player
        Software_URL         : https://fpdownload.macromedia.com/pub/flashplayer/masterversion/masterversion.xml
        Online_Version       : 30.0.0.154
        Online_Date          : August 21, 2018
        Download_URL_PPAPI   : https://fpdownload.macromedia.com/pub/flashplayer/pdc/30.0.0.154/install_flash_player_30_ppapi.msi
        Download_URL_NPAPI   : https://fpdownload.macromedia.com/pub/flashplayer/pdc/30.0.0.154/install_flash_player_30_plugin.msi
        Download_URL_ActiveX : https://fpdownload.macromedia.com/pub/flashplayer/pdc/30.0.0.154/install_flash_player_30_active_X.msi

    
        PS C:\> Get-OnlineVeNotePadPlusPlus -Quiet
        30.0.0.154
    
    
    .INPUTS
        -Quiet
            Use of this parameter will output just the current version of
            Flash Player instead of the entire object. It will always be the
            last parameter.
    .OUTPUTS
            An object containing the following:
            Software Name: Name of the software
            Software URL: The URL info was sourced from
            Online Version: The current version found
            Online Date: The date the version was updated
            Download URL PPAPI: Download URL for the PPAPI version
            Download URL PPAPI: Download URL for the NPAPI version
            Download URL PPAPI: Download URL for the ActiveX version
    
            If -Quiet is specified then just the value of 'Online Version'
            will be displayed.
    .NOTES
            Resources/Credits:
            https://github.com/itsontheb

#>

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

function Get-OnlineVerFlashPlayer
{

    [cmdletbinding()]
    param (
        [Parameter(Mandatory=$false, 
                   Position=0)]
        [switch]
        $Quiet
    )

    begin
    {
        # Initial Variables
        $SoftwareName = "Adobe Flash Player"
        $uri = 'https://fpdownload.macromedia.com/pub/flashplayer/masterversion/masterversion.xml'
       
            
        $hashtable = [ordered]@{
            'Software_Name'    = $softwareName
            'Software_URL'     = $uri
            'Online_Version'   = 'UNKNOWN' 
            'Online_Date'      = 'UNKNOWN'
            'Download_URL_PPAPI' = 'UNKNOWN'
            'Download_URL_NPAPI' = 'UNKNOWN'
            'Download_URL_ActiveX' = 'UNKNOWN'
        }
    
        $swObject = New-Object -TypeName PSObject -Property $hashtable
    }


   Process
    {
        # Get the Version & Release Date
        try
        {
            Write-Verbose -Message "Attempting to pull info from the below URL: `n $URI"
            

        $uri = 'https://fpdownload.macromedia.com/pub/flashplayer/masterversion/masterversion.xml'
        $xml_versions = New-Object XML
        $xml_versions.Load($uri)
        $FlashMajorVersion = ($xml_versions.version.release.NPAPI_win.version).Substring(0,2)
        $FlashFullVersion = ($xml_versions.version.release.NPAPI_win.version).replace(",",".")
        $FlashURLPrefix = "https://fpdownload.macromedia.com/pub/flashplayer/pdc/" + $FlashFullVersion
        $FlashDateURI= (curl -Uri https://filehippo.com/download_adobe-flash-player/tech -UseBasicParsing | Select-Object Content -ExpandProperty Content)
        $FlashDateURI -match "Date added:</span> <span class=""field-value"">`r`n                                (?<content>.*)</span>" | Out-Null
        $app1Date = ($matches['content'])
        $swObject.Online_Version = $FlashFullVersion
        $swobject.Online_Date = $app1Date
        
         
        } 
        catch
        {
            Write-Verbose -Message "Error accessing the below URL: `n $URI"
            $message = $("Line {0} : {1}" -f $_.InvocationInfo.ScriptLineNumber, $_.exception.message)
            $swObject | Add-Member -MemberType NoteProperty -Name 'ERROR' -Value $message
        }
        finally
        {
          

        # Get the Download URLs
        if ($swObject.Online_Version -ne 'UNKNOWN')
        {
           
            
           $FlashURLPPAPI = $FlashURLPrefix + "/install_flash_player_" + $FlashMajorVersion + "_ppapi.msi"
           $FlashURLActiveX = $FlashURLPRefix + "/install_flash_player_" + $FlashMajorVersion + "_active_X.msi"
           $FLashURLNPAPI = $FlashURLPRefix +  "/install_flash_player_" + $FlashMajorVersion + "_plugin.msi"

            $swObject.DOWNLOAD_URL_PPAPI = $FlashURLPPAPI
            $swObject.DOWNLOAD_URL_NPAPI = $FlashURLNPAPI
            $swObject.DOWNLOAD_URL_ActiveX = $FlashURLActiveX
        }
  }
    }
    End
    {
        # Output to Host
        if ($Quiet)
        {
            Write-Verbose -Message '$Quiet was specified. Returning just the version'
            Return $swObject.Online_Version
        }
        else
        {
            Return $swobject
        }
    }
}  # END Function Get-OnlineVerFlashPlayer
$fpNPAPI = Get-OnlineVerFlashPlayer
$row = $table.NewRow()
 
$softwareName = "Adobe Flash Player NPAPI/Plugin"
$softwareDate = $fpNPAPI.Online_Date
$softwareVersion = $fpNPAPI.Online_Version
$downloadURl = $fpNPAPI.Download_URL_NPAPI
 
$row.Software = [string]$softwareName
$row.Version = $softwareVersion
$row.DateAdded = $softwareDate
$row.DownloadURL = $downloadURl
$table.Rows.Add($row)
`

function Get-OnlineVerAdobeReader
{
    [cmdletbinding()]
    param (
        [Parameter(Mandatory=$false, 
                   Position=0)]
        [switch]
        $Quiet
    )

    begin
    {
        # Initial Variables
        $SoftwareName = 'Adobe Acrobat Reader DC'
        $URI = 'https://helpx.adobe.com/acrobat/release-note/release-notes-acrobat-reader.html'
            
        $hashtable = [ordered]@{
            'Software_Name'    = $softwareName
            'Software_URL'     = $uri
            'Online_Version'   = 'UNKNOWN' 
            'Online_Date'      = 'UNKNOWN'
            'Download_URL_x64' = 'UNKNOWN'
        }
    
        $swObject = New-Object -TypeName PSObject -Property $hashtable
}
   Process
    {
        # Get the Version & Release Date
        try
        {
  
        $VersionRegex = "\d+(\.\d+)+"
        $html = Invoke-WebRequest -UseBasicParsing -Uri "$uri"
        $DC_Versions = $html.Links | Where-Object outerHTML -Match "\($VersionRegex\)"
        $versionArray = @()
        foreach ($version in $DC_Versions) {
        $VersionNumber = [regex]::match($Version.outerHTML ,"$VersionRegex").Value
        $versionArray += $VersionNumber
        }
        $adobeVersion = $versionArray[0]
        
       
        $site = (curl -Uri $uri| Select-Object -ExpandProperty Content)
        $site -match "<td valign=""top""><p><strong>Focus</strong></p>`n</td>`n</tr><tr><td>(?<content>.*)</td>" | Out-Null
        $adobeDate = ($matches['content'])
      
        $urlData = $adobeVersion.Replace(".","")
        $downloadURL = 'http://ardownload.adobe.com/pub/adobe/reader/win/AcrobatDC/' + $urlData + "/AcrodrDCUpd" + $urlData + ".msp"
        
        $swObject.Download_URL_x64 = $downloadURL
        $swObject.Online_Version = $adobeVersion
        $swObject.Online_Date = $adobeDate
        
         }
        catch
        {
            Write-Verbose -Message "Error accessing the below URL: `n $URI"
            $message = $("Line {0} : {1}" -f $_.InvocationInfo.ScriptLineNumber, $_.exception.message)
            $swObject | Add-Member -MemberType NoteProperty -Name 'ERROR' -Value $message
        }
        finally
        {
   
    }
    }
    End
    {
        # Output to Host
        if ($Quiet)
        {
            Write-Verbose -Message '$Quiet was specified. Returning just the version'
            Return $swObject.Online_Version
        }
        else
        {
            Return $swobject
        }
    }
}  # END Function Get-OnlineAdobeReader

$adobeReader = Get-OnlineVerAdobeReader
$row = $table.NewRow()
 
$softwareName = "Adobe Acrobat Reader DC"
$softwareDate = $adobeReader.Online_Date
$softwareVersion =  $adobeReader.Online_Version
$downloadURl =  $adobeReader.Download_URL_x64
 
$row.Software = [string]$softwareName
$row.Version = $softwareVersion
$row.DateAdded = $softwareDate
$row.DownloadURL = $downloadURl
$table.Rows.Add($row)


<#	
	.NOTES
	===========================================================================
	 Created with: 	PowerShell ISE (Win10 17134)
	 Revision:		v5
	 Last Modified: 24 August 2018
	 Created by:   	Jay Harper (github.com/thecatdidit/powershellusefulscripts)
	 Organizaiton: 	Happy Days Are Here Again
	 Filename:     	Get-OnlineVerFlashPlayer.ps1
	===========================================================================
	.Synopsis
        Queries Adobe's Flash Player Website for the current version of
        the app and returns the version, date updated, and
        download URLs if available.
    .DESCRIPTION
	    This function retrieves the latest data associated with Adobe Flash Player
        Invoke-WebRequest queries the site to obtain app release date, version and 
        download URLs. This includes NPAPI, PPAPI and ActiveX
        It then outputs the information as a
        PSObject to the Host.

    .NOTE: 
        At the moment, the release date of Flash Player is being obtained from FileHippo.
        Once I have a bit of spare time, I will try and change this to use of the vendor site.

    .EXAMPLE
        PS C:\> Get-OnlineVerFlashPlayer.ps1

        Software_Name        : Adobe Flash Player
        Software_URL         : https://fpdownload.macromedia.com/pub/flashplayer/masterversion/masterversion.xml
        Online_Version       : 30.0.0.154
        Online_Date          : August 21, 2018
        Download_URL_PPAPI   : https://fpdownload.macromedia.com/pub/flashplayer/pdc/30.0.0.154/install_flash_player_30_ppapi.msi
        Download_URL_NPAPI   : https://fpdownload.macromedia.com/pub/flashplayer/pdc/30.0.0.154/install_flash_player_30_plugin.msi
        Download_URL_ActiveX : https://fpdownload.macromedia.com/pub/flashplayer/pdc/30.0.0.154/install_flash_player_30_active_X.msi

    
        PS C:\> Get-OnlineVeNotePadPlusPlus -Quiet
        30.0.0.154
    
    
    .INPUTS
        -Quiet
            Use of this parameter will output just the current version of
            Flash Player instead of the entire object. It will always be the
            last parameter.
    .OUTPUTS
            An object containing the following:
            Software Name: Name of the software
            Software URL: The URL info was sourced from
            Online Version: The current version found
            Online Date: The date the version was updated
            Download URL PPAPI: Download URL for the PPAPI version
            Download URL PPAPI: Download URL for the NPAPI version
            Download URL PPAPI: Download URL for the ActiveX version
    
            If -Quiet is specified then just the value of 'Online Version'
            will be displayed.
    .NOTES
            Resources/Credits:
            https://github.com/itsontheb

#>

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

function Get-OnlineVerFlashPlayer
{

    [cmdletbinding()]
    param (
        [Parameter(Mandatory=$false, 
                   Position=0)]
        [switch]
        $Quiet
    )

    begin
    {
        # Initial Variables
        $SoftwareName = "Adobe Flash Player"
        $uri = 'https://fpdownload.macromedia.com/pub/flashplayer/masterversion/masterversion.xml'
       
            
        $hashtable = [ordered]@{
            'Software_Name'    = $softwareName
            'Software_URL'     = $uri
            'Online_Version'   = 'UNKNOWN' 
            'Online_Date'      = 'UNKNOWN'
            'Download_URL_PPAPI' = 'UNKNOWN'
            'Download_URL_NPAPI' = 'UNKNOWN'
            'Download_URL_ActiveX' = 'UNKNOWN'
        }
    
        $swObject = New-Object -TypeName PSObject -Property $hashtable
    }


   Process
    {
        # Get the Version & Release Date
        try
        {
            Write-Verbose -Message "Attempting to pull info from the below URL: `n $URI"
            

        $uri = 'https://fpdownload.macromedia.com/pub/flashplayer/masterversion/masterversion.xml'
        $xml_versions = New-Object XML
        $xml_versions.Load($uri)
        $FlashMajorVersion = ($xml_versions.version.release.NPAPI_win.version).Substring(0,2)
        $FlashFullVersion = ($xml_versions.version.release.NPAPI_win.version).replace(",",".")
        $FlashURLPrefix = "https://fpdownload.macromedia.com/pub/flashplayer/pdc/" + $FlashFullVersion
        $FlashDateURI= (curl -Uri https://filehippo.com/download_adobe-flash-player/tech -UseBasicParsing | Select-Object Content -ExpandProperty Content)
        $FlashDateURI -match "Date added:</span> <span class=""field-value"">`r`n                                (?<content>.*)</span>" | Out-Null
        $app1Date = ($matches['content'])
        $swObject.Online_Version = $FlashFullVersion
        $swobject.Online_Date = $app1Date
        
         
        } 
        catch
        {
            Write-Verbose -Message "Error accessing the below URL: `n $URI"
            $message = $("Line {0} : {1}" -f $_.InvocationInfo.ScriptLineNumber, $_.exception.message)
            $swObject | Add-Member -MemberType NoteProperty -Name 'ERROR' -Value $message
        }
        finally
        {
          

        # Get the Download URLs
        if ($swObject.Online_Version -ne 'UNKNOWN')
        {
           
            
           $FlashURLPPAPI = $FlashURLPrefix + "/install_flash_player_" + $FlashMajorVersion + "_ppapi.msi"
           $FlashURLActiveX = $FlashURLPRefix + "/install_flash_player_" + $FlashMajorVersion + "_active_X.msi"
           $FLashURLNPAPI = $FlashURLPRefix +  "/install_flash_player_" + $FlashMajorVersion + "_plugin.msi"

            $swObject.DOWNLOAD_URL_PPAPI = $FlashURLPPAPI
            $swObject.DOWNLOAD_URL_NPAPI = $FlashURLNPAPI
            $swObject.DOWNLOAD_URL_ActiveX = $FlashURLActiveX
        }
  }
    }
    End
    {
        # Output to Host
        if ($Quiet)
        {
            Write-Verbose -Message '$Quiet was specified. Returning just the version'
            Return $swObject.Online_Version
        }
        else
        {
            Return $swobject
        }
    }
}  # END Function Get-OnlineVerFlashPlayer

function Get-OnlineVerFirefox
{

    [cmdletbinding()]
    param (
        [Parameter(Mandatory=$false, 
                   Position=0)]
        [switch]
        $Quiet
    )

    begin
    {
        # Initial Variables
        $SoftwareName = "Mozilla Firefox"
        $uri = 'https://product-details.mozilla.org/1.0/firefox_versions.json'
       
            
        $hashtable = [ordered]@{
            'Software_Name'    = $softwareName
            'Software_URL'     = 'UNKNOWN'
            'Online_Version'   = 'UNKNOWN' 
            'Online_Date'      = 'UNKNOWN'
            'Download_URL_x64' = 'UNKNOWN'
            'Download_URL_x86' = 'UNKNOWN'
           
        }
    
        $swObject = New-Object -TypeName PSObject -Property $hashtable
    }


   Process
    {
        # Get the Version & Release Date
        try
        {
            Write-Verbose -Message "Attempting to pull info from the below URL: `n $URI"
            

        $uri = 'https://product-details.mozilla.org/1.0/firefox_versions.json'
        $FirefoxVersion = Invoke-WebRequest $uri -UseBasicParsing | ConvertFrom-Json | select -ExpandProperty LATEST_FIREFOX_vERSION
        $ffReleaseNotes = "https://www.mozilla.org/en-us/firefox/"+$firefoxversion+"/releasenotes/"
        (curl -Uri $ffReleaseNotes -UseBasicParsing| Select-Object -ExpandProperty Content) -match "<h3>Firefox Release</h3>`n            `n              <p>(?<content>.*)</p>" | Out-Null
        $FirefoxDate = ($matches['content'])
        $FirefoxDownloadX64 = "https://download-origin.cdn.mozilla.net/pub/firefox/releases/" + $FirefoxVersion + "/win64/en-US/Firefox%20Setup%20" + $FirefoxVersion + ".exe"
        $FirefoxDownloadX86 = "https://download-origin.cdn.mozilla.net/pub/firefox/releases/" + $FirefoxVersion + "/win32/en-US/Firefox%20Setup%20" + $FirefoxVersion + ".exe"
        

        $swObject.Online_Version = $FirefoxVersion
        $swobject.Online_Date = $FirefoxDate
        $swobject.Software_URL = $ffReleaseNotes
         
        } 
        catch
        {
            Write-Verbose -Message "Error accessing the below URL: `n $URI"
            $message = $("Line {0} : {1}" -f $_.InvocationInfo.ScriptLineNumber, $_.exception.message)
            $swObject | Add-Member -MemberType NoteProperty -Name 'ERROR' -Value $message
        }
        finally
        {
          

        # Get the Download URLs
        if ($swObject.Online_Version -ne 'UNKNOWN')
        {
           
            $swobject.Download_URL_X64 = $FirefoxDownloadX64
            $swobject.Download_URL_X86 = $FirefoxDownloadX86
        }
  }
    }
    End
    {
        # Output to Host
        if ($Quiet)
        {
            Write-Verbose -Message '$Quiet was specified. Returning just the version'
            Return $swObject.Online_Version
        }
        else
        {
            Return $swobject
        }
    }
}  # END Function Get-OnlineVerFirefox
$ff = Get-OnlineVerFirefox
$row = $table.NewRow()
 
$softwareName = $ff.Software_Name
$softwareDate = $ff.Online_Date
$softwareVersion = $ff.Online_Version
$downloadURl = $ff.Download_URL_x64
 
 
$row.Software = [string]$softwareName
$row.Version = $softwareVersion
$row.DateAdded = $softwareDate
$row.DownloadURL = $downloadURl
$table.Rows.Add($row)
 
 
$tabName = "Windows 10 Build Status"
#Create Table object
$tableWin10 = New-Object system.Data.DataTable "$tabName"
 
#Define Columns
$col1 = New-Object system.Data.DataColumn Name, ([string])
$col2 = New-Object system.Data.DataColumn Version, ([string])
$col3 = New-Object system.Data.DataColumn DateUpdated, ([string])
$col4 = New-Object system.Data.DataColumn Build, ([string])
 
#Add the Columns
$tableWin10.columns.add($col1)
$tableWin10.columns.add($col2)
$tableWin10.columns.add($col3)
$tableWin10.columns.add($col4)
 
$1607 = 'https://support.microsoft.com/en-us/help/4000825'
$1703 = 'https://support.microsoft.com/en-us/help/4018124'
$1709 = 'https://support.microsoft.com/en-us/help/4043454'
$1803 = 'https://support.microsoft.com/en-us/help/4099479'
$1809 = 'https://support.microsoft.com/en-us/help/4464619'


$news1607 = (curl -Uri $1607| Select-Object -ExpandProperty Content)
$news1607 -match "releaseVersion""\: ""OS Build (?<content>.*)"""
$version1607 = ($matches['content'])
$news1607 -match "heading""\: ""(?<content>.*)—"
$date1607 = ($matches['content'])

$row = $tableWin10.NewRow()
$Win10Name = "Anniversary Edition"
$Win10Version = "1607"
$Win10Date = $date1607
$win10Build = $version1607
$row.Name = $Win10Name
$row.Version = $Win10Version
$row.DateUpdated = $win10Date
$row.Build = $win10Build
$tableWin10.Rows.Add($row)

$news1703 = (curl -Uri $1703| Select-Object -ExpandProperty Content)
$news1703 -match "releaseVersion""\: ""OS Build (?<content>.*)"""
$version1703 = ($matches['content'])
$news1703 -match "heading""\: ""(?<content>.*)—"
$date1703 = ($matches['content'])
 
$row = $tableWin10.NewRow()
$Win10Name = "Creators Update"
$Win10Version = "1703"
$Win10Date = $date1703
$win10Build = $version1703
$row.Name = $Win10Name
$row.Version = $Win10Version
$row.DateUpdated = $win10Date
$row.Build = $win10Build
$tableWin10.Rows.Add($row)
 

$news1709 = (curl -Uri $1709| Select-Object -ExpandProperty Content)
$news1709 -match "releaseVersion""\: ""OS Build (?<content>.*)"""
$version1709 = ($matches['content'])
$news1709 -match "heading""\: ""(?<content>.*)—"
$date1709 = ($matches['content'])
 
$row = $tableWin10.NewRow()
$Win10Name = "Fall Creators Update"
$Win10Version = "1709"
$Win10Date = $date1709
$win10Build = $version1709
$row.Name = $Win10Name
$row.Version = $Win10Version
$row.DateUpdated = $win10Date
$row.Build = $win10Build
$tableWin10.Rows.Add($row)
 
$news1803 = (curl -Uri $1803| Select-Object -ExpandProperty Content)
$news1803 -match "releaseVersion""\: ""OS Build (?<content>.*)"""
$version1803 = ($matches['content'])
$news1803 -match "heading""\: ""(?<content>.*)—"
$date1803 = ($matches['content'])

$row = $tableWin10.NewRow()
$Win10Name = "April Update"
$Win10Version = "1803"
$Win10Date = $date1803
$win10Build = $version1803
$row.Name = $Win10Name
$row.Version = $Win10Version
$row.DateUpdated = $win10Date
$row.Build = $win10Build
$tableWin10.Rows.Add($row)
 
$html = "<table><tr><td><b><u>Software</u></b></td><td><b><u>Version</u></b></td><td><b><u>Previous</u></b></td></tr>"
foreach ($row in $table.Rows)
{
      $html += "<tr><td>" + $row[0] + "</td><td>" + $row[1] + "</td></tr>" + $row[2] + "</td></tr>" + $row[3]
}
$html += "</table>"
 
foreach ($row in $tableWin10.Rows)
{
      $htmlWin10 += "<tr><td>" + $row[0] + "</td><td>" + $row[1] + "</td></tr>" + $row[2] + "</td></tr>" + $row[3]
}
$htmlWin10 += "</table>"
 
$Style = "
<style>
    TABLE{border-width: 1px;border-style: solid;border-color: black;border-collapse: collapse;}
    TH{border-width: 1px;padding: 3px;border-style: solid;border-color: black;}
    TD{border-width: 1px;padding: 3px;border-style: solid;border-color: black;}
</style>
"
 
$table = ($table | Sort-Object Software | ConvertTo-Html -Title "Third Party Apps" -Property Software, Version, DateAdded, DownloadURL -Head $Style) | Out-String
$tableWin10 = ($tableWin10 | Sort-Object Build | ConvertTo-Html -Title "Windows 10 Build Status" -Property Name,Version,DateUpdated,Build -Head $Style) | Out-String
$date = Get-Date -UFormat "%A %d %B %Y - %r"
$tableFinal = $table + $tableWin10 + $date


$tableFinal | Out-File C:\temp\3pup.html -Force

Start-Process "chrome.exe" "C:\temp\3pup.html"

<#
Old Win10 queries
$cwurl = (curl -uri https://changewindows.org/rings/pc -UseBasicParsing | Select-Object -ExpandProperty content)
$filter1607 = ("redstone1/14393/pc"">`n    <div class=""card-block"">`n        <h5>Targeted</h5>`n        <h3>(?<version>.*)</h3>`n        <p class=""bold"">(?<date>.*)</p>")
$filter1703 = ("redstone2/15063/pc"">`n    <div class=""card-block"">`n        <h5>Targeted</h5>`n        <h3>(?<version>.*)</h3>`n        <p class=""bold"">(?<date>.*)</p>")
$filter1709 = ("redstone3/16299/pc"">`n    <div class=""card-block"">`n        <h5>Targeted</h5>`n        <h3>(?<version>.*)</h3>`n        <p class=""bold"">(?<date>.*)</p>")
$filter1803 = ("redstone4/17134/pc"">`n    <div class=""card-block"">`n        <h5>Targeted</h5>`n        <h3>(?<version>.*)</h3>`n        <p class=""bold"">(?<date>.*)</p>")
 
$cwurl -match $filter1607 | out-null ; $version = ($Matches['version']); $date = ($matches['date'])
#>

<##>
# Send the email
$smtpserver = "chsrelay.benefitfocus.com"
$from = "michael.harper@benefitfocus.com"
$to = "michael.harper@benefitfocus.com"
$cc = "HelpdeskProjects@benefitfocus.com"
$date = Get-Date -UFormat "%A %d %B %Y - %r"
$subject = "Daily Grind - $date"
#$body =  "<br /> GENERATED AS OF <b>$date</b><br /><br />" + $body
Send-MailMessage -smtpserver $smtpserver -from $from -to $to -subject $subject -Cc $cc -body $tableFinal -bodyashtml
#>