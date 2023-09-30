<#
    ===========================================================================
     Created with:  PowerShell ISE - Win10 21H1/19043
     Revision:      v1
     Last Modified: 31 Mar 2022
     Created by:    Jay Harper (github.com/thecatdidit/powershellusefulscripts)
     Organizaiton:  Happy Days Are Here Again
     Filename:      Get-OnlineVerAtlassianCompanion.ps1
    ===========================================================================
    .CHANGELOG
     [03.31.22] Initial script creation
    
    .SYNOPSIS
        Queries the Atlassian webside for the current version of
        Companion and returns the version, date updated, and
        download URLs if available.
    
    .DESCRIPTION
        This function retrieves the latest data associated with Atlassian Companion
        Invoke-WebRequest queries the site to obtain app release date, version and 
        download URLs. This includes both the standard EXE installer and the MSI
        instance

        It then outputs the information as a
        PSObject to the Host

        App Site: https://confluence.atlassian.com/doc/atlassian-companion-app-release-notes-958455712.html

    .EXAMPLE
        PS C:\> Get-OnlineVerAtlassianCompanion.ps1

        Software_Name    : Atlassian Companion
        Software_URL     : https://confluence.atlassian.com
        Online_Version   : 1.3.1
        Online_Date      : 12 November 2021
        EXE_Installer    : https://update-nucleus.atlassian.com/Atlassian-Companion/291cb34fe2296e5fb82b83a04704c9b4/latest/win32/ia32/Atlassian%20Companion.exe
        MSI_Installer    : https://update-nucleus.atlassian.com/Atlassian-Companion/291cb34fe2296e5fb82b83a04704c9b4/latest/win32/ia32/Atlassian%20Companion.msi
    
        PS C:\> Get-OnlineVerAtlassianCompanion -Quiet
        1.3.1
 
    .INPUTS
        -Quiet
            Use of this parameter will output just the current version of
            Atlassian Companion instead of the entire object. It will always be the
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

function Get-OnlineVerAtlassianCompanion {
    [cmdletbinding()]
    param (
        [Parameter(Mandatory = $false, 
            Position = 0)]
        [switch]
        $Quiet
    )

    begin {
        # Initial Variables
        $SoftwareName = 'Atlassian Companion'
        $URI = 'https://confluence.atlassian.com'
            
        $hashtable = [ordered]@{
            'Software_Name'    = $softwareName
            'Software_URL'     = $uri
            'Online_Version'   = 'UNKNOWN' 
            'Online_Date'      = 'UNKNOWN'
            'EXE_Installer' = 'https://update-nucleus.atlassian.com/Atlassian-Companion/291cb34fe2296e5fb82b83a04704c9b4/latest/win32/ia32/Atlassian%20Companion.exe'
            'MSI_Installer' = 'https://update-nucleus.atlassian.com/Atlassian-Companion/291cb34fe2296e5fb82b83a04704c9b4/latest/win32/ia32/Atlassian%20Companion.msi'
        }
    
        $swObject = New-Object -TypeName PSObject -Property $hashtable
    }


    Process {
        # Get the Version & Release Date
        try {
            Write-Verbose -Message "Attempting to pull info from the below URL: `n $URI"
            $URI = 'https://confluence.atlassian.com/doc/atlassian-companion-app-release-notes-958455712.html'
            $ACURL = (Invoke-WebRequest -Uri $URI -UseBasicParsing | Select-Object -ExpandProperty Content)
            $query = "Latest versions</h2><h3 id=""AtlassianCompanionappreleasenotes-AtlassianCompanion1.3.1"">Atlassian Companion (?<version>.*)</h3><p>Released (?<date>.*)</p><p>"
            $ACURL -match $query
             
            $ACVersion = ($matches['version'])
            $ACDate = ($matches['date'])
            
            $swObject.Online_Version = $ACVersion
            $swObject.Online_Date = $ACDate

        }
        catch {
            Write-Verbose -Message "Error accessing the below URL: `n $URI"
            $message = $("Line {0} : {1}" -f $_.InvocationInfo.ScriptLineNumber, $_.exception.message)
            $swObject | Add-Member -MemberType NoteProperty -Name 'ERROR' -Value $message
        }
        finally {
          

            # Get the Download URLs
            if ($swObject.Online_Version -ne 'UNKNOWN') {
       
                $MMDownloadEXE = "https://update-nucleus.atlassian.com/Atlassian-Companion/291cb34fe2296e5fb82b83a04704c9b4/latest/win32/ia32/Atlassian%20Companion.exe"
                $MMDownloadMSI = "https://update-nucleus.atlassian.com/Atlassian-Companion/291cb34fe2296e5fb82b83a04704c9b4/latest/win32/ia32/Atlassian%20Companion.msi"
                
                   
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
}  # END Function Get-OnlineVerAtlassianCompanion
