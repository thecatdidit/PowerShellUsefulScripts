<#
	===========================================================================
	 Created with: 	ISE 22621
	 Revision:      v4
	 Last Modified: 02 October 2025
	 Created by:   	Jay Harper (github.com/thecatdidit/powershellusefulscripts)
	 Organizaiton: 	Happy Days Are Here Again
	 Filename:     	Get-OnlineVerGoogleChrome.ps1
	===========================================================================
	.CHANGELOG
        v4 [02 October 2025]
		Corrected download links for the MSI installers - x86 and x64 flavors
		v3 [02 August 2024]
        Update source and filter logic to reflect site content changes
        v2 [09 April 2024]
        Update release tracker source and filter logic
        v1 [27 July 2021]
        Script creation

	.SYNOPSIS
        This script queries details on the latest release of Google Chrome.
        
	.DESCRIPTION
        Release information is obtained from Chromium Dev Team's release tracker
        https://chromiumdash.appspot.com/releases?platform=Windows

	.EXAMPLE
        PS> Get-OnlineVerGoogleChrome
        Software_Name    : Google Chrome
        Software_URL     : https://versionhistory.googleapis.com/v1/chrome/platforms/win64/channels/stable/versions/all/releases?filter=endtime=none
        Online_Version   : 127.0.6533.89
        Online_Date      : 2024-08-01
        Download_URL_x86 : https://dl.google.com/dl/chrome/install/googlechromestandaloneenterprise64.msi
        Download_URL_x64 : https://dl.google.com/dl/chrome/install/googlechromestandaloneenterprise.msi
       	
        PS> Get-GetOnlineVerGooglechrome -Quiet
       	127.0.6533.89

 	.INPUTS
        -Quiet
            Use of this parameter will output just the current version of
            Chrome instead of the entire object. It will always be the
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

function Get-OnlineVerGoogleChrome {
    [cmdletbinding()]
    param (
        [Parameter(Mandatory = $false, 
            Position = 0)]
        [switch]
        $Quiet
    )

    begin {
        # Initial Variables
        $SoftwareName = 'Google Chrome'
        $URI = 'https://versionhistory.googleapis.com/v1/chrome/platforms/win64/channels/stable/versions/all/releases?filter=endtime=none'
            
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

    Process {
        # Get the Version & Release Date
        try {
            Write-Verbose -Message "Attempting to pull info from the below URL: `n $URI"
            $ReleaseInfo = ((Invoke-WebRequest -Uri $URI).content) | ConvertFrom-Json
            $ReleaseVersion = $ReleaseInfo.releases[0].version
            $ReleaseDate = ($ReleaseInfo.releases[0].serving.startTime).Substring(0,10)
            
            $swObject.Online_Version = $ReleaseVersion
            $swObject.Online_Date = $ReleaseDate

        }
        catch {
            Write-Verbose -Message "Error accessing the below URL: `n $URI"
            $message = $("Line {0} : {1}" -f $_.InvocationInfo.ScriptLineNumber, $_.exception.message)
            $swObject | Add-Member -MemberType NoteProperty -Name 'ERROR' -Value $message
        }

        finally {

            # Get the Download URLs
            if ($swObject.Online_Version -ne 'UNKNOWN') {
                
                $swObject.Download_URL_x86 = "https://dl.google.com/dl/chrome/install/googlechromestandaloneenterprise.msi"
                $swObject.Download_URL_x64 = "https://dl.google.com/dl/chrome/install/googlechromestandaloneenterprise64.msi"
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
}  # END Function Get-OnlineVerGoogleChrome



