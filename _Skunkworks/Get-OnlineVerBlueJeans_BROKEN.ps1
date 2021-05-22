<# WARNING - SOURCE LINKS OR OTHER RESOURCES HAVE CHANGED, AND THIS SCRIPT MUST BE UPDATED. THIS WARNING WILL BE REMOVED ONCE THE CODE CHANGE IS IN PLACE. YOU HAVE BEEN WARNED.
 # Wed 08 Apr 2021
#>
 
 <#	
	.NOTES
	===========================================================================
	 Created with: 	PowerShell ISE (Win10 17134)
	 Revision:	v1
	 Last Modified: 30 March 2019
	 Created by:   	Jay Harper (github.com/thecatdidit/powershellusefulscripts)
	 Organizaiton: 	Happy Days Are Here Again
	 Filename:     	Get-OnlineVerBlueJeans.ps1
	===========================================================================
	.Synopsis
        Queries the BlueJeans Website for the current version of
        the app and returns the version, date updated, and
        download URLs if available.
    .DESCRIPTION
	    This function retrieves the latest data associated with BlueJeans
        Utilizes Invoke-WebRequest to query the Postman download page and
        pulls out the Version, Update Date and Download URLs for
        the app (x64 only) It then outputs the information as a
        PSObject to the Host.
    .EXAMPLE
        PS C:\> Get-OnlineVerPostman
        
        Software_Name    : Blue Jeans
        Software_URL     : https://support.bluejeans.com/knowledge/desktop-app-deployment
        Online_Version   : 2.11.593m
        Online_Date      : March 21, 2019
        Download_URL_x64 : https://swdl.bluejeans.com/desktop-app/win/2.11.593.0/BlueJeans.2.11.593m.msi

        
    .INPUTS
        -Quiet
            Use of this parameter will output just the current version of
            Google Chrome instead of the entire object. It will always be the
            last parameter.

        PS C:\> Get-OnlineVerBlueJeans -Quiet
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


function Get-OnlineVerBlueJeans {
    [cmdletbinding()]
    param (
        [Parameter(Mandatory = $false, 
            Position = 0)]
        [switch]
        $Quiet
    )

    begin {
        # Initial Variables
        $SoftwareName = 'Blue Jeans'
        $uri = "https://support.bluejeans.com/knowledge/desktop-app-deployment"
            
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
  
            $site = (Invoke-WebRequest -uri $uri -UseBasicParsing).Content

            $site -match "Last Updated: (?<date>.*) //" | Out-Null
            $blueJeansDate = $matches['date']

            $site -match "Command Line Switch for silent deployment: msiexec /i "“BlueJeans.(?<version>.*).msi" | Out-Null
            $blueJeansVersion = $matches['version']

            $blueJeansURL = "https://swdl.bluejeans.com/desktop-app/win/" + $blueJeansVersion.Replace("m", "") + ".0/BlueJeans." + $blueJeansVersion + ".msi"
        
            $swObject.Online_Version = $blueJeansVersion
            $swObject.Online_Date = $blueJeansDate
            $swObject.Download_URL_x64 = $blueJeansURL
 
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
}  # END Function Get-OnlineVerBlueJeans
