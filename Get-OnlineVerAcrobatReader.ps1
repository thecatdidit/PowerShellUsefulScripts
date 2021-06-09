<#	
	.NOTES
	===========================================================================
	 Created with: 	PowerShell ISE (Win10 17763)
	 Revision:	v2
	 Last Modified: 09 June 2021
	 Created by:   	Jay Harper (github.com/thecatdidit/powershellusefulscripts)
	 Organizaiton: 	Happy Days Are Here Again
	 Filename:     	Get-OnlineVerAdobeReader.ps1
	===========================================================================
	.CHANGELOG
    v2 (09 June 2021)
    Corrected site scraping/parsing RegEx to reflect a new layout of the Adobe
    support site.
    v1 (27 March 2019)
    Script creation

	.SYNOPSIS
        Queries the Adobe Website for the current version of
        Adobe Acrobat Reader DC. The script returns the version, date updated, and
        download URLs if available.

        .DESCRIPTION
        This function retrieves the latest data associated with Adobe Reader.
        Utilizes Invoke-WebRequest to query Adobe Reader's release notes pagean
        and pulls out the Version, Update Date and Download URLs for
        the app (x64 only) It then outputs the information as a
        PSObject to the Host.

	.EXAMPLE
        PS C:\> Get-OnlineVerAdobeReader.ps1

                Software_Name    : Adobe Acrobat Reader DC
                Software_URL     : https://helpx.adobe.com/acrobat/release-note/release-notes-acrobat-reader.html
                Online_Version   : 21.005.20048
                Online_Date      : Jun 08, 2021
                Download_URL_x64 : http://ardownload.adobe.com/pub/adobe/reader/win/AcrobatDC/2100520048/AcrodrDCUpd2100520048.msp

        PS C:\> Get-OnlineVerAdobeReader.ps1 -Quiet
        21.005.20048

	.INPUTS
        -Quiet
         Use of this parameter will output just the current version of
         Adobe Reader instead of the entire object. It will always be the
         last parameter.

	.OUTPUTS
        An object containing the following:
        Software Name: Name of the software
        Software URL: The URL info was sourced from
        Online Version: The current version found
        Online Date: The date the version was updated
    
        If -Quiet is specified then just the value of 'Online Version'
        will be displayed.

	.NOTES
        Resources/Credits:
        https://github.com/itsontheb

#>

function Get-OnlineVerAdobeReader {
    [cmdletbinding()]
    param (
        [Parameter(Mandatory = $false, 
            Position = 0)]
        [switch]
        $Quiet
    )

    begin {
        # Initial Variables
        $softwareName = 'Adobe Acrobat Reader DC'
        $uri = 'https://helpx.adobe.com/acrobat/release-note/release-notes-acrobat-reader.html'
            
        $hashtable = [ordered]@{
            'Software_Name'    = $softwareName
            'Software_URL'     = $uri
            'Online_Version'   = 'UNKNOWN' 
            'Online_Date'      = 'UNKNOWN'
            'Download_URL_x64' = 'UNKNOWN'
        }
    
        $swObject = New-Object -TypeName PSObject -Property $hashtable
    }
    Process {
        # Get the Version & Release Date
        try {
            $VersionRegex = "\d+(\.\d+)+"
            $html = Invoke-WebRequest -UseBasicParsing -Uri "$uri"
            $DC_Versions = $html.Links | Where-Object outerHTML -Match "\($VersionRegex\)"
            $versionArray = @()
            foreach ($version in $DC_Versions) {
                $VersionNumber = [regex]::match($Version.outerHTML , "$VersionRegex").Value
                $versionArray += $VersionNumber
            }
            $adobeVersion = $versionArray[0]
        
            $site = (Invoke-WebRequest -Uri $uri -UseBasicParsing | Select-Object -ExpandProperty Content)
            $site -match "Release Type\*</a></b></p>`n</th>`n<th valign=""top""><p><b>Focus</b></p>`n</th>`n</tr><tr><td>(?<date>.*)</td>" | Out-Null
            $adobeDate = ($matches['date'])
      
            $urlData = $adobeVersion.Replace(".", "")
            $downloadURL = 'http://ardownload.adobe.com/pub/adobe/reader/win/AcrobatDC/' + $urlData + "/AcrodrDCUpd" + $urlData + ".msp"
        
            $swObject.Download_URL_x64 = $downloadURL
            $swObject.Online_Version = $adobeVersion
            $swObject.Online_Date = $adobeDate
        
        }
        catch {
            Write-Verbose -Message "Error accessing the below URL: `n $URI"
            $message = $("Line {0} : {1}" -f $_.InvocationInfo.ScriptLineNumber, $_.exception.message)
            $swObject | Add-Member -MemberType NoteProperty -Name 'ERROR' -Value $message
        }
        finally {
        }
    }
    End {
        # Output to Host
        if ($Quiet) {
            Write-Verbose -Message '$Quiet was specified. Returning just the version'
            Return $swObject.Online_Version
        }
        else {
            Return $swobject
        }
    }
}  # END Function Get-OnlineVerAdobeReader
