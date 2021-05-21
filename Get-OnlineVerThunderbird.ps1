<#
	===========================================================================
	 Created with: 	PowerShell ISE (Win10 19042)
	 Revision:	v1
	 Last Modified: 21 May 2021
	 Created by:   	Jay Harper (github.com/thecatdidit/powershellusefulscripts)
	 Organizaiton: 	Happy Days Are Here Again
	 Filename:     	Get-OnlineVerThunderbird.ps1
	===========================================================================
	.CHANGELOG
        [2021.05.21]
        Script creation

	.SYNOPSIS
        Queries Mozilla's Website for the current version of
        Thunderbird and returns the version, date updated, and
        download URLs if available.

	.DESCRIPTION
	This function retrieves the latest data associated with Thunderbird
        Invoke-WebRequest queries the site to obtain app release date, version and 
        download URLs. This includes x86 and x64.
        It then outputs the information as a
        PSObject to the Host

        The version info for Thunderbird is obtained from a JSON file that Mozilla 
        maintains for tracking the app builds. 

        The URLs for the release notes and direct download links are extrapolated
        by updating Thunderbird's URL syntax with the version number. The templates:

        Release Notes: https://www.mozilla.org/en-us/thunderbird/ + <VERSION> + /releasenotes/
        Download URL: https://download-origin.cdn.mozilla.net/pub/thunderbird/releases/ + <VERSION> + /win64/en-US/Thunderbird20Setup%20 + <VERSION>.exe
            
        Thunderbird 78.10.2 is the version at the time of documentation. Using that version, we would get

        Release Notes: https://www.mozilla.org/en-us/thunderbird/78.10.2/releasenotes/
        Download URL:https://download-origin.cdn.mozilla.net/pub/thunderbird/releases/78.10.2/win64/en-US/Thunderbird%20Setup%2078.10.2.exe

	.EXAMPLE
        PS C:\> Get-OnlineVerThunderbird.ps1

        Software_Name    : Mozilla Thunderbird
        Software_URL     : https://www.mozilla.org/en-us/thunderbird/78.10.2/releasenotes/
        Online_Version   : 78.10.2
        Online_Date      : May 17, 2021
        Download_URL_x64 : https://download-origin.cdn.mozilla.net/pub/thunderbird/releases/78.10.2/win64/en-US/Thunderbird%20Setup%2078.10.2.exe
        Download_URL_x86 : https://download-origin.cdn.mozilla.net/pub/thunderbird/releases/78.10.2/win32/en-US/Thunderbird%20Setup%2078.10.2.exe
       	
       PS C:\> Get-OnlineVerThunderbird -Quiet
       	78.10.2
 
 	.INPUTS
        -Quiet
            Use of this parameter will output just the current version of
            Thunderbird instead of the entire object. It will always be the
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

function Get-OnlineVerThunderbird {

    [cmdletbinding()]
    param (
        [Parameter(Mandatory = $false, 
            Position = 0)]
        [switch]
        $Quiet
    )

    begin {
        # Initial Variables
        $SoftwareName = "Mozilla Thunderbird"
        $uri = 'https://product-details.mozilla.org/1.0/thunderbird_versions.json'
       
            
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
            

            $uri = 'https://product-details.mozilla.org/1.0/thunderbird_versions.json'
            $ThunderbirdVersion = Invoke-WebRequest $uri -UseBasicParsing | ConvertFrom-Json | Select-Object -ExpandProperty LATEST_THUNDERBIRD_vERSION
            $ThunderbirdReleaseNotes = "https://www.mozilla.org/en-us/thunderbird/" + $ThunderbirdVersion + "/releasenotes/"
            (Invoke-WebRequest -Uri $ThunderbirdReleaseNotes -UseBasicParsing | Select-Object -ExpandProperty Content) -match "first offered to  channel users on (?<ReleaseDate>.*)`n    </p>" | Out-Null
            $ThunderbirdDate = ($matches['ReleaseDate'])
            $Thunderbirdx64 = "https://download-origin.cdn.mozilla.net/pub/thunderbird/releases/" + $ThunderbirdVersion + "/win64/en-US/Thunderbird%20Setup%20" + $ThunderbirdVersion + ".exe" 
            $Thunderbirdx86 = "https://download-origin.cdn.mozilla.net/pub/thunderbird/releases/" + $ThunderbirdVersion + "/win32/en-US/Thunderbird%20Setup%20" + $ThunderbirdVersion + ".exe"
        
        
            $swObject.Online_Version = $ThunderbirdVersion
            $swobject.Online_Date = $ThunderbirdDate
            $swobject.Software_URL = $ThunderbirdReleaseNotes
         
        } 
        catch {
            Write-Verbose -Message "Error accessing the below URL: `n $URI"
            $message = $("Line {0} : {1}" -f $_.InvocationInfo.ScriptLineNumber, $_.exception.message)
            $swObject | Add-Member -MemberType NoteProperty -Name 'ERROR' -Value $message
        }
        finally {
          

            # Get the Download URLs
            if ($swObject.Online_Version -ne 'UNKNOWN') {
           
                $swobject.Download_URL_X64 = $Thunderbirdx64
                $swobject.Download_URL_X86 = $Thunderbirdx86
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
}  # END Function Get-OnlineVerThunderbird
