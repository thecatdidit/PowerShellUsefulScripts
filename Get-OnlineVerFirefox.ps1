<#
	===========================================================================
	 Created with: 	PowerShell ISE (Win10 18362/1903)
	 Revision:	2019.08.13.01
	 Last Modified: 13 August 2019
	 Created by:   	Jay Harper (github.com/thecatdidit/powershellusefulscripts)
	 Organizaiton: 	Happy Days Are Here Again
	 Filename:     	Get-OnlineVerFirefox.ps1
	===========================================================================
	.CHANGELOG
	[2019.08.13.01]
	Updated content query of FF release notes to reflect HTML layout changes
	[2018.12.14.02]
	Cleaned up errant tabs and spaces that were acting screwy on GitHub.
	[2018.12.18.01]
	Updated script documentation with information on URL syntax, etc.
	.SYNOPSIS
        Queries Mozilla's Website for the current version of
        Firefox and returns the version, date updated, and
        download URLs if available.
	.DESCRIPTION
	This function retrieves the latest data associated with Mozilla Firefox
        Invoke-WebRequest queries the site to obtain app release date, version and 
        download URLs. This includes x86 and x64.
        It then outputs the information as a
        PSObject to the Host

        The version info for Firefox is obtained from a JSON file that Mozilla 
        maintains for browser builds (current, beta, etc.). Once the version
        number is obtained, it is used to find the date of release by
        parsing data from the Firefox release notes website. The date is
        extracted from this page as the JSON data tends to suffer from mistypes
        on occasion when new builds are released.

        The URLs for the release notes and direct download links are extrapolated
        by updating Firefox's URL syntax with the version number. The teplates:

        Release Notes: https://www.mozilla.org/en-us/firefox/ + <VERSION> + /releasenotes/
        Download URL: https://download-origin.cdn.mozilla.net/pub/firefox/releases/ + <VERSION> + /win64/en-US/Firefox%20Setup%20 + <VERSION>.exe
            
        Firefox 64.0 is the version at the time of documentation. Using that version, we would get

        Release Notes: https://www.mozilla.org/en-us/firefox/64.0/releasenotes/
        Download URL: https://download-origin.cdn.mozilla.net/pub/firefox/releases/64.0/win64/en-US/Firefox%20Stup%2064.0.exe

	.EXAMPLE
        PS C:\> Get-OnlineVerFirefox.ps1

        Software_Name    : Mozilla Firefox
        Software_URL     : https://product-details.mozilla.org/1.0/firefox_versions.json
        Online_Version   : 61.0.2
        Online_Date      : 2018-08-08
        Download_URL_x64 : https://download-origin.cdn.mozilla.net/pub/firefox/releases/61.0.2/win64/en-US/Firefox%20Setup%2061.0.2.exe
        Download_URL_x86 : https://download-origin.cdn.mozilla.net/pub/firefox/releases/61.0.2/win32/en-US/Firefox%20Setup%2061.0.2.exe
    
       	PS C:\> Get-OnlineVerFirefox -Quiet
       	61.0.2
 
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
            will be displayed
	.NOTES
            Resources/Credits:
            https://github.com/itsontheb
#>

function Get-OnlineVerFirefox {

    [cmdletbinding()]
    param (
        [Parameter(Mandatory = $false, 
            Position = 0)]
        [switch]
        $Quiet
    )

    begin {
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


    Process {
        # Get the Version & Release Date
        try {
            Write-Verbose -Message "Attempting to pull info from the below URL: `n $URI"
            

            $uri = 'https://product-details.mozilla.org/1.0/firefox_versions.json'
            $FirefoxVersion = Invoke-WebRequest $uri -UseBasicParsing | ConvertFrom-Json | Select-Object -ExpandProperty LATEST_FIREFOX_vERSION
            $ffReleaseNotes = "https://www.mozilla.org/en-us/firefox/" + $firefoxversion + "/releasenotes/"
            (Invoke-WebRequest -Uri $ffReleaseNotes | Select-Object -ExpandProperty Content) -match "<p class=""c-release-date"">(?<content>.*)</p>" | Out-Null
            $FirefoxDate = ($matches['content'])
            $FirefoxDownloadX64 = "https://download-origin.cdn.mozilla.net/pub/firefox/releases/" + $FirefoxVersion + "/win64/en-US/Firefox%20Setup%20" + $FirefoxVersion + ".exe"
            $FirefoxDownloadX86 = "https://download-origin.cdn.mozilla.net/pub/firefox/releases/" + $FirefoxVersion + "/win32/en-US/Firefox%20Setup%20" + $FirefoxVersion + ".exe"
        

            $swObject.Online_Version = $FirefoxVersion
            $swobject.Online_Date = $FirefoxDate
            $swobject.Software_URL = $ffReleaseNotes
         
        } 
        catch {
            Write-Verbose -Message "Error accessing the below URL: `n $URI"
            $message = $("Line {0} : {1}" -f $_.InvocationInfo.ScriptLineNumber, $_.exception.message)
            $swObject | Add-Member -MemberType NoteProperty -Name 'ERROR' -Value $message
        }
        finally {
          

            # Get the Download URLs
            if ($swObject.Online_Version -ne 'UNKNOWN') {
           
                $swobject.Download_URL_X64 = $FirefoxDownloadX64
                $swobject.Download_URL_X86 = $FirefoxDownloadX86
            }
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
}  # END Function Get-OnlineVerFirefox
