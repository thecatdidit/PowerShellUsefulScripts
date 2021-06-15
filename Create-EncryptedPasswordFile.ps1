<#	
	.NOTES
	===========================================================================
	 Created with: 	PowerShell ISE (Win10 18363)
	 Revision:      2020.02.19.1800
	 Last Modified: 19 February 2020
	 Created by:   	Jay Harper (github.com/thecatdidit/powershellusefulscripts)
	 Organizaiton: 	Happy Days Are Here Again
	 Filename:     	Create-EncryptedPasswordFile.ps1
	===========================================================================
	.CHANGELOG
	[2020.02.19.1800]
	Original script creation
	
	.SYNOPSIS
	This script enables secure storage of user credentials in a single, 
	PSAutomation COM Object so that this variable can be passed when needing
	credentials for functions on remote systems.
	
	.DESCRIPTION
	The script requests a manually submitted set of user credentials. The password is 
	encrypted as SecureString, then paired with a 256-bit AES encryption key.
	
	.EXAMPLE
        PS C:\> Create-EncryptedPasswordFile.ps1 -FilePath C:\Temp -FileName SomeFile 
    
	.INPUTS
        -FilePath (MANDATORY)
            Configures the location where both the Secure String password file and AES key
            are stored.
        -FileName (MANDATORY)
        Configures the name of the password file and key file

	.OUTPUTS
        PSCredential System.Object
#>
Function Create-EncryptedPasswordFile($FilePath, $FileName) {

    if (Test-Path $FilePath) {
        ##
        #Confirm full proper path with ending backslash
        ##
        if (!($FilePath.EndsWith("\"))) {
            $FilePath = $FilePath.Insert($FilePath.Length, "\")
        }
          
        ##
        #Associate encryption key with password file
        ##
        $Key = New-Object Byte[] 32
        [Security.Cryptography.RNGCryptoServiceProvider]::Create().GetBytes($Key)
        $Key | out-file $FilePath\$FileName.key -Force
    
        
        $YourCreds = Get-Credential
        (Get-Credential -Credential $YourCreds).Password | ConvertFrom-SecureString -key (Get-Content $FilePath\$fileName.key) | set-content "$FilePath\$FileName.txt" -Force
        $CredsSecure = New-Object System.Management.Automation.PSCredential($YourCreds.UserName, $YourCreds.Password)
        Return $CredsSecure
    }
}
