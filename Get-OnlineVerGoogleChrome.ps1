<#
.NOTES
	===========================================================================
	 Created with: 	PowerShell ISE
	 Revision:	v6
	 Last Modified: 24 August 2018
	 Created by:   	Jay Harper (github.com/thecatdidit/powershellusesfulscripts)
	 Organizaiton: 	Happy Days Are Here Again
	 Filename:     	Get-OnlineVerGoogleChrome.ps1
	===========================================================================
.Synopsis
    Queries Google's Website for the current version of
    Chrome and returns the version, date uploaded and download URLs
.DESCRIPTION
    Utilizes Invoke-WebRequest to query Google Chrome's Dev Team Blog and
    pulls out the Version, Update Date and Download URLs for both
    x68 and x64 versions. It then outputs the information as a
    PSObject to the Host.
.EXAMPLE
   PS C:\> Get-OnlineVerGoogleChrome -Quiert
.INPUTS
    -Quiet
        Use of this parameter will output just the current version of
        Google Chrome instead of the entire object. It will always be the
        last parameter.
.OUTPUTS
        An object containing the following:
        Software Name: Name of the software
        Software URL: The URL info was sourced from
        Online Version: The current version found
        Online Date: The date the version was updated
        Download URL x86: Download URL for the win32 version
        Download URL x64: Download URL for the win64 version
.EXAMPLE
        Software_Name    : GoogleChrome
        Software_URL     : http://feeds.feedburner.com/GoogleChromeReleases
        Online_Version   : 68.0.3440.106
        Online_Date      : 2018-08-23
        Download_URL_x86 : https://dl.google.com/dl/chrome/install/googlechromestandaloneenterprise64.msi
        Download_URL_x64 : https://dl.google.com/dl/chrome/install/googlechromestandaloneenterprise.msi

    
    If -Quiet is specified then just the value of 'Online Version'
    will be displayed.
.NOTES
    Resources/Credits:
    https://github.com/itsontheb

    Helpful URLs:

#>

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
