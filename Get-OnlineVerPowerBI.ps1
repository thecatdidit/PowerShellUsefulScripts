<#	
	.NOTES
	===========================================================================
	 Created with: 	PowerShell ISE (Win10 17134)
	 Revision:		v2020.02.17.1130
	 Last Modified: 17 February 2020
	 Created by:   	Jay Harper (github.com/thecatdidit/powershellusefulscripts)
	 Organizaiton: 	Happy Days Are Here Again
	 Filename:     	Get-OnlineVerPowerBI.ps1
	===========================================================================
	.CHANGELOG
	    [2020.02.17.1130]
	    Updated URI content query to reflect MS site content changes
	
	.SYNOPSIS
        Queries the PowerBI Website for the current version of
        the app and returns the version, date updated, and
        download URLs if available.
    
	.DESCRIPTION
	    This function retrieves the latest data associated with PowerBI
        Utilizes Invoke-WebRequest to query the Postman download page and
        pulls out the Version, Update Date and Download URLs for
        the app (x64 only) It then outputs the information as a
        PSObject to the Host.
    
	.EXAMPLE
        PS C:\> Get-OnlineVerPowerBI
        
        Software_Name    : PowerBI
        Software_URL     : https://docs.microsoft.com/en-us/power-bi/desktop-latest-update
        Online_Version   : 2.78.5740.721
        Online_Date      : 2/15/2020
        Download_URL_x64 : https://download.microsoft.com/download/8/8/0/880BCA75-79DD-466A-927D-1ABF1F5454B0/PBIDesktopSetup_x64.exe
	
	.INPUTS
        -Quiet
            Use of this parameter will output just the current version of
            Google Chrome instead of the entire object. It will always be the
            last parameter.

        PS C:\> Get-OnlineVerPowerBI -Quiet
        2.11.593m

	.OUTPUTS
        An object containing the following:
        Software Name: Name of the software
        Software URL: The URL info was sourced from
        Online Version: The current version found
        Online Date: The date the version was updated
        Download URL x64: Download URL for the win64 version
    
        If -Quiet is specified then just the value of 'Online Version'
        will be displayed.
	.NOTES
		Resources/Credits:
		https://github.com/itsontheb

#>


function Get-OnlineVerPowerBI
{
    [cmdletbinding()]
    param (
        [Parameter(Mandatory=$false, 
                   Position=0)]
        [switch]
        $Quiet
    )

    begin
    {
        # Initial Variables
        $SoftwareName = 'PowerBI'
        $uri = "https://docs.microsoft.com/en-us/power-bi/desktop-latest-update"
            
        $hashtable = [ordered]@{
            'Software_Name'    = $softwareName
            'Software_URL'     = $uri
            'Online_Version'   = 'UNKNOWN' 
            'Online_Date'      = 'UNKNOWN'
            'Download_URL_x64' = 'UNKNOWN'
        }
    
        $swObject = New-Object -TypeName PSObject -Property $hashtable
}


   Process
    {
        # Get the Version & Release Date
        try
        {
        $uri2 = 'https://www.microsoft.com/en-us/download/details.aspx?id=58494'
        $site = (curl -uri $uri2 -UseBasicParsing | select -ExpandProperty Content)
        $site -match "Version:                                            </div><p>(?<version>.*)</p>" | Out-Null
        $biVersion = $matches['version']
        $site -match "Date Published:                                            </div><p>(?<date>.*)</p>" | Out-Null
        $biDate = $matches['date']
        $biDownloadURL = "https://download.microsoft.com/download/8/8/0/880BCA75-79DD-466A-927D-1ABF1F5454B0/PBIDesktopSetup_x64.exe"
        
        $swObject.Online_Version = $biVersion
        $swObject.Online_Date = $biDate
        $swObject.Download_URL_x64 = $biDownloadURL
 
         }
        catch
        {
            Write-Verbose -Message "Error accessing the below URL: `n $URI"
            $message = $("Line {0} : {1}" -f $_.InvocationInfo.ScriptLineNumber, $_.exception.message)
            $swObject | Add-Member -MemberType NoteProperty -Name 'ERROR' -Value $message
        }
        finally
        {
   
    }
    }
    End
    {
        # Output to Host
        if ($Quiet)
        {
            Write-Verbose -Message '$Quiet was specified. Returning just the version'
            Return $swObject.Online_Version
        }
        else
        {
            Return $swobject
        }
    }
}  # END Function Get-OnlineVerPowerBI
