<#
	===========================================================================
	 Created with: 	PowerShell ISE - Win10 21H1/19043
	 Revision:      v1
	 Last Modified: 06 Jan 2022
	 Created by:   	Jay Harper (github.com/thecatdidit/powershellusefulscripts)
	 Organizaiton: 	Happy Days Are Here Again
	 Filename:     	Get-OnlineVerMattermost.ps1
	===========================================================================
     .CHANGELOG
	[v1 - 2021.06.22]
        Script creatiom

    .SYNOPSIS
        Queries the MatterMost webside for the current version of
        the app and returns the version, date updated, and
        download URLs if available.
	
    .DESCRIPTION
	    This function retrieves the latest data associated with Mattermost
        Invoke-WebRequest queries the site to obtain app release date, version and 
        download URLs. This includes both the standard EXE installer and the MSI
        instance. It then outputs the information as a PSObject to the Host.

        App Site: https://mattermost.com/

    .EXAMPLE
        PS C:\> Get-OnlineVerMattermost

        Software_Name    : Mattermost
        Software_URL     : https://mattermost.com/
        Online_Version   : 5.0.2
        Online_Date      : 2021-11-15
        EXE_Installer    : https://releases.mattermost.com/desktop/5.0.2/mattermost-desktop-setup-5.0.2-win.exe?src=dl
        MSI_Installer    : https://releases.mattermost.com/desktop/5.0.2/mattermost-desktop-setup-5.0.2-win.exe?src=dl
    
       	PS C:\> Get-OnlineVerMattermost -Quiet
       	5.0.2
    
	.INPUTS
	    -Quiet
            Use of this parameter will output just the current version of
            Mattermost instead of the entire object. It will always be the
            last parameter
	    
	.OUTPUTS
            An object containing the following:
            Software Name: Name of the software
            Software URL: The URL info was sourced from
            Online Version: The current version found
            Online Date: The date the version was updated
            EXE Installer: Direct download link for the EXE-based installer
            MSI Installer: Direct download link for the MSI-based installed
    
            If -Quiet is specified then just the value of 'Online Version'
            will be displayed.
	.NOTES
            Resources/Credits:
            https://github.com/itsontheb
#>

function Get-OnlineVerMattermost {
    [cmdletbinding()]
    param (
        [Parameter(Mandatory = $false, 
            Position = 0)]
        [switch]
        $Quiet
    )

    begin {
        # Initial Variables
        $SoftwareName = 'Mattermost'
        $URI = 'https://mattermost.com/'
            
        $hashtable = [ordered]@{
            'Software_Name'    = $softwareName
            'Software_URL'     = $uri
            'Online_Version'   = 'UNKNOWN' 
            'Online_Date'      = 'UNKNOWN'
            'EXE_Installer' = 'UNKNOWN'
            'MSI_Installer' = 'UNKNOWN'
        }
    
        $swObject = New-Object -TypeName PSObject -Property $hashtable
    }


    Process {
        # Get the Version & Release Date
        try {
            Write-Verbose -Message "Attempting to pull info from the below URL: `n $URI"
            $URI = 'https://docs.mattermost.com/install/desktop-app-changelog.html'
            $MMURL = (Invoke-WebRequest -Uri $URI -UseBasicParsing | Select-Object -ExpandProperty Content)
            $MMURL -match "<li><p><strong>v(?<version>.*), released (?<date>.*)</strong></p></li>" | Out-Null
             
            $MMVersion = ($matches['version'])
            $MMDate = ($matches['date'])
            
            $swObject.Online_Version = $MMVersion
            $swObject.Online_Date = $MMDate

        }
        catch {
            Write-Verbose -Message "Error accessing the below URL: `n $URI"
            $message = $("Line {0} : {1}" -f $_.InvocationInfo.ScriptLineNumber, $_.exception.message)
            $swObject | Add-Member -MemberType NoteProperty -Name 'ERROR' -Value $message
        }
        finally {
          

            # Get the Download URLs
            if ($swObject.Online_Version -ne 'UNKNOWN') {
       
                $MMDownloadEXE = "https://releases.mattermost.com/desktop/" + $ReleaseVersion + "/mattermost-desktop-setup-" + $ReleaseVersion + "-win.exe?src=dl"
                $MMDownloadMSI = "https://releases.mattermost.com/desktop/" + $ReleaseVersion + "/mattermost-desktop-" + $ReleaseVersion + "-x64.msi?src=dl"                
                
            
            
                $swObject.EXE_Installer = $MMDownloadEXE
                $swObject.MSI_Installer = $MMDownloadMSI
                
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
}  # END Function Get-OnlineVerMattermost
