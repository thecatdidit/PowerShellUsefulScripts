<#	
    ===========================================================================
    Created with: 	PowerShell ISE (Win10 19042)
    Revision:		2022.05.24
    Last Modified:	24 May 2022
    Created by:		Jay Harper (github.com/thecatdidit/powershellusefulscripts)
    Organizaiton: 	Happy Days Are Here Again
    Filename: 		Get-OnlineVerNotepadPlusPlus.ps1
    ===========================================================================
    .CHANGELOG
    [2022.05.24]
    Updated query source to Github release feed
    [2021.07.20]
    Fixed a bug with passing of version parameter
    Added Notepad++ GUP source for easier pull of needed data
    [2021.06.10]
    Added '-UseBasicParsing' to web calls re: IE engine decomm
    [2021.04.08]
    Overhauled source scraping and parsing functions to reflect the vendor's new
    site layout

    .SYNOPSIS
        Queries Notepad++ Website for the current version of
        the app and returns the version, date updated, and
        download URLs if available.

    .DESCRIPTION
        This function retrieves the latest data associated with Notepad++.
        Utilizes Invoke-WebRequest to query the app's Download Page and
        pulls out the Version, Update Date and Download URLs for both
        x86 and x64 versions. It then outputs the information as a
        PSObject to the Host.

    .INPUTS
        -Quiet
            Use of this parameter will output just the current version of
            Google Chrome instead of the entire object. It will always be the
            last parameter.

    .OUTPUTS
        An object containing the following:
        Software Name: Name of the software
        Software URL: The URL info was sourced from
        Online Version: The current version found
        Online Date: The date the version was updated
        Download URL x86: Download URL for the win32 version
        Download URL x64: Download URL for the win64 version
    
        If -Quiet is specified then just the value of 'Online Version'
        will be displayed.

    .EXAMPLE
        PS C:\> Get-OnlineVerNotePadPlusPlus
        
        Software_Name    : NotepadPlusPlus
        Software_URL     : https://notepad-plus-plus.org
        Online_Version   : 8.4.1
        Online_Date      : 2022-05-11
        Download_URL_x86 : https://github.com/notepad-plus-plus/notepad-plus-plus/releases/download/v8.4.1/npp.8.4.1.Installer.exe
        Download_URL_x64 : https://github.com/notepad-plus-plus/notepad-plus-plus/releases/download/v8.4.1/npp.8.4.1.Installer.x64.exe

        PS C:\> Get-OnlineVerNotePadPlusPlus -Quiet
        8.4.1

    .NOTES
        Resources/Credits:
        https://github.com/itsontheb
        https://github.com/aaronparker
#>

function Get-OnlineVerNotepadPlusPlus {
    [cmdletbinding()]
    param (
        [Parameter(Mandatory = $false, 
            Position = 0)]
        [switch]
        $Quiet
    )

    begin {
        # Initial Variables
        $SoftwareName = 'NotepadPlusPlus'
        $URI = 'https://notepad-plus-plus.org/'
            
        $hashtable = [ordered]@{
            'Software_Name'    = $softwareName
            'Software_URL'     = 'https://notepad-plus-plus.org'
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
          
          <#Retaining prior query logic for future reference
            $uri = 'https://notepad-plus-plus.org/'
            $nppURL = (Invoke-WebRequest -Uri $uri -UseBasicParsing)
            $nppLink = ($nppURL.Links | Where outerHTML -Match "Current Version")
            $nppVersionLink = "https://notepad-plus-plus.org" + $nppLink.href
            
            $nppDate = (Invoke-WebRequest $nppVersionLink -UseBasicParsing)
            $nppDate.Content -match "<p>Release Date: (?<content>.*)</p>" | Out-Null
            $nppDate = $Matches['content']
           
	    
            $Site = "https://api.github.com/repos/notepad-plus-plus/notepad-plus-plus/releases/latest"
            
            $uri = 'https://notepad-plus-plus.org/update/getDownloadUrl.php'
            [xml]$nppVersion = (Invoke-WebRequest -Uri $uri -UseBasicParsing).content
            [string]$nppversion = $nppVersion.GUP.Version
        #>
        
            $Site = "https://api.github.com/repos/notepad-plus-plus/notepad-plus-plus/releases/latest"
            $AppInfo = (Invoke-WebRequest -Uri $Site -UseBasicParsing).Content | ConvertFrom-Json
            #Obtain App Version
            $AppVersion = $AppInfo.tag_name.Replace("v","")
            #Obtain App Release Date
            $AppDate = $AppInfo.created_at
            $Begin = 0
            $End = $AppDate.IndexOf("T")
            $AppDate = $AppDate.Substring(0,$End)

	    $swObject.Online_Date = $AppDate
            $swObject.Online_version = $AppVersion

        }
        catch {
            Write-Verbose -Message "Error accessing the below URL: `n $URI"
            $message = $("Line {0} : {1}" -f $_.InvocationInfo.ScriptLineNumber, $_.exception.message)
            $swObject | Add-Member -MemberType NoteProperty -Name 'ERROR' -Value $message
        }
        finally {
          
        # Get the Download URLs
            if ($swObject.Online_Version -ne 'UNKNOWN') {
                $nppDownloadx86 = "https://github.com/notepad-plus-plus/notepad-plus-plus/releases/download/v" + $AppVersion + "/" + "npp." + $AppVersion + ".Installer.exe"
                $nppDownloadx64 = "https://github.com/notepad-plus-plus/notepad-plus-plus/releases/download/v" + $AppVersion + "/" + "npp." + $AppVersion + ".Installer.x64.exe"
                                  
                $swObject.Download_URL_x86 = $nppDownloadx86
                $swObject.Download_URL_x64 = $nppDownloadx64
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
}  # END Function Get-OnlineVerNotepadPlusPlus
