<#	
	.NOTES
	===========================================================================
	 Created with: 	PowerShell ISE (Win10 17134)
	 Revision:		v1
	 Last Modified: 30 March 2019
	 Created by:   	Jay Harper (github.com/thecatdidit/powershellusefulscripts)
	 Organizaiton: 	Happy Days Are Here Again
	 Filename:     	Get-OnlineVerSyncplicity.ps1
	===========================================================================
	.Synopsis
        Queries the Syncplicity Website for the current version of
        the app and returns the version, date updated, and
        download URLs if available.
    .DESCRIPTION
	    This function retrieves the latest data associated with Syncplicity
        Utilizes Invoke-WebRequest to query the Postman download page and
        pulls out the Version, Update Date and Download URLs for
        the app (x64 only) It then outputs the information as a
        PSObject to the Host.
    .EXAMPLE
        PS C:\> Get-OnlineVerSyncplicity
        
        Software_Name    : Syncplicity
        Software_URL     : https://docs.axway.com/bundle/Syncplicity/page/windows_desktop_client_release_notes.html
        Online_Version   : 6.0.1
        Online_Date      : March 2019
        Download_URL_x64 : https://download.syncplicity.com/windows/Syncplicity_Setup.exe

        
    .INPUTS
        -Quiet
            Use of this parameter will output just the current version of
            Google Chrome instead of the entire object. It will always be the
            last parameter.

        PS C:\> Get-OnlineVerSyncplicity -Quiet
        6.0.1

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


function Get-OnlineVerSyncplicity
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
        $SoftwareName = 'Syncplicity'
        $uri = 'https://docs.axway.com/bundle/Syncplicity/page/windows_desktop_client_release_notes.html'
            
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
  
        $site = (curl -uri $uri -UseBasicParsing | select -ExpandProperty Content) 
        0
        $site -match "<h2 id=""Windowsdesktopclientreleasenotes-(?<content>.*)>(?<date>.*)</h2>"
        $syncplicityDate = $matches['date']
        $site -match "<p>Windows Client (?<version>.*)</p>"
        
        $syncplicityVersion = $matches['version']
        $syncplicityURL = 'https://download.syncplicity.com/windows/Syncplicity_Setup.exe'
        
        $swObject.Online_Version = $syncplicityVersion
        $swObject.Online_Date = $syncplicityDate
        $swObject.Download_URL_x64 = $syncplicityURL
 
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
}  # END Function Get-OnlineVerSyncplicity