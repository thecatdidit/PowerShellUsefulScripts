<#
	===========================================================================
	 Created with: 	PowerShell ISE (Win10 18363)
	 Revision:      2020.03.16.1800
	 Last Modified: 16 March 2020
	 Created by:   	Jay Harper (github.com/thecatdidit/powershellusefulscripts)
	 Organizaiton: 	Happy Days Are Here Again
	 Filename:     	Get-OnlineVerVSCode.ps1
	===========================================================================
	.CHANGELOG
	[2020.03.16.1800]
    Initial script creation
	.SYNOPSIS
        This script retrieves information on the current release of Microsoft
        Visual Studio Code. 
    .DESCRIPTION
        Data is obtained from version release feed
        URL: https://code.visualstudio.com/feed.xml
        The version isn't explicity listed as a value, so it is extrapolated from
        the release notes URL
    .EXAMPLE
        PS C:\> Get-OnlineVerVSCode.ps1
        
        Software_Name    : Visual Studio Code
        Software_URL     : https://code.visualstudio.com/updates
        Online_Version   : 1.43
        Online_Date      : Mon Mar 09 2020
        Download_URL_x64 : https://go.microsoft.com/fwlink/?Linkid=852157
        Download_URL_x86 : https://go.microsoft.com/fwlink/?Linkid=852157
    
       	PS C:\> Get-OnlineVerVSCode -Quiet
       	1.43
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
            There are some pending, minor changes to the script, but it is
            functioning correctly at the moment.
#>

function Get-OnlineVerVSCode {

    [cmdletbinding()]
    param (
        [Parameter(Mandatory = $false, 
            Position = 0)]
        [switch]
        $Quiet
    )

    begin {
        # Initial Variables
        $SoftwareName = "Visual Studio Code"
        $uri = 'https://code.visualstudio.com/updates'
       
            
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
            

            $uri = 'https://code.visualstudio.com/feed.xml'
            $AppInfo = New-Object XML
            $AppInfo.Load($uri)
            $AppDate = $AppInfo.feed.entry[0].updated.Substring(0, 15)
            $AppVersion = $AppInfo.feed.entry[0].id.Substring(39, 4).replace("_", ".")
            

            $swObject.Online_Version = $AppVersion
            $swobject.Online_Date = $AppDate
            $swobject.Software_URL = 'https://code.visualstudio.com/updates'
         
        } 
        catch {
            Write-Verbose -Message "Error accessing the below URL: `n $URI"
            $message = $("Line {0} : {1}" -f $_.InvocationInfo.ScriptLineNumber, $_.exception.message)
            $swObject | Add-Member -MemberType NoteProperty -Name 'ERROR' -Value $message
        }
        finally {
          

            # Get the Download URLs
            if ($swObject.Online_Version -ne 'UNKNOWN') {
           
                $swobject.Download_URL_X64 = "https://go.microsoft.com/fwlink/?Linkid=852157"
                $swobject.Download_URL_X86 = "https://go.microsoft.com/fwlink/?Linkid=852157"
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
}  # END Function Get-OnlineVerVSCode
