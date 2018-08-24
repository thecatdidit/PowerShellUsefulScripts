<#	
	.NOTES
	===========================================================================
	 Created with: 	PowerShell ISE (Win10 17134)
	 Revision:		v5
	 Last Modified: 24 August 2018
	 Created by:   	Jay Harper (github.com/thecatdidit/powershellusefulscripts)
	 Organizaiton: 	Happy Days Are Here Again
	 Filename:     	Get-OnlineVerFlashPlayer.ps1
	===========================================================================
	.Synopsis
        Queries Adobe's Flash Player Website for the current version of
        the app and returns the version, date updated, and
        download URLs if available.
    .DESCRIPTION
	    This function retrieves the latest data associated with Adobe Flash Player
        Invoke-WebRequest queries the site to obtain app release date, version and 
        download URLs. This includes NPAPI, PPAPI and ActiveX
        It then outputs the information as a
        PSObject to the Host.

    .NOTE: 
        At the moment, the release date of Flash Player is being obtained from FileHippo.
        Once I have a bit of spare time, I will try and change this to use of the vendor site.

    .EXAMPLE
        PS C:\> Get-OnlineVerFlashPlayer.ps1

        Software_Name        : Adobe Flash Player
        Software_URL         : https://fpdownload.macromedia.com/pub/flashplayer/masterversion/masterversion.xml
        Online_Version       : 30.0.0.154
        Online_Date          : August 21, 2018
        Download_URL_PPAPI   : https://fpdownload.macromedia.com/pub/flashplayer/pdc/30.0.0.154/install_flash_player_30_ppapi.msi
        Download_URL_NPAPI   : https://fpdownload.macromedia.com/pub/flashplayer/pdc/30.0.0.154/install_flash_player_30_plugin.msi
        Download_URL_ActiveX : https://fpdownload.macromedia.com/pub/flashplayer/pdc/30.0.0.154/install_flash_player_30_active_X.msi

    
        PS C:\> Get-OnlineVeNotePadPlusPlus -Quiet
        30.0.0.154
    
    
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
            Download URL PPAPI: Download URL for the NPAPI version
            Download URL PPAPI: Download URL for the ActiveX version
    
            If -Quiet is specified then just the value of 'Online Version'
            will be displayed.
    .NOTES
            Resources/Credits:
            https://github.com/itsontheb

#>

function Get-OnlineVerFlashPlayer
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
        $SoftwareName = "Adobe Flash Player"
        $uri = 'https://fpdownload.macromedia.com/pub/flashplayer/masterversion/masterversion.xml'
       
            
        $hashtable = [ordered]@{
            'Software_Name'    = $softwareName
            'Software_URL'     = $uri
            'Online_Version'   = 'UNKNOWN' 
            'Online_Date'      = 'UNKNOWN'
            'Download_URL_PPAPI' = 'UNKNOWN'
            'Download_URL_NPAPI' = 'UNKNOWN'
            'Download_URL_ActiveX' = 'UNKNOWN'
        }
    
        $swObject = New-Object -TypeName PSObject -Property $hashtable
    }


   Process
    {
        # Get the Version & Release Date
        try
        {
            Write-Verbose -Message "Attempting to pull info from the below URL: `n $URI"
            

        $uri = 'https://fpdownload.macromedia.com/pub/flashplayer/masterversion/masterversion.xml'
        $xml_versions = New-Object XML
        $xml_versions.Load($uri)
        $FlashMajorVersion = ($xml_versions.version.release.NPAPI_win.version).Substring(0,2)
        $FlashFullVersion = ($xml_versions.version.release.NPAPI_win.version).replace(",",".")
        $FlashURLPrefix = "https://fpdownload.macromedia.com/pub/flashplayer/pdc/" + $FlashFullVersion
        $FlashDateURI= (curl -Uri https://filehippo.com/download_adobe-flash-player/tech -UseBasicParsing | Select-Object Content -ExpandProperty Content)
        $FlashDateURI -match "Date added:</span> <span class=""field-value"">`r`n                                (?<content>.*)</span>" | Out-Null
        $app1Date = ($matches['content'])
        $swObject.Online_Version = $FlashFullVersion
        $swobject.Online_Date = $app1Date
        
         
        } 
        catch
        {
            Write-Verbose -Message "Error accessing the below URL: `n $URI"
            $message = $("Line {0} : {1}" -f $_.InvocationInfo.ScriptLineNumber, $_.exception.message)
            $swObject | Add-Member -MemberType NoteProperty -Name 'ERROR' -Value $message
        }
        finally
        {
          

        # Get the Download URLs
        if ($swObject.Online_Version -ne 'UNKNOWN')
        {
           
            
           $FlashURLPPAPI = $FlashURLPrefix + "/install_flash_player_" + $FlashMajorVersion + "_ppapi.msi"
           $FlashURLActiveX = $FlashURLPRefix + "/install_flash_player_" + $FlashMajorVersion + "_active_X.msi"
           $FLashURLNPAPI = $FlashURLPRefix +  "/install_flash_player_" + $FlashMajorVersion + "_plugin.msi"

            $swObject.DOWNLOAD_URL_PPAPI = $FlashURLPPAPI
            $swObject.DOWNLOAD_URL_NPAPI = $FlashURLNPAPI
            $swObject.DOWNLOAD_URL_ActiveX = $FlashURLActiveX
        }
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
}  # END Function Get-OnlineVerFlashPlayer