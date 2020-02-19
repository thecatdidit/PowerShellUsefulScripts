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