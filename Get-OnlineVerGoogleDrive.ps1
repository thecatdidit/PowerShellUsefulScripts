<#
    ===========================================================================
     Created with:  PowerShell ISE - Win10 22H2/19045
     Revision:      v1
     Last Modified: 09 April 2024
     Created by:    Jay Harper (github.com/thecatdidit/powershellusefulscripts)
     Organizaiton:  Happy Days Are Here Again
     Filename:      Get-OnlineVerGoogleDrive.ps1
    ===========================================================================
    .CHANGELOG
     v1 [04.09.2024]
     Initial script creation
    
    .SYNOPSIS
        Queries the Google Drive webside for the current version of
        Companion and returns the version, date updated, and
        download URLs if available.
    
    .DESCRIPTION
        This function retrieves the latest data associated with Google Drive
        Invoke-WebRequest queries the site to obtain app release date, version and 
        download URLs

        It then outputs the information as a
        PSObject to the Host

    .EXAMPLE
        PS C:\> Get-OnlineVerGoogleDrive.ps1

        Software_Name    : Google Drive
        Software_URL     : https://support.google.com/a/answer/7577057?hl=en
        Online_Version   : 89.0
        Online_Date      : March 25, 2024
        Download_URL_x64 : https://dl.google.com/drive-file-stream/GoogleDriveSetup.exe
            
        PS C:\> Get-OnlineVerGoogleDrive -Quiet
        89.0
 
    .INPUTS
        -Quiet
            Use of this parameter will output just the current version of
            Google Drive instead of the entire object. It will always be the
            last parameter
        
    .OUTPUTS
            An object containing the following:
            Software Name: Name of the software
            Software URL: The URL info was sourced from
            Online Version: The current version found
            Online Date: The date the version was updated
            EXE Installer: Direct download link for the EXE-based installer
            
            If -Quiet is specified then just the value of 'Online Version'
            will be displayed.

    .NOTES
            Resources/Credits:
            https://github.com/itsontheb
#>

function Get-OnlineVerGoogleDrive
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
        $SoftwareName = 'Google Drive'
        $uri = "https://support.google.com/a/answer/7577057?hl=en"
            
        $hashtable = [ordered]@{
            'Software_Name'    = $softwareName
            'Software_URL'     = $uri
            'Online_Version'   = 'UNKNOWN' 
            'Online_Date'      = 'UNKNOWN'
            'Download_URL_x64' = 'https://dl.google.com/drive-file-stream/GoogleDriveSetup.exe'
        }
    
        $swObject = New-Object -TypeName PSObject -Property $hashtable
}


   Process
    {
        # Get the Version & Release Date
        try
        {
        $ReleaseInfo = (Invoke-WebRequest -Uri https://support.google.com/a/answer/7577057?hl=en).content
        $ReleaseInfo -match "<p><em><strong>Windows and macOS:</strong> Version (?<version>.*)</em></p>" | Out-Null
        $GDriveVersion = $matches['version']
        $ReleaseInfo -match "<h2>(?<date>.*) - Bug fixes</h2>" | Out-Null
        $GDriveDate = $matches['date']

       
        $swObject.Online_Version = $GDriveVersion
        $swObject.Online_Date = $GDriveDate
        $swObject.Download_URL_x64 = "https://dl.google.com/drive-file-stream/GoogleDriveSetup.exe"
 
         }
        catch
        {
            Write-Verbose -Message "Error accessing the below URL: `n $URI"
            $message = $("Line {0} : {1}" -f $_.InvocationInfo.ScriptLineNumber, $_.exception.message)
            $swObject | Add-Member -MemberType NoteProperty -Name 'ERROR' -Value $message
        }
        finally
        {
   
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
}  # END Function Get-OnlineVerGoogleDrive
