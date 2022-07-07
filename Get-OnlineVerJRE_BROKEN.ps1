<#	

	[07.07.22]: This script is broken. I will investigate when time permits -JH
	
	.NOTES
	===========================================================================
	 Created with: 	PowerShell ISE (Win10 18363)
	 Revision:		2020.03.03.1445
	 Last Modified: 03 March 2020
	 Created by:   	Jay Harper (github.com/thecatdidit/powershellusefulscripts)
	 Organizaiton: 	Happy Days Are Here Again
	 Filename:     	Get-OnlineVerJRE.ps1
	===========================================================================
	.SYNOPSIS
		Queries Oracle's JRE site to determine the current version of 
		the app, date of release and download URL
	.DESCRIPTION
		Invoke-WebRequest (curl) is used to parse the product page. Values
		for desired data are parsed via RegEx into a PSObject.
	.EXAMPLE
		PS C:\> Get-OnlineVerJRE
				Software_Name    : Java Runtime Engine
				Software_URL     : https://www.java.com/en/download/manual.jsp
				Online_Version   : 8 Update 241
				Online_Date      : January 14, 2020
				Download_URL_x64 : https://javadl.oracle.com/webapps/download/AutoDL?BundleId=241534_1f5b5a70bf22433b84d0e960903adac8 
	.INPUTS
		-Quiet
			Use of this parameter will output just the current version of
			Google Chrome instead of the entire object. It will always be the
			last parameter.
	.OUTPUTS
		An object containing the following:
		Software Name: Name of the software
		Software URL: The URL info was sourced from
		Online Version: The current version found
		Online Date: The date the version was updated
		Download URL: Download URL for the win32 version

		If -Quiet is specified then just the value of 'Online Version'
		will be displayed.
	.REFERENCES AND ATTRIBUTIONS
		Richard Tracy (https://github.com/PowerShellCrack)
		Your code helped me better understand how to apply RegEx when parsing HTML. Thank you!
#>

function Get-OnlineVerJRE {
    [cmdletbinding()]
    param (
        [Parameter(Mandatory = $false, 
            Position = 0)]
        [switch]
        $Quiet
    )

    begin {
        # Initial Variables
        $SoftwareName = 'Java Runtime Engine'
        $URI = 'https://www.java.com/en/download/manual.jsp'
            
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
  
            $JREDetails = (Invoke-WebRequest -Uri $uri -UseBasicParsing).Content
        
            $JREDetails -match "<h4 class=`"sub`">Recommended Version (?<version>.*)</h4>" | Out-Null
            $JREVersion = $matches['version']
        
            $JREDetails -match "Release date (?<date>.*)" | Out-Null
            $JREDate = $matches['date']

            $JREDetails -match "<a title=`"Download Java software for Windows Offline`" href=`"(?<download>.*)`">" | Out-Null
            $JREDownload = $matches['download']


            $swObject.Online_Version = $JREVersion
            $swObject.Online_Date = $JREDate
            $swObject.Download_URL_x64 = $JREDownload
 
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
}  # END Function Get-OnlineVerPostman
Get-OnlineVerJRE
