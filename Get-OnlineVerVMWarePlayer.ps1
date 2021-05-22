<#	
    ===========================================================================
	 Created with: 	PowerShell ISE (Win10 19342)
	 Revision:		v1
	 Last Modified: 22 May 2021
	 Created by:   	Jay Harper (github.com/thecatdidit/powershellusefulscripts)
	 Organizaiton: 	Happy Days Are Here Again
	 Filename:     	Get-OnlineVerVMWarePlayer.ps1
    ===========================================================================
    .CHANGELOG
    v1 (2021.05.22)
    Initial script creation
    
    .SYNOPSIS
        Queries the VMWare website for the current version of
        the app and returns the version, release date and
        download URLs if available.

    .DESCRIPTION
	    This function retrieves the latest data associated with VMWare Workstation
        Player. The app's website is parsed for an available Version, Release Date
        and Download URLs.

        Note: No x86 version of the application is available.

    .EXAMPLE
        PS C:\> Get-OnlineVerVMWarePlayer.ps1
        
        Software_Name    : VMWare Workstation Player
        Software_URL     : https://docs.vmware.com/en/VMware-Workstation-Player/index.html
        Online_Version   : 16.1.2
        Online_Date      : 17 May 2021
        Download_URL_x86 : X86 VERSION NOT AVAILABLE
        Download_URL_x64 : https://www.vmware.com/go/getplayer-win
 
    .INPUTS
        -Quiet
            Use of this parameter will output just the current version of
            VMWare Workstation Player instead of the entire object. It will 
            always be the last parameter.

        PS C:\> Get-OnlineVerVMWarePlayer.ps1 -Quiet
        16.1.2

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

function Get-OnlineVerVMWarePlayer {
    [cmdletbinding()]
    param (
        [Parameter(Mandatory = $false, 
            Position = 0)]
        [switch]
        $Quiet
    )

    begin {
        # Initial Variables
        $SoftwareName = 'VMWare Workstation Player'
        $URI = "https://docs.vmware.com/en/VMware-Workstation-Player/rn_rss.xml"
            
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
            [xml]$VMWareSite = Invoke-WebRequest -Uri $URI -UseBasicParsing  
            $ReleaseInfo = $VMWareSite.feed.entry[0]
            $ReleaseInfo.subtitle -match "VMware Workstation Player (?<Version>.*)" | Out-Null
            $ReleaseVersion = $Matches['Version']
            $ReleaseDate = $Releaseinfo.updated.Substring(0, 10)
            $ReleaseDate = [datetime]::parseexact($ReleaseDate, 'yyyy-MM-dd', $null).ToString('dd MMM yyyy')
            $swObject.Software_URL = "https://docs.vmware.com/en/VMware-Workstation-Player/index.html"
            $swObject.Online_Version = $ReleaseVersion
            $swObject.Online_Date = $ReleaseDate

        }
        catch {
            Write-Verbose -Message "Error accessing the below URL: `n $URI"
            $message = $("Line {0} : {1}" -f $_.InvocationInfo.ScriptLineNumber, $_.exception.message)
            $swObject | Add-Member -MemberType NoteProperty -Name 'ERROR' -Value $message
        }
        finally {
          

            # Get the Download URLs
            if ($swObject.Online_Version -ne 'UNKNOWN') {
      
                $AppDownloadx86 = "X86 VERSION NOT AVAILABLE"
                $AppDownloadx64 = "https://www.vmware.com/go/getplayer-win"
                $swObject.Download_URL_x86 = $AppDownloadx86
                $swObject.Download_URL_x64 = $AppDownloadx64
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
}  # END Function Get-OnlineVerVMWarePlayer
