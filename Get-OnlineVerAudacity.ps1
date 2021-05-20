<#
	===========================================================================
	 Created with: 	VS Code 1.56.1/ISE 19042
	 Revision:      v1
	 Last Modified: 19 May 2021
	 Created by:   	Jay Harper (github.com/thecatdidit/powershellusefulscripts)
	 Organizaiton: 	Happy Days Are Here Again
	 Filename:     	Get-OnlineVerAudacity.ps1
	===========================================================================
	.CHANGELOG
	[2021.05.20]
	Script creation

	.SYNOPSIS
        Queries the Audacity webside for the current version of
        the app and returns the version, date updated, and
        download URLs if available.

	.DESCRIPTION
	    This function retrieves the latest data associated with Audacity
        Invoke-WebRequest queries the site to obtain app release date, version and 
        download URLs. This includes x86 and x64.
        It then outputs the information as a
        PSObject to the Host

        Release Version obtained from https://www.audacityteam.org/download/windows
        Release date obtained from https://wiki.audacityteam.org/wiki/Audacity_Versions

	.EXAMPLE
           PS> Get-OnlineVerAudacity
           Software_Name    : Audacity
           Software_URL     : https://wiki.audacityteam.org/wiki/Release_Notes_3.0.2
           Online_Version   : 3.0.2 
           Online_Date      : 19 Apr 2021
           Download_URL_x86 : https://www.fosshub.com/Audacity.html/audacity-win-3.0.2.exe
           Download_URL_x64 : https://www.fosshub.com/Audacity.html/audacity-win-3.0.2.exe
       	
           PS C:\> Get-OnlineVerAudacity -Quiet
       	   3.0.2
 
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

function Get-OnlineVerAudacity {
    [cmdletbinding()]
    param (
        [Parameter(Mandatory = $false, 
            Position = 0)]
        [switch]
        $Quiet
    )

    begin {
        # Initial Variables
        $SoftwareName = 'Audacity'
        $URI = "https://www.audacityteam.org/download/windows/"
            
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
            $Site = "https://www.audacityteam.org/download/windows/"
            Write-Verbose -Message "Attempting to pull info from the below URL: `n $URI"
            $SiteWiki = "https://wiki.audacityteam.org/wiki/Audacity_Versions"
            $SiteContent = Invoke-WebRequest -Uri $Site -UseBasicParsing
            $SiteWikiContent = Invoke-WebRequest -Uri $SiteWiki -UseBasicParsing
            $SiteWikiContent.Content -match "title=""Release Notes (?<Version>.*)"">" | Out-Null
            $AudacityVersion = $matches['Version']
            $SiteWikiContent.Content -match"</a></span>`n</td>`n<td>(?<ReleaseDate>.*)`n</td>" | Out-Null
            $AudacityReleaseDate = $matches['ReleaseDate']
            $AudacityReleaseNotes = "https://wiki.audacityteam.org/wiki/Release_Notes_" + "$AudacityVersion"
            
            $swObject.Software_URL = $AudacityReleaseNotes
            $swObject.Online_Version = $AudacityVersion
            $swObject.Online_Date = $AudacityReleaseDate

        }
        catch {
            Write-Verbose -Message "Error accessing the below URL: `n $URI"
            $message = $("Line {0} : {1}" -f $_.InvocationInfo.ScriptLineNumber, $_.exception.message)
            $swObject | Add-Member -MemberType NoteProperty -Name 'ERROR' -Value $message
        }
        finally {
          

            # Get the Download URLs
            if ($swObject.Online_Version -ne 'UNKNOWN') {
      
               $AudacityDownloadx86 = "https://www.fosshub.com/Audacity.html/audacity-win-" + "$AudacityVersion.exe"
               $AudacityDownloadx64 = "https://www.fosshub.com/Audacity.html/audacity-win-" + "$AudacityVersion.exe"
               $swObject.Download_URL_x86 = $AudacityDownloadx86
               $swObject.Download_URL_x64 = $AudacityDownloadx64
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
}  # END Function Get-OnlineVerAudacity
