<#
    ===========================================================================
     Created with:	VS Code 1.56.1/ISE 19042
     Revision:		2022.05.24
     Last Modified:	24 May 2022
     Created by:   	Jay Harper (github.com/thecatdidit/powershellusefulscripts)
     Organizaiton: 	Happy Days Are Here Again
     Filename:     	Get-OnlineVerAudacity.ps1
    ===========================================================================
    .CHANGELOG
    [2022.05.24]
    Changed version query source to Github release feed
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
           Software_URL     : https://wiki.audacityteam.org/wiki/Release_Notes_3.1.3
           Online_Version   : 3.1.3
           Online_Date      : 2021-12-22
           Download_URL_x86 : https://github.com/audacity/audacity/releases/download/Audacity-3.1.3/audacity-win-3.1.3-32bit.exe
           Download_URL_x64 : https://github.com/audacity/audacity/releases/download/Audacity-3.1.3/audacity-win-3.1.3-64bit.exe
       	
           PS C:\> Get-OnlineVerAudacity -Quiet
       	   3.1.3
 
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
	    https://github.com/aaronparker
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
         
         
            $Site = "https://api.github.com/repos/audacity/audacity/releases/latest"
            $AppInfo = (Invoke-WebRequest -Uri $Site -UseBasicParsing).Content | ConvertFrom-Json
            #Obtain app release version
            $AppVersion = $AppInfo.tag_name
            $Begin = $AppVersion.IndexOf("-") + 1
            $End = $AppVersion.Length
            $AppVersion = $AppVersion.Substring($begin,$End - $Begin)
            #Obtain app relase date
            $AppDate = $AppInfo.created_at
            $Begin = 0
            $End = $AppDate.IndexOf("T")
            $AppDate = $AppDate.Substring(0,$End)
            #Obtain URL for the current release notes
            $AppNotes = "https://wiki.audacityteam.org/wiki/Release_Notes_" + "$AppVersion"
            
            $swObject.Online_Version = $AppVersion
            $swObject.Online_Date = $AppDate
            $swObject.Software_URL = $AppNotes

            <# The prior query logic is being kept in comment for future reference
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
            #>
        }
        catch {
            Write-Verbose -Message "Error accessing the below URL: `n $URI"
            $message = $("Line {0} : {1}" -f $_.InvocationInfo.ScriptLineNumber, $_.exception.message)
            $swObject | Add-Member -MemberType NoteProperty -Name 'ERROR' -Value $message
        }
        finally {
          

            # Get the Download URLs
            if ($swObject.Online_Version -ne 'UNKNOWN') {
      
               #Sample Download URL
               #https://github.com/audacity/audacity/releases/download/Audacity-3.1.3/audacity-win-3.1.3-64bit.exe
               $AudacityDownloadx86 = "https://github.com/audacity/audacity/releases/download/Audacity-" + $AppVersion + "/audacity-win-" + $AppVersion + "-32bit.exe"
               $AudacityDownloadx64 = "https://github.com/audacity/audacity/releases/download/Audacity-" + $AppVersion + "/audacity-win-" + $AppVersion + "-64bit.exe"
               
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
