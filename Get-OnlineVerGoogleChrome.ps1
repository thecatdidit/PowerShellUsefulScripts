<#
	===========================================================================
	 Created with: 	VS Code 1.58.2/ISE 19043
	 Revision:      v1
	 Last Modified: 27 July 2021
	 Created by:   	Jay Harper (github.com/thecatdidit/powershellusefulscripts)
	 Organizaiton: 	Happy Days Are Here Again
	 Filename:     	Get-OnlineVerGoogleChrome.ps1
	===========================================================================
	.CHANGELOG
        v1 [27 July 2021]
        Script creation

	.SYNOPSIS
        This script queries details on the latest release of Google Chrome.
        
	.DESCRIPTION
        Release information is obtained from Chromium Dev Team's release tracker
        https://omahaproxy.appsot.com

	.EXAMPLE
        PS> Get-OnlineVerGoogleChrome
        Software_Name    : Google Chrome
        Software_URL     : https://omahaproxy.appspot.com/
        Online_Version   : 92.0.4515.107
        Online_Date      : 07/20/21
        Download_URL_x86 : https://dl.google.com/dl/chrome/install/googlechromestandaloneenterprise64.msi
        Download_URL_x64 : https://dl.google.com/dl/chrome/install/googlechromestandaloneenterprise.msi
       	
        PS> Get-GetOnlineVerGooglechrome -Quiet
       	92.0.4515.107

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
        $URI = 'https://omahaproxy.appspot.com/'
            
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
            $uri = 'https://omahaproxy.appspot.com/all?csv=1'
            $ReleaseInfo = (((ConvertFrom-Csv (Invoke-WebRequest -URI $URI -UseBasicParsing).content)) | Where-Object os -Match "win64" | Where-Object channel -EQ "stable")
            $ReleaseVersion = $ReleaseInfo.current_version
            $ReleaseDate = $ReleaseInfo.current_reldate 

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
                
                $swObject.Download_URL_x86 = "https://dl.google.com/dl/chrome/install/googlechromestandaloneenterprise64.msi"
                $swObject.Download_URL_x64 = "https://dl.google.com/dl/chrome/install/googlechromestandaloneenterprise.msi"
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
