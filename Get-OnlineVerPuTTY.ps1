<#
	===========================================================================
	 Created with: 	VS Code 1.56.1/ISE 19043
	 Revision:      v1
	 Last Modified: 16 June 2021
	 Created by:   	Jay Harper (github.com/thecatdidit/powershellusefulscripts)
	 Organizaiton: 	Happy Days Are Here Again
	 Filename:     	Get-OnlineVerPuTTY.ps1
	===========================================================================
	.CHANGELOG
	v1 [2021.06.16]
	Script creation

	.SYNOPSIS
        This script queries details on the latest release of PuTTY.
        
	.DESCRIPTION
        PuTTY's official site is parsed to obtain release data (Name, Version, Reference URL, Direct download
        URLs).

	.EXAMPLE
           PS> Get-OnlineVerPuTTY
           Software_Name    : PuTTY
           Software_URL     : https://www.chiark.greenend.org.uk/~sgtatham/putty/latest.html
           Online_Version   : 0.75
           Online_Date      : 2021-05-08
           Download_URL_x86 : UNAVAILABLE
           Download_URL_x64 : https://the.earth.li/~sgtatham/putty/latest/w64/putty-64bit-0.75-installer.msi
       	
           PS> Get-OnlineVerPuTTY -Quiet
       	   0.75
 
 	.INPUTS
        -Quiet
            Use of this parameter will output just the current version of
            PuTTY instead of the entire object. It will always be the
            last parameter
	    
	.OUTPUTS
            An object containing the following:
            Software Name: Name of the software
            Software URL: The URL info was sourced from
            Online Version: The current version found
            Online Date: The date the version was updated
            Download URL x64: Direct download link for the x64 version
            Download URL x86: THIS IS UNAVAILABLE
	    
            If -Quiet is specified then just the value of 'Online Version'
            will be displayed.
	
    .NOTES
            Resources/Credits:
            https://github.com/itsontheb
#>

function Get-OnlineVerPuTTY {
    [cmdletbinding()]
    param (
        [Parameter(Mandatory = $false, 
            Position = 0)]
        [switch]
        $Quiet
    )

    begin {
        # Initial Variables
        $SoftwareName = 'PuTTY'
        $URI = "https://www.chiark.greenend.org.uk/~sgtatham/putty/latest.html"
            
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
            $AppSite = Invoke-WebRequest -Uri $URI -UseBasicParsing
            $AppSite.Content -match "PuTTY.`nCurrently this is (?<version>.*), released on (?<date>.*)." | Out-Null
            $AppVersion = $Matches['Version']
            $AppDate = $Matches['Date']
            
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
      
               $AppDownloadx64 = "https://the.earth.li/~sgtatham/putty/latest/w64/putty-64bit-" + $AppVersion + "-installer.msi"
               $AppDownloadx86 = "UNAVAILABLE"
               $swObject.Download_URL_x64 = $AppDownloadx64
               $swObject.Download_URL_x86 = $AppDownloadx86
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
}  # END Function Get-OnlineVerPuTTY
