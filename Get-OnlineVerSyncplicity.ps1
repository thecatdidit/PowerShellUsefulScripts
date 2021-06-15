<#
	===========================================================================
	 Created with: 	VS Code 1.56.1/ISE 19042
	 Revision:      v2
	 Last Modified: 15 June 2021
	 Created by:   	Jay Harper (github.com/thecatdidit/powershellusefulscripts)
	 Organizaiton: 	Happy Days Are Here Again
	 Filename:     	Get-OnlineVerSyncplicity.ps1
	===========================================================================
	.CHANGELOG
	    v2 (15 June 2021)
        .Modify parsing logic to reflect Axway website content change
        v1 (30 Mar 2019)
        .Initial script creation

	.SYNOPSIS
        This function returns details on the current version of Syncplicity.

	.DESCRIPTION
        This function retrieves the latest data associated with Syncplicity
        Invoke-WebRequest queries the site to obtain app release date, version and 
        download URLs.

	.EXAMPLE
           PS> Get-OnlineVerSyncplicity
           Software_Name    : Syncplicity
           Software_URL     : https://docs.axway.com/bundle/Syncplicity/page/windows_desktop_client_release_notes.html
           Online_Version   : 6.3.1
           Online_Date      : April 2021
           Download_URL_x64 : https://download.syncplicity.com/windows/Syncplicity_Setup.exe


           PS C:\> Get-OnlineVerWinzip -Quiet
       	   6.3.1
 
 	.INPUTS
        -Quiet
            Use of this parameter will output just the current version of
            Syncplicity instead of the entire object. It will always be the
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

function Get-OnlineVerSyncplicity {
    [cmdletbinding()]
    param (
        [Parameter(Mandatory = $false, 
            Position = 0)]
        [switch]
        $Quiet
    )

    begin {
        # Initial Variables
        $SoftwareName = 'Syncplicity'
        $uri = 'https://docs.axway.com/bundle/Syncplicity/page/windows_desktop_client_release_notes.html'
            
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
  
            $AppSite = (Invoke-WebRequest -uri $uri -UseBasicParsing).Content
            
            $AppSite -match "About the desktop client on Windows (?<date>.*) Windows Client (?<version>.*) Im" 
            $AppDate = $matches['date']
            $AppVersion = $matches['version'].Substring(0, $version.IndexOf(" "))
            $AppURL = 'https://download.syncplicity.com/windows/Syncplicity_Setup.exe'
        
            $swObject.Online_Version = $AppVersion
            $swObject.Online_Date = $AppDate
            $swObject.Download_URL_x64 = $AppURL
 
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
}  # END Function Get-OnlineVerSyncplicity
