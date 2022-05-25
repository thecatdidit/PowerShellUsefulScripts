<#
     ===========================================================================
      Created with: 	PowerShell ISE 19043
      Last Modified: 	24 May 2022
      Created by:   	Jay Harper (github.com/thecatdidit/powershellusefulscripts)
      Organizaiton: 	Happy Days Are Here Again
      Filename:     	Get-OnlineVer7Zip.ps1
     ===========================================================================
    .CHANGELOG
    [2022.05.25]
    Software querying changed from standard page scrape to JSON feed on SourceForge
    https://sourceforge.net/projects/sevenzip/best_release.json
    [2021.05.08]
    Added '-UseBasicParsing' to web content calls
    [2019.03.27]
    Script creation

    .SYNOPSIS
        Queries the 7Zip webside for the current version of
        the app and returns the version, date updated, and
        download URLs if available.

    .DESCRIPTION
    This function retrieves the latest data associated with 7Zip
        Invoke-WebRequest queries the site to obtain app release date, version and 
        download URLs. This includes x86 and x64.
        It then outputs the information as a
        PSObject to the Host

        App Site: https://www.7-zip.org/

    .EXAMPLE
        PS C:\> Get-OnlineVer7Zip

        Software_Name    : 7Zip
        Software_URL     : https://www.7-zip.org/download.html
        Online_Version   : 21.07
        Online_Date      : 2021-12-28
        Download_URL_x86 : https://www.7-zip.org/a/7z2107.msi
        Download_URL_x64 : https://www.7-zip.org/a/7z2107-x64.msi
    
       	PS C:\> Get-OnlineVer7Zip -Quiet
       	19.00
 
    .INPUTS
        -Quiet
            Use of this parameter will output just the current version of
            Flash Player instead of the entire object. It will always be the
            last parameter
        
    .OUTPUTS
            An object containing the following:
            Software Name: Name of the software
            Software URL: The URL info was sourced from
            Online Version: The current version found
            Online Date: The date the version was updated
            Download URL x64: Direct download link for the x64 version
            Download URL x86: Direct download link for the x86 version
    
            If -Quiet is specified then just the value of 'Online Version'
            will be displayed.

    .NOTES
            Resources/Credits:
            https://github.com/itsontheb
            https://github.com/aaronparker
#>

function Get-OnlineVer7Zip {
    [cmdletbinding()]
    param (
        [Parameter(Mandatory = $false, 
            Position = 0)]
        [switch]
        $Quiet
    )

    begin {
        # Initial Variables
        $SoftwareName = '7Zip'
        $URI = 'https://www.7-zip.org/download.html'
            
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


    Process {
        # Get the Version & Release Date
        try {
            Write-Verbose -Message "Attempting to pull info from the below URL: `n $URI"
            $Site = 'https://sourceforge.net/projects/sevenzip/best_release.json'
            $7ZipInfo = (Invoke-WebRequest -Uri $Site -UseBasicParsing).Content | ConvertFrom-Json
            
            #Parsing out version info
            $7ZipFileName = $7ZipInfo.release.filename
            $Begin = $7ZipFileName.IndexOf("`/7-Zip/") + 7
            $End = $7ZipFileName.IndexOf("/7z")
            $7ZipVersion = ($7ZipFileName).Substring($begin,$end-$begin)

            $7ZipDate = $7ZipInfo.release.date.Substring(0,10)
            
           <# Keeping the prior scraping logic commmented for posterity's sake
            $7ZipURL = (Invoke-WebRequest -Uri $uri -UseBasicParsing | Select-Object -ExpandProperty Content)
            $7ZIPURL -match "<P><B>Download 7-Zip (?<version>.*) \((?<date>.*)\) f" | Out-Null
            $7ZipVersion = ($matches['version'])
            $7ZipDate = ($matches['date'])
           #>

            $swObject.Online_Version = $7ZipVersion
            $swObject.Online_Date = $7ZipDate

        }
        catch {
            Write-Verbose -Message "Error accessing the below URL: `n $URI"
            $message = $("Line {0} : {1}" -f $_.InvocationInfo.ScriptLineNumber, $_.exception.message)
            $swObject | Add-Member -MemberType NoteProperty -Name 'ERROR' -Value $message
        }
        finally {

            # Get the Download URLs
            if ($swObject.Online_Version -ne 'UNKNOWN') {
       
                $7ZipDownloadx64 = "https://www.7-zip.org/a/7z" + $7ZipVersion.replace(".", "") + "-x64.msi"
                $7ZipDownloadx86 = "https://www.7-zip.org/a/7z" + $7ZipVersion.replace(".", "") + ".msi"
            
                $swObject.Download_URL_x86 = $7ZipDownloadx86
                $swObject.Download_URL_x64 = $7ZipDownloadx64
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
}  # END Function Get-OnlineVer7Zip
