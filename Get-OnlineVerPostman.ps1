<#	
	.NOTES
	===========================================================================
	 Created with: 	PowerShell ISE (Win10 17134)
	 Revision:		v5
	 Last Modified: 24 August 2018
	 Created by:   	Jay Harper (github.com/thecatdidit/powershellusefulscripts)
	 Organizaiton: 	Happy Days Are Here Again
	 Filename:     	Get-OnlineVerPostman.ps1
	===========================================================================
	.Synopsis
        Queries the Postman Website for the current version of
        the app and returns the version, date updated, and
        download URLs if available.
    .DESCRIPTION
	    This function retrieves the latest data associated with Postman.
        Utilizes Invoke-WebRequest to query the Postman download page and
        pulls out the Version, Update Date and Download URLs for
        the app (x64 only) It then outputs the information as a
        PSObject to the Host.
    .EXAMPLE
        PS C:\> Get-OnlineVerPostman
        
        Software_Name    : Postman
        Software_URL     : https://dl.pstmn.io/changelog?channel=stable&platform=win
        Online_Version   : 6.2.5
        Online_Date      : 2018-08-20
        Download_URL_x64 : https://dl.pstmn.io/download/version/6.2.5/windows64

        PS C:\> Get-OnlineVerPostman -Quiet
        6.2.5

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
.NOTES
    Resources/Credits:
    https://github.com/itsontheb

#>


function Get-OnlineVerPostman
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
        $SoftwareName = 'Postman'
        $URI = 'https://dl.pstmn.io/changelog?channel=stable&platform=win'
            
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
  
        $postmanDetails = (Invoke-WebRequest $uri | ConvertFrom-Json)
        $postmanVersion = $postmanDetails.changelog[0].name
        $postmanDate = $postmandetails.changelog[0].createdAt.Substring(0,10)
        $postmanDownload = $postmanDetails.changelog[0].assets.url
        $swObject.Online_Version = $postmanVersion
        $swObject.Online_Date = $PostmanDate
        $swObject.Download_URL_x64 = $postmanDownload
 
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
}  # END Function Get-OnlineVerGoogleChrome