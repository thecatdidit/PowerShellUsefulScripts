<#  Creator @gwblok - GARYTOWN.COM
    Used to download BIOS Updates from HP, then Extract the bin file.
    This Script was created to build a BIOS Update Package. 
    Future Scripts based on this will be one that gets the Model / Product info from the machine it's running on and pull down the correct BIOS and run the Updater
 
    REQUIREMENTS:  HP Client Management Script Library
    Download / Installer: https://ftp.hp.com/pub/caps-softpaq/cmit/hp-cmsl.html  
    Docs: https://developers.hp.com/hp-client-management/doc/client-management-script-library-0
    This Script was created using version 1.1.1
#>
 
#Reset Vars
$BIOS = ""
$Model = ""
$HPModelsTable = ""
$HPModelName = ""
$CurrentDownloadedVersion = ""
 
$OS = "Win10"
$Category = "bios"
#$HPModels = @("80FC", "82CA")
$DownloadDir = "C:\HPContent\Downloads"
$ExtractedDir = "C:\HPContent\Packages\HP"
    
$HPModelsTable = @(
    @{ ProdCode = '80FC'; Model = "Elite x2 1012 G1" }
    @{ ProdCode = '82CA'; Model = "Elite x2 1012 G2" }
    @{ ProdCode = '80FB'; Model = "EliteBook 1030 G1" }
    @{ ProdCode = '80FA'; Model = "EliteBook 1040 G3" }
    @{ ProdCode = '225A'; Model = "EliteBook 820 G2" }
    @{ ProdCode = '807C'; Model = "EliteBook 820 G3" }
    @{ ProdCode = '2216'; Model = "EliteBook 840 G2" }
    @{ ProdCode = '8079'; Model = "EliteBook 840 G3" }
)
$HPModelName = $HPModelsTable | Where-Object ProdCode -eq $Model | ForEach-Object Model
 
 
foreach ($Model in $HPModelsTable) {
    Write-Output "Checking Product Code $($Model.ProdCode) for BIOS Updates"
    $BIOS = Get-SoftpaqList -platform $Model.ProdCode -os $OS -category $Category
    if (Test-Path "$($DownloadDir)\$($Model.Model)") { $CurrentDownloadedVersion = (Get-ChildItem -Path "$($DownloadDir)\$($Model.Model)").Name }
    $MostRecent = ($Bios | Measure-Object -Property "ReleaseDate" -Maximum).Maximum
    $BIOS = $BIOS | Where-Object "ReleaseDate" -eq "$MostRecent"
    $DownloadPath = "$($DownloadDir)\$($Model.Model)\$($BIOS.Version)"
    $ExtractedPath = "$($ExtractedDir)\$($Model.Model)"
    
    if (-not (Test-Path "$($DownloadPath)")) {
        if ($CurrentDownloadedVersion) { Write-Output "Update Found, Replacing $([decimal]$CurrentDownloadedVersion) with $([decimal]$BIOS.Version)" }
        Else { Write-Output "Update Found, Downloading: $([decimal]$BIOS.Version)" }
        Write-Output "Downloading BIOS Update for: $($Model.Model) aka $($Model.ProdCode)"
        Get-Softpaq -number $BIOS.ID -saveAs "$($DownloadPath)\$($BIOS.id).exe" -Verbose
        Write-Output "Creating Readme file with BIOS Info HERE: $($DownloadPath)\$($Bios.ReleaseDate).txt"
        $BIOS | Out-File -FilePath "$($DownloadPath)\$($Bios.ReleaseDate).txt"
        $BiosFileName = Get-ChildItem -Path "$($DownloadPath)\*.exe" | Select-Object -ExpandProperty "Name"
        
        if (Test-Path $ExtractedPath) {
            Write-Output "Deleting $($ExtractedPath) Contents before extracting new contents"
            Remove-Item -Path $ExtractedPath -Recurse -Force
        }
        Write-Output "Extracting Downloaded BIOS File to: $($ExtractedPath)"
        Start-Process "$($DownloadPath)\$($BiosFileName)" -ArgumentList "-pdf -e -s -f$($ExtractedPath)" -wait
        #Start-Sleep -Seconds 2
        $BIOS | Out-File -FilePath "$($ExtractedPath)\$([decimal]$Bios.Version).txt"
        #Start-Sleep -Seconds 2
        #Write-Output "Deleting support files, leaving only the BIOS.bin file & 64Bit Updater"
        Remove-Item -Path "$($ExtractedPath)\*.rtf" -Verbose
        Remove-Item -Path "$($ExtractedPath)\*.log" -Verbose
        Remove-Item -Path "$($ExtractedPath)\Hpq*.exe" -Verbose
        Remove-Item -Path "$($ExtractedPath)\HPBIOSUPDREC.exe" -Verbose
        
        Start-Sleep -Seconds 3
    }
    Else
    { Write-Output "No New BIOS Available" }
}