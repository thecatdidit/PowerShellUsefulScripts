<#	
	.NOTES
	===========================================================================
	 Created with: 	PowerShell ISE (Win10 17134)
	 Revision:		v1
	 Last Modified: 30 March 2019
	 Created by:   	Jay Harper (github.com/thecatdidit/powershellusefulscripts)
	 Organizaiton: 	Happy Days Are Here Again
	 Filename:     	Get-OnlineVerWireshark
	===========================================================================
	.Synopsis
        Queries the Wireshark Website for the current version of
        the app and returns the version, date updated, and
        download URLs if available.

        Wireshark maintains a PAD file for automation systems to keep 
        track of new releases.

        Site: https://www.wireshark.org/wireshark-pad.xml
    .DESCRIPTION
	    This function retrieves the latest data associated with Wireshark
        Utilizes Invoke-WebRequest to query the Wireshark download page and
        pulls out the Version, Update Date and Download URLs for
        the app (x64 only) It then outputs the information as a
        PSObject to the Host.
    .EXAMPLE
        PS C:\> Get-OnlineVerWireshark
        
       Software_Name    : Wireshark
       Software_URL     : hhttps://www.wireshark.org/wireshark-pad.xml
       Online_Version   : 3.0.0
       Online_Date      : 2019-02-28
       Download_URL_x64 : https://1.na.dl.wireshark.org/win64/Wireshark-win64-3.0.0.exe

    .INPUTS
        -Quiet
            Use of this parameter will output just the current version of
            Google Chrome instead of the entire object. It will always be the
            last parameter.

        PS C:\> Get-OnlineVerWireshark -Quiet
        3.0.0

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


function Get-OnlineVerWireshark {
    [cmdletbinding()]
    param (
        [Parameter(Mandatory = $false, 
            Position = 0)]
        [switch]
        $Quiet
    )

    begin {
        # Initial Variables
        $SoftwareName = 'Wireshark'
        $uri = "https://www.wireshark.org/wireshark-pad.xml"
            
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
  
            $uri = 'https://www.wireshark.org/wireshark-pad.xml'
            $xml_versions = New-Object XML
            $xml_versions.Load($uri)
            $wiresharkVersion = ($xml_versions.XML_DIZ_INFO.Program_Info.Program_Version).ToString()
            $wiresharkDate = ($xml_versions.XML_DIZ_INFO.Program_Info.Program_Release_Year + "-" + $xml_versions.XML_DIZ_INFO.Program_Info.Program_Release_Month + "-" + $xml_versions.XML_DIZ_INFO.Program_Info.Program_Release_Day).ToString()
            $wiresharkURL = ("https://1.na.dl.wireshark.org/win64/Wireshark-win64-" + $wiresharkVersion + ".exe").ToString()
        
            $swObject.Online_Version = $wiresharkVersion
            $swObject.Online_Date = $wiresharkDate
            $swObject.Download_URL_x64 = $wiresharkURL
 
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
