<#
	===========================================================================
	 Created with: 	PowerShell ISE (Win10 18362/1903)
	 Revision:      v2
	 Last Modified: 22 Jun 2021
	 Created by:   	Jay Harper (github.com/thecatdidit/powershellusefulscripts)
	 Organizaiton: 	Happy Days Are Here Again
	 Filename:     	Get-OnlineVerFirefox.ps1
	===========================================================================
	.CHANGELOG
	v2 (21 Jun 2021)
        Corrected variable for Firefox version. Script output was not providing
        all of the requested data
    v1 (11 Jun 2021)
        Original script creation

	.SYNOPSIS
        This script obtains details for the current release of Mozilla Firefox.

	.DESCRIPTION
        This function retrieves the latest data associated with Mozilla Firefox
        Invoke-WebRequest queries the site to obtain app release date, version and 
        download URLs. This includes x86 and x64.
        It then outputs the information as a PSObject to the Host

        Mozilla provides a JSON containing the latest Firefox build information. The
        file is used to populate the details.

	.EXAMPLE
        PS C:\> Get-OnlineVerFirefox.ps1

        Software_Name    : Mozilla Firefox
        Software_URL     : https://www.mozilla.org/en-us/firefox/89.0/releasenotes/
        Online_Version   : 89.0
        Online_Date      : 2021-06-01
        Download_URL_x64 : https://download-origin.cdn.mozilla.net/pub/firefox/releases/89.0/win64/en-US/Firefox%20Setup%2089.0.exe
        Download_URL_x86 : https://download-origin.cdn.mozilla.net/pub/firefox/releases/89.0/win32/en-US/Firefox%20Setup%2089.0.exe
    
       	PS C:\> Get-OnlineVerFirefox -Quiet
       	89.0
 
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
            $FFReleaseInfo = Invoke-WebRequest $uri -UseBasicParsing | ConvertFrom-Json
            $FFDate = $FFReleaseInfo.LAST_RELEASE_DATE
            $FFVersion = $FFReleaseInfo.LATEST_FIREFOX_VERSION
            $FFReleaseNotes = "https://www.mozilla.org/en-us/firefox/" + $FFVersion + "/releasenotes/"
            $FirefoxDownloadX64 = "https://download-origin.cdn.mozilla.net/pub/firefox/releases/" + $FFVersion + "/win64/en-US/Firefox%20Setup%20" + $FFVersion + ".exe"
            $FirefoxDownloadX86 = "https://download-origin.cdn.mozilla.net/pub/firefox/releases/" + $FFVersion + "/win32/en-US/Firefox%20Setup%20" + $FFVersion + ".exe"
        
            $swObject.Online_Version = $FFVersion
            $swobject.Online_Date = $FFDate
            $swobject.Software_URL = $FFReleaseNotes
         
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
