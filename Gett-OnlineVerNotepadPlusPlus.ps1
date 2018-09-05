<#	
	.NOTES
	===========================================================================
	 Created with: 	PowerShell ISE (Win10 17134)
	 Revision:	v6
	 Last Modified: 05 September 2018
	 Created by:   	Jay Harper (github.com/thecatdidit/powershellusefulscripts)
	 Organizaiton: 	Happy Days Are Here Again
	 Filename:     	Get-OnlineVerNotepadPlusPlus.ps1
	===========================================================================
    .SYNOPSIS
        Queries Notepad++ Website for the current version of
        the app and returns the version, date updated, and
        download URLs if available.
    .DESCRIPTION
	    This function retrieves the latest data associated with Notepad++.
        Utilizes Invoke-WebRequest to query NotepadPlusPlus Download Page and
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
        PS C:\> Get-OnlineVeNotePadPlusPlus
	Software_Name    : NotepadPlusPlus
        Software_URL     : https://notepad-plus-plus.org/download
        Online_Version   : 7.5.8
        Online_Date      : 2018-07-23
        Download_URL_x86 : https://notepad-plus-plus.org/repository/7.x/7.5.8/npp.7.5.8.Installer.x86.exe
        Download_URL_x64 : https://notepad-plus-plus.org/repository/7.x/7.5.8/npp.7.5.8.Installer.x64.exe

        PS C:\> Get-OnlineVeNotePadPlusPlus -Quiet
        7.5.8
    .NOTES
        Resources/Credits:
        https://github.com/itsontheb
#>

function Get-OnlineVerNotepadPlusPlus
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
        $SoftwareName = 'NotepadPlusPlus'
        $URI = 'https://notepad-plus-plus.org/download'
            
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


   Process
    {
        # Get the Version & Release Date
        try
        {
            Write-Verbose -Message "Attempting to pull info from the below URL: `n $URI"
            $uri = 'https://notepad-plus-plus.org/download'
            $nppURL = (curl -Uri $uri| Select-Object -ExpandProperty Content)
            $nppURL -match "<title>Notepad\+\+ v(?<content>.*) - Current Version</title>"  | Out-Null
            $nppVersion = ($matches['content'])
            $nppURL -match "<p>Release Date: (?<content>.*)</p>" | Out-Null
            $nppDate = ($matches['content'])
            
            $swObject.Online_Version = $nppVersion
            $swObject.Online_Date = $nppDate

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
       
            $nppDownloadx86 = "https://notepad-plus-plus.org/repository/"+$nppVersion[0]+".x/"+$nppVersion+"/"+"npp."+$nppVersion+".Installer.x86.exe"
            $nppDownloadx64 = "https://notepad-plus-plus.org/repository/"+$nppVersion[0]+".x/"+$nppVersion+"/"+"npp."+$nppVersion+".Installer.x64.exe"
            
            $swObject.Download_URL_x86 = $nppDownloadx86
            $swObject.Download_URL_x64 = $nppDownloadx64
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
}  # END Function Get-OnlineVerNotepadPlusPlus
