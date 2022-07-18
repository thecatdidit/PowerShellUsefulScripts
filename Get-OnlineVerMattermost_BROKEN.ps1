# [07.18.22]: This script is broken. I will investigate when time permits -JH
 <#
    ===========================================================================
     Created with:  PowerShell ISE - Win10 21H1/19043
     Revision:      2022.05.24
     Last Modified: 24 May 2022
     Created by:    Jay Harper (github.com/thecatdidit/powershellusefulscripts)
     Organizaiton:  Happy Days Are Here Again
     Filename:      Get-OnlineVerMattermost.ps1
    ===========================================================================
    .CHANGELOG
    [2022.05.24]
    Updated scraping logic to capture host-side content changes
    Updated download URL syntax to reflect new host URLs
    [2022.01.06]
    Script creation

    .SYNOPSIS
        Queries the MatterMost webside for the current version of
        the app and returns the version, date updated, and
        download URLs if available.
    
    .DESCRIPTION
        This function retrieves the latest data associated with Mattermost
        Invoke-WebRequest queries the site to obtain app release date, version and 
        download URLs. This includes both the standard EXE installer and the MSI
        instance

        It then outputs the information as a
        PSObject to the Host

        App Site: https://mattermost.com/

    .EXAMPLE
        PS C:\> Get-OnlineVerMattermost

        Software_Name  : Mattermost
        Software_URL   : https://mattermost.com/
        Online_Version : 5.1.0
        Online_Date    : 2022-05-16
        EXE_Installer  : https://releases.mattermost.com/desktop/5.1.0/mattermost-desktop-setup-5.1.0-win.exe
        MSI_Installer  : https://releases.mattermost.com/desktop/5.1.0/mattermost-desktop-5.1.0-x64.msi

        PS C:\> Get-OnlineVerMattermost -Quiet
        5.1.0
 
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
            
            $MMVersionSearchString = "<h2>Release v(?<version>.*)<a class=""headerlink"" href=""#id1"" title=""Permalink to this headline"">"
            $MMDateSearchString = "<p><strong>Release day: (?<date>.*)</strong></p>"
            $MMWebsite = (Invoke-WebRequest -Uri 'https://docs.mattermost.com/install/desktop-app-changelog.html' -UseBasicParsing | Select-Object -ExpandProperty Content)

           
            $MMWebsite -match $MMVersionSearchString | Out-Null
            $ReleaseVersion = ($Matches['version'])
            if (($ReleaseVersion.Substring($ReleaseVersion.Length-1) -ne 0)) { $ReleaseVersion = $ReleaseVersion + ".0" }
                        
            $MMWebsite -match $MMDateSearchString | Out-Null
            $ReleaseDate = ($Matches['date'])
            
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
       
                #Download syntax (Last checked on 24 May 2022)
                #https://releases.mattermost.com/desktop/5.1.0/mattermost-desktop-5.1.0-x64.msi
                #https://releases.mattermost.com/desktop/5.1.0/mattermost-desktop-5.1.0-x64.msi
                #https://releases.mattermost.com/desktop/5.1.0/mattermost-desktop-setup-5.1.0-win.exe
                
                $MMDownloadEXE = "https://releases.mattermost.com/desktop/" + $ReleaseVersion + "/mattermost-desktop-setup-" + $ReleaseVersion + "-win.exe"
                $MMDownloadMSI = "https://releases.mattermost.com/desktop/" + $ReleaseVersion + "/mattermost-desktop-" + $ReleaseVersion + "-x64.msi"                
                
            
            
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
