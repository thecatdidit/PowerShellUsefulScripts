<#
    ===========================================================================
     Created with:  PowerShell ISE - Win10 22H2/19045
     Revision:      v2
     Last Modified: 09 April 2024
     Created by:    Jay Harper (github.com/thecatdidit/powershellusefulscripts)
     Organizaiton:  Happy Days Are Here Again
     Filename:      Get-OnlineVerKeePass.ps1
    ===========================================================================
    .CHANGELOG
     v2 [04.09.24] Updates to reflect the offial app's release feed
     v1 [03.31.22] Initial script creation
    
    .SYNOPSIS
        Queries for the current version of KeePass and returns the version, date updated, and
        download URLs if available.
    
    .DESCRIPTION
        This function retrieves the latest data associated with KeePass
        Invoke-WebRequest queries the site to obtain app release date, version and 
        download URLs. This includes both the standard EXE installer and the MSI
        instance

        It then outputs the information as a
        PSObject to the Host

        App Release Feed (JSON): https://sourceforge.net/projects/keepass/best_release.json

    .EXAMPLE
        PS C:\> Get-OnlineVerKeePass.ps1

        Software_Name  : KeePass
        Software_URL   : https://keepass.info/
        Online_Version : 2.56
        Online_Date    : 2024-02-04
        Download_URL_x64: https://sourceforge.net/projects/keepass/files/KeePass%202.x/2.56/KeePass-2.56-Setup.exe/download
    
        PS C:\> Get-OnlineVerKeePass -Quiet
        2.56
 
    .INPUTS
        -Quiet
            Use of this parameter will output just the current version of
            KeePass instead of the entire object. It will always be the
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

function Get-OnlineVerKeePass {
    [cmdletbinding()]
    param (
        [Parameter(Mandatory = $false, 
            Position = 0)]
        [switch]
        $Quiet
    )

    begin {
        # Initial Variables
        $SoftwareName = 'KeePass'
        $URI = 'https://keepass.info/'
            
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
            Write-Verbose -Message "Attempting to pull info from the below URL: `n $URI"
            $ReleaseInfo = (Invoke-WebRequest -uri https://sourceforge.net/projects/keepass/best_release.json).content | ConvertFrom-Json
            $ReleaseVersion = ($ReleaseInfo.release.filename).Substring(13,4)
            $ReleaseDate = ($ReleaseInfo.release.date).Substring(0,10)

                      
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

                $KPDownload = "https://sourceforge.net/projects/keepass/files/KeePass%202.x/" + $ReleaseVersion + "/KeePass-" + $ReleaseVersion + "-Setup.exe/download"
                $swObject.Download_URL_x64 = $KPDownload
                               
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
}  # END Function Get-OnlineVerKeePass
