<#
	===========================================================================
	 Created with: 	VS Code 1.56.1/ISE 19042
	 Revision:      v1
	 Last Modified: 21 May 2021
	 Created by:   	Jay Harper (github.com/thecatdidit/powershellusefulscripts)
	 Organizaiton: 	Happy Days Are Here Again
	 Filename:     	Get-OnlineVerLAPS.ps1
	===========================================================================
	.CHANGELOG
	[2021.05.21]
	Script creation

	.SYNOPSIS
        From Microsoft's webiste:
        "The "Local Administrator Password Solution" (LAPS) provides management 
        of local account passwords of domain joined computers. Passwords are 
        stored in Active Directory (AD) and protected by ACL, so only eligible 
        users can read it or request its reset."
        
        Queries the Microsoft webside for the current version of
        the app and returns the version, date updated, and
        download URLs if available.

	.DESCRIPTION
	    This function retrieves the latest data associated with LAPS
        Invoke-WebRequest queries the site to obtain app release date, version and 
        download URLs. This includes x86 and x64.
        It then outputs the information as a
        PSObject to the Host

        Release date and version obtained from https://www.microsoft.com/en-us/download/details.aspx?id=46899

	.EXAMPLE
           PS> Get-OnlineVerLAPS
           Software_Name    : Local Administrator Password Solution (LAPS)
           Software_URL     : https://www.microsoft.com/en-us/download/details.aspx?id=46899
           Online_Version   : 6.2
           Online_Date      : 5/18/2021
           Download_URL_x86 : https://download.microsoft.com/download/C/7/A/C7AAD914-A8A6-4904-88A1-29E657445D03/LAPS.x86.msi
           Download_URL_x64 : https://download.microsoft.com/download/C/7/A/C7AAD914-A8A6-4904-88A1-29E657445D03/LAPS.x64.msi
       	
           PS C:\> Get-OnlineVerAudacity -Quiet
       	   3.0.2
 
 	.INPUTS
        -Quiet
            Use of this parameter will output just the current version of
            LAPS instead of the entire object. It will always be the
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

function Get-OnlineVerLAPS {
    [cmdletbinding()]
    param (
        [Parameter(Mandatory = $false, 
            Position = 0)]
        [switch]
        $Quiet
    )

    begin {
        # Initial Variables
        $SoftwareName = 'Local Administrator Password Solution (LAPS)'
        $URI = "https://www.microsoft.com/en-us/download/details.aspx?id=46899"
            
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
            $LAPSSite = Invoke-WebRequest -Uri $URI -UseBasicParsing
            $LAPSSite.Content -match  "<div class=""header"">
                                                Version:                                            </div><p>(?<Version>.*)</p></div>" | Out-Null
            $LAPSVersion = $Matches['Version']
            $LAPSSite -match "<div class=""header date-published"">
                                                Date Published:                                            </div><p>(?<ReleaseDate>.*)</p></div>" | Out-Null
            $LAPSReleaseDate = $Matches['ReleaseDate']
            $swObject.Software_URL = $URI
            $swObject.Online_Version = $LAPSVersion
            $swObject.Online_Date = $LAPSReleaseDate

        }
        catch {
            Write-Verbose -Message "Error accessing the below URL: `n $URI"
            $message = $("Line {0} : {1}" -f $_.InvocationInfo.ScriptLineNumber, $_.exception.message)
            $swObject | Add-Member -MemberType NoteProperty -Name 'ERROR' -Value $message
        }
        finally {
          

            # Get the Download URLs
            if ($swObject.Online_Version -ne 'UNKNOWN') {
      
               $LAPSDownloadx86 = "https://download.microsoft.com/download/C/7/A/C7AAD914-A8A6-4904-88A1-29E657445D03/LAPS.x86.msi"
               $LAPSDownloadx64 = "https://download.microsoft.com/download/C/7/A/C7AAD914-A8A6-4904-88A1-29E657445D03/LAPS.x64.msi"
               $swObject.Download_URL_x86 = $LAPSDownloadx86
               $swObject.Download_URL_x64 = $LAPSDownloadx64
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
}  # END Function Get-OnlineVerLAPS
