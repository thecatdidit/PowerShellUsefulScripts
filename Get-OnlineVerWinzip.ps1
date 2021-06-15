
<#
	===========================================================================
	 Created with: 	VS Code 1.56.1/ISE 19042
	 Revision:      v1
	 Last Modified: 15 June 2021
	 Created by:   	Jay Harper (github.com/thecatdidit/powershellusefulscripts)
	 Organizaiton: 	Happy Days Are Here Again
	 Filename:     	Get-OnlineVerWinzip.ps1
	===========================================================================
	.CHANGELOG
	    v1 (15 June 2021)
        .Initial script creation

	.SYNOPSIS
        This function returns details on the current version of Winzip.

	.DESCRIPTION
        This function retrieves the latest data associated with Winzip
        Invoke-WebRequest queries the site to obtain app release date, version and 
        download URLs. This includes x86 and x64.
        It then outputs the information as a
        PSObject to the Host

	.EXAMPLE
           PS> Get-OnlineVerWinzip
           Software_Name    : Winzip
           Software_URL     : https://www.winzip.com/win/en/downwz.html
           Online_Version   : 25.0.build14245
           Online_Date      : February 19, 2021
           Download_URL_x86 : UNAVAILABLE
           Download_URL_x64 : https://download.winzip.com/gl/nkln/winzip25-downwz.exe


           PS C:\> Get-OnlineVerWinzip -Quiet
       	   25.0.build14245

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

function Get-OnlineVerWinzip {
    [cmdletbinding()]
    param (
        [Parameter(Mandatory = $false, 
            Position = 0)]
        [switch]
        $Quiet
    )

    begin {
        # Initial Variables
        $SoftwareName = 'Winzip'
        $URI = "https://www.winzip.com/win/en/downwz.html"
            
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
            $AppSite = Invoke-WebRequest -Uri "https://en.wikipedia.org/wiki/WinZip#cite_note-1" -UseBasicParsing
            $AppSite.content -match "Microsoft Windows"">Windows</a></th><td class=""infobox-data"">(?<version>.*) \/ (?<date>.*)<span class=""noprint"">&#59;&#(?<when>.*)</span><span style=""display:none"">&#160"
            $AppVersion = $Matches['version'].Split(" ")[0]
            $AppDate = $Matches['date'].Replace("&#160;", " ")
            $swObject.Software_URL = $URI
            $swObject.Online_Version = $AppVersion
            $swObject.Online_Date = $AppDate

        }
        catch {
            Write-Verbose -Message "Error accessing the below URL: `n $URI"
            $message = $("Line {0} : {1}" -f $_.InvocationInfo.ScriptLineNumber, $_.exception.message)
            $swObject | Add-Member -MemberType NoteProperty -Name 'ERROR' -Value $message
        }
        finally {
          

            # Get the Download URLs
            if ($swObject.Online_Version -ne 'UNKNOWN') {
      
                $LAPSDownloadx86 = "UNAVAILABLE"
                $LAPSDownloadx64 = "https://download.winzip.com/gl/nkln/winzip" + $version.Split(".")[0] + "-downwz.exe"
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
}
#END function Get-OnlineVerWinzip
