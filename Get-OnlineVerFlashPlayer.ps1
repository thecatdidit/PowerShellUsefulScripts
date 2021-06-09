<#	
    .NOTES
	===========================================================================
	 Created with: 	PowerShell ISE (Win10 17134)
	 Revision:      v1
	 Last Modified: 09 June 2021
	 Created by:   	Jay Harper (github.com/thecatdidit/powershellusefulscripts)
	 Organizaiton: 	Happy Days Are Here Again
	 Filename:     	Get-OnlineVerFlashPlayer.ps1
	===========================================================================
    .CHANGELOG
        v1 (09 June 2021)
        Rewrite of the script

    .SYNOPSIS
        This script queries for info on the most recent release of Adobe
        Acrobat Flash Player.

	.DESCRIPTION
        This function scrapes and parses data from Adobe and FileHippo in order to 
        determine full release info. Adobe does not pair release dates with the Flash
        Player versions, so FileHippo is used to get that piece.

    .EXAMPLE
        PS C:\> Get-OnlineVerFlashPlayer.ps1

                Software_Name        : Adobe Flash Player
                Software_URL         : https://fpdownload.macromedia.com/pub/flashplayer/masterversion/masterversion.xml
                Online_Version       : 32.0.0.465
                Online_Date          : Tuesday, June 11th 2019
                Download_URL_PPAPI   : https://fpdownload.macromedia.com/pub/flashplayer/pdc/32.0.0.465/install_flash_player_32_ppapi.msi
                Download_URL_NPAPI   : https://fpdownload.macromedia.com/pub/flashplayer/pdc/32.0.0.465/install_flash_player_32_plugin.msi
                Download_URL_ActiveX : https://fpdownload.macromedia.com/pub/flashplayer/pdc/32.0.0.465/install_flash_player_32_active_X.msi
        
        PS C:\> Get-OnlineVerFlashPlayer -Quiet
                32.0.0.465
    
    .INPUTS
        -Quiet
            Use of this parameter will output just the current version of
            Flash Player instead of the entire object. It will always be the
            last parameter.
    .OUTPUTS
            An object containing the following:
            Software Name: Name of the software
            Software URL: The URL info was sourced from
            Online Version: The current version found
            Online Date: The date the version was updated
            Download URL PPAPI: Download URL for the PPAPI version
            Download URL NPAPI: Download URL for the NPAPI version
            Download URL ActiveX: Download URL for the ActiveX version
    
            If -Quiet is specified then just the value of 'Online Version'
            will be displayed.
    .NOTES
            Resources/Credits:
            https://github.com/itsontheb (for help with creation of the update PSObject)
#>

#Allows TLS 1.2 for FileHippo HTTPS access
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

function Get-OnlineVerFlashPlayer {

    [cmdletbinding()]
    param (
        [Parameter(Mandatory = $false, 
            Position = 0)]
        [switch]
        $Quiet
    )

    begin {
        # Initial Variables
        $SoftwareName = "Adobe Flash Player"
        $uri = 'https://fpdownload.macromedia.com/pub/flashplayer/masterversion/masterversion.xml'
       
            
        $hashtable = [ordered]@{
            'Software_Name'        = $softwareName
            'Software_URL'         = $uri
            'Online_Version'       = 'UNKNOWN' 
            'Online_Date'          = 'UNKNOWN'
            'Download_URL_PPAPI'   = 'UNKNOWN'
            'Download_URL_NPAPI'   = 'UNKNOWN'
            'Download_URL_ActiveX' = 'UNKNOWN'
        }
    
        $swObject = New-Object -TypeName PSObject -Property $hashtable
    }


    Process {
        # Get the Version & Release Date
        try {
            Write-Verbose -Message "Attempting to pull info from the below URL: `n $URI"
            

            $uri = 'https://fpdownload.macromedia.com/pub/flashplayer/masterversion/masterversion.xml'
            $xml_versions = New-Object XML
            $xml_versions.Load($uri)
            $FlashMajorVersion = ($xml_versions.version.release.NPAPI_win.version).Substring(0, 2)
            $FlashFullVersion = ($xml_versions.version.release.NPAPI_win.version).replace(",", ".")
            $FlashURLPrefix = "https://fpdownload.macromedia.com/pub/flashplayer/pdc/" + $FlashFullVersion
            $FlashDateURI = (Invoke-WebRequest -Uri https://filehippo.com/download_adobe-flash-player/tech -UseBasicParsing | Select-Object Content -ExpandProperty Content)
            $FlashDateURI -match "Date added:</dt><dd data-qa=""program-technical-date"">(?<date>.*)</dd><dt data-qa" | Out-Null
            $appDate = ($matches['date'])
            $swObject.Online_Version = $FlashFullVersion
            $swobject.Online_Date = $appDate
        
         
        } 
        catch {
            Write-Verbose -Message "Error accessing the below URL: `n $URI"
            $message = $("Line {0} : {1}" -f $_.InvocationInfo.ScriptLineNumber, $_.exception.message)
            $swObject | Add-Member -MemberType NoteProperty -Name 'ERROR' -Value $message
        }
        finally {
          

            # Get the Download URLs
            if ($swObject.Online_Version -ne 'UNKNOWN') {
           
            
                $FlashURLPPAPI = $FlashURLPrefix + "/install_flash_player_" + $FlashMajorVersion + "_ppapi.msi"
                $FlashURLActiveX = $FlashURLPRefix + "/install_flash_player_" + $FlashMajorVersion + "_active_X.msi"
                $FLashURLNPAPI = $FlashURLPRefix + "/install_flash_player_" + $FlashMajorVersion + "_plugin.msi"

                $swObject.DOWNLOAD_URL_PPAPI = $FlashURLPPAPI
                $swObject.DOWNLOAD_URL_NPAPI = $FlashURLNPAPI
                $swObject.DOWNLOAD_URL_ActiveX = $FlashURLActiveX
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
}  # END Function Get-OnlineVerFlashPlayer
