﻿<#	
	.NOTES
	===========================================================================
	 Created with: 	PowerShell ISE (Win10 19342)
	 Revision:		v2
	 Last Modified: 22 May 2021
	 Created by:   	Jay Harper (github.com/thecatdidit/powershellusefulscripts)
	 Organizaiton: 	Happy Days Are Here Again
	 Filename:     	Get-OnlineVerWinSCP.ps1
	===========================================================================
	
    .CHANGELOG
        v2 (22 May 2021)
        Corrected formatting for creation of the download URL. Some of the releases
        with Release Candidate version tracking pull down a version such as "5.12 RC1".
        The formatted download URL uses a '.' in place of the white space.
        
        v1 (30 March 2019)
        Original script creation
    
    .SYNOPSIS
        Queries the WinSCP Website for the current version of
        the app and returns the version, date updated, and
        download URLs if available.
    
    .DESCRIPTION
	    This function retrieves the latest data associated with WinSCP
        Utilizes Invoke-WebRequest to query the WinSCP download page and
        pulls out the Version, Update Date and Download URLs for
        the app (x64 only) It then outputs the information as a
        PSObject to the Host.
    
    .EXAMPLE
        PS C:\> Get-OnlineVerWinSCP
        
        Software_Name    : WinSCP
        Software_URL     : https://winscp.net/eng/news.php
        Online_Version   : 5.18.5.RC
        Online_Date      : 2021-05-20
        Download_URL_x64 : https://winscp.net/download/WinSCP-5.18.5.RC-Setup.exe
        
    .INPUTS
        -Quiet
            Use of this parameter will output just the current version of
            WinSCP instead of the entire object. It will always be the
            last parameter.

        PS C:\> Get-OnlineVerWinSCP -Quiet
        5.18.5.RC

	.OUTPUTS
        An object containing the following:
        Software Name: Name of the software
        Software URL: The URL info was sourced from
        Online Version: The current version found
        Online Date: The date the version was updated
        Download URL x64: Download URL for the win64 version
    
        If -Quiet is specified then just the value of 'Online Version'
        will be displayed.
	
.NOTES
    Resources/Credits:
    https://github.com/itsontheb

#>


function Get-OnlineVerWinSCP
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
        $SoftwareName = 'WinSCP'
        $uri = "https://winscp.net/eng/news.php"
            
        $hashtable = [ordered]@{
            'Software_Name'    = $softwareName
            'Software_URL'     = $uri
            'Online_Version'   = 'UNKNOWN' 
            'Online_Date'      = 'UNKNOWN'
            'Download_URL_x64' = 'UNKNOWN'
        }
    
        $swObject = New-Object -TypeName PSObject -Property $hashtable
}


   Process
    {
        # Get the Version & Release Date
        try
        {
  
        $site = (Invoke-WebRequest -uri $uri -UseBasicParsing).Content

        $site -match "<p class=""items-list-blocks-item-date""><span class=""sr-only"">Published:</span>(?<date>.*)</p>" | Out-Null
        $winscpdate = $matches['date']

        $site -match "<h2 class=""items-list-blocks-item-heading"">WinSCP (?<version>.*) released</h2>" | Out-Null
        $winscpVersion = ($matches['version']).Replace(" ",".")
        $winscpVersion.Replace(" ",".") | Out-Null

        $winscpURL = "https://winscp.net/download/WinSCP-" + $winscpVersion + "-Setup.exe"
        
        $swObject.Online_Version = $winscpVersion
        $swObject.Online_Date = $winscpdate
        $swObject.Download_URL_x64 = $winscpURL
 
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
}  # END Function Get-OnlineVerWinSCP