<#
	===========================================================================
	 Created with: 	PowerShell ISE (Win10 18362/1903)
	 Revision:      v2
	 Last Modified: 22 Jun 2021
	 Created by:   	Jay Harper (github.com/thecatdidit/powershellusefulscripts)
	 Organizaiton: 	Happy Days Are Here Again
	 Filename:     	Get-OnlineVerFirefoxESR.ps1
	===========================================================================
	.CHANGELOG
        v1 (14 Jul 2021)
        .Initial script creation

	.SYNOPSIS
        This script obtains details for the Extended Service Release (ESR)
        of Mozilla Firefox.

	.DESCRIPTION
        This function retrieves the latest data associated with Mozilla Firefox
        Invoke-WebRequest queries the site to obtain app release date, version and 
        download URLs. This includes x86 and x64.
        It then outputs the information as a PSObject to the Host

        Mozilla provides a JSON containing the latest Firefox build information. The
        file is used to populate the details.

	.EXAMPLE
        PS C:\> Get-OnlineVerFirefoxESR.ps1

        Software_Name    : Mozilla Firefox ESR
        Software_URL     : https://www.mozilla.org/en-us/firefox/78.12.0/releasenotes/
        Online_Version   : 78.12.0
        Online_Date      : 2021-07-13
        Download_URL_x64 : https://download-installer.cdn.mozilla.net/pub/firefox/releases/78.12.0esr/win64/en-US/Firefox%20Setup%2078.12.0esr.exe
        Download_URL_x86 : https://download-installer.cdn.mozilla.net/pub/firefox/releases/78.12.0esr/win32/en-US/Firefox%20Setup%2078.12.0esr.exe
    
       	PS C:\> Get-OnlineVerFirefoxESR -Quiet
       	78.12.0
 
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

function Get-OnlineVerFirefoxESR {

    [cmdletbinding()]
    param (
        [Parameter(Mandatory = $false, 
            Position = 0)]
        [switch]
        $Quiet
    )

    begin {
        # Initial Variables
        $SoftwareName = "Mozilla Firefox ESR"
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
            $FFVersion = $FFReleaseInfo.FIREFOX_ESR.Replace("esr","")
            $FFReleaseNotes = "https://www.mozilla.org/en-us/firefox/" + $FFVersion + "/releasenotes/"
            $FirefoxDownloadX64 =  "https://download-installer.cdn.mozilla.net/pub/firefox/releases/" + $FFVersion + "esr/win64/en-US/Firefox%20Setup%20" + $FFVersion + "esr.exe"
            $FirefoxDownloadX86 =  "https://download-installer.cdn.mozilla.net/pub/firefox/releases/" + $FFVersion + "esr/win32/en-US/Firefox%20Setup%20" + $FFVersion + "esr.exe"
                                 
        
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
}  # END Function Get-OnlineVerFirefoxESR
