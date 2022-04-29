<#
.SYNOPSIS
  Check and apply available BIOS updates (or downgrades)

.DESCRIPTION
  This function uses an internet service to retrieve the list of BIOS updates available for a platform, and optionally checks it against the current system.

  The result is a series of records, with the following definition:

    * Ver - the BIOS update version
    * Date - the BIOS release date
    * Bin - the BIOS update binary file

.PARAMETER Platform
  The Platform ID to check. It can be obtained via Get-HPDeviceProductID. The Platform ID cannot be specified for a flash operation. If not specified, current Platform ID is checked.

.PARAMETER Target
  Execute the command on specified target computer. If not specified, the command is executed on the local computer.

.PARAMETER Format
  The file format (xml, json, csv, list) to output. If not specified, a list of PowerShell objects is returned.

.PARAMETER Latest
  If specified, only return or download the latest available BIOS version between remote and local. If -Platform is specified, local BIOS will not be read and the latest BIOS version available remotely will be returned.

.PARAMETER Check
  If specified, return true if the latest version corresponds to the installed version or installed version is higher, false otherwise. This check is only valid when comparing against current platform.

.PARAMETER All
  Include all known BIOS update information. This may include additional data such as dependencies, rollback support, and criticality.

.PARAMETER Download
  Download the BIOS file to the current directory or a path specified by SaveAs.

.PARAMETER Flash
  Apply the BIOS update to the current system.

.PARAMETER Password
  Specify the BIOS password, if a password is active. This switch is only used when -flash is specified.
  - Use single quotes around the password to prevent PowerShell from interpreting special characters in the string.

.PARAMETER Version
  The BIOS version to download. If not specified, the latest version available will be downloaded.

.PARAMETER SaveAs
  The filename for the downloaded BIOS file. If not specified, the remote file name will be used.

.PARAMETER Quiet
  Do not display a progress bar during BIOS file download.

.PARAMETER Overwrite
  Force overwriting any existing file with the same name during BIOS file download. This switch is only used when -download is specified.

.PARAMETER Yes
  Answer 'yes' to the 'Are you sure you want to flash' prompt.

.PARAMETER Force
  Force the BIOS to update, even if the target BIOS is already installed.

.PARAMETER BitLocker
  Provide an answer to the BitLocker check prompt (if any). The value may be one of:
    stop - stop if BitLocker is detected but not suspended, and prompt.
    stop is default when BitLocker switch is provided.
    ignore - skip the BitLocker check
    suspend - suspend BitLocker if active, and continue

.PARAMETER Url
  Alternate Url source to provide platform's BIOS update catalog (xml)

.NOTES
  - Flash is only supported on Windows 10 1709 (Fall Creators Updated) and later.
  - UEFI boot mode is required for flashing, legacy mode is not supported.
  - The flash operation requires 64-bit PowerShell (not supported under 32-bit PowerShell)

  **WinPE notes**

  - Use '-BitLocker ignore' when using this function in WinPE, as BitLocker checks are not applicable in Windows PE.
  - Requires that the WInPE image is built with the WinPE-SecureBootCmdlets.cab component.

.EXAMPLE
  Get-HPBIOSUpdates
#>
function Get-HPBIOSUpdates {

  [CmdletBinding(DefaultParameterSetName = "ViewSet",
    HelpUri = "https://developers.hp.com/hp-client-management/doc/Get%E2%80%90HPBIOSUpdates")]
  param(
    [Parameter(ParameterSetName = "DownloadSet",Position = 0,Mandatory = $false)]
    [Parameter(ParameterSetName = "ViewSet",Position = 0,Mandatory = $false)]
    [Parameter(Position = 0,Mandatory = $false)]
    [ValidatePattern("^[a-fA-F0-9]{4}$")]
    [string]$Platform,

    [ValidateSet('Xml','Json','CSV','List')]
    [Parameter(ParameterSetName = "ViewSet",Position = 1,Mandatory = $false)]
    [string]$Format,

    [Parameter(ParameterSetName = "ViewSet",Position = 2,Mandatory = $false)]
    [switch]$Latest,

    [Parameter(ParameterSetName = "CheckSet",Position = 3,Mandatory = $false)]
    [switch]$Check,

    [Parameter(ParameterSetName = "FlashSetPassword",Position = 4,Mandatory = $false)]
    [Parameter(ParameterSetName = "DownloadSet",Position = 4,Mandatory = $false)]
    [Parameter(ParameterSetName = "ViewSet",Position = 4,Mandatory = $false)]
    [string]$Target = ".",

    [Parameter(ParameterSetName = "ViewSet",Position = 5,Mandatory = $false)]
    [switch]$All,

    [Parameter(ParameterSetName = "DownloadSet",Position = 6,Mandatory = $true)]
    [switch]$Download,

    [Parameter(ParameterSetName = "FlashSetPassword",Position = 7,Mandatory = $true)]
    [switch]$Flash,

    [Parameter(ParameterSetName = 'FlashSetPassword',Position = 8,Mandatory = $false)]
    [string]$Password,

    [Parameter(ParameterSetName = "FlashSetPassword",Position = 9,Mandatory = $false)]
    [Parameter(ParameterSetName = "DownloadSet",Position = 9,Mandatory = $false)]
    [string]$Version,

    [Parameter(ParameterSetName = "FlashSetPassword",Position = 10,Mandatory = $false)]
    [Parameter(ParameterSetName = "DownloadSet",Position = 10,Mandatory = $false)]
    [string]$SaveAs,

    [Parameter(ParameterSetName = "FlashSetPassword",Position = 11,Mandatory = $false)]
    [Parameter(ParameterSetName = "DownloadSet",Position = 11,Mandatory = $false)]
    [switch]$Quiet,

    [Parameter(ParameterSetName = "FlashSetPassword",Position = 12,Mandatory = $false)]
    [Parameter(ParameterSetName = "DownloadSet",Position = 12,Mandatory = $false)]
    [switch]$Overwrite,

    [Parameter(ParameterSetName = 'FlashSetPassword',Position = 13,Mandatory = $false)]
    [switch]$Yes,

    [Parameter(ParameterSetName = 'FlashSetPassword',Position = 14,Mandatory = $false)]
    [ValidateSet('Stop','Ignore','Suspend')]
    [string]$BitLocker = 'Stop',

    [Parameter(ParameterSetName = 'FlashSetPassword',Position = 15,Mandatory = $false)]
    [switch]$Force,

    [Parameter(ParameterSetName = 'FlashSetPassword',Position = 16,Mandatory = $false)]
    [string]$Url = "https://ftp.hp.com/pub/pcbios"
  )

  if ($PSCmdlet.ParameterSetName -eq "FlashSetPassword") {
    Test-HPFirmwareFlashSupported -CheckPlatform

    if ((Get-HPPrivateIsSureAdminEnabled) -eq $true) {
      throw "Sure Admin is enabled, you must use Update-HPFirmware with a payload instead of a password"
    }
  }

  if (-not $platform) {
    # if platform is not provided, $platform is current platform
    $platform = Get-HPDeviceProductID -Target $target
  }

  $platform = $platform.ToUpper()
  Write-Verbose "Using platform ID $platform"


  $uri = [string]"$Url/{0}/{0}.xml" -f $platform.ToUpper()
  Write-Verbose "Retrieving catalog file $uri"
  $ua = Get-HPPrivateUserAgent
  try {
    [System.Net.ServicePointManager]::SecurityProtocol = Get-HPPrivateAllowedHttpsProtocols
    $data = Invoke-WebRequest -Uri $uri -UserAgent $ua -UseBasicParsing -ErrorAction Stop
  }
  catch [System.Net.WebException]{
    if ($_.Exception.Message.contains("(404) Not Found"))
    {
      throw [System.Management.Automation.ItemNotFoundException]"Unable to retrieve BIOS data for a platform with ID $platform (data file not found)."
    }
    throw $_.Exception
  }

  [xml]$doc = [System.IO.StreamReader]::new($data.RawContentStream).ReadToEnd()
  if ((-not $doc) -or (-not (Get-Member -InputObject $doc -Type Property -Name "BIOS")) -or (-not (Get-Member -InputObject $doc.bios -Type Property -Name "Rel")))
  {
    throw [System.FormatException]"Source data file is unsupported or corrupt"
  }

  #reach to Rel nodes to find Bin entries in xml
  #ignore any entry not ending in *.bin e.g. *.tgz, *.cab
  $unwanted_nodes = $doc.SelectNodes("//BIOS/Rel") | Where-Object { -not ($_.Bin -like "*.bin") }
  $unwanted_nodes | Where-Object {
    $ignore = $_.ParentNode.RemoveChild($_)
  }

  #trim the 0 from the start of the version and then sort on the version value
  $refined_doc = $doc.SelectNodes("//BIOS/Rel") | Select-Object -Property @{ Name = 'Ver'; expr = { $_.Ver.TrimStart("0") } },'Date','Bin','RB','L','DP' `
     | Sort-Object -Property Ver -Descending

  #latest version
  $latestVer = $refined_doc[0]

  if (($PSCmdlet.ParameterSetName -eq "ViewSet") -or ($PSCmdlet.ParameterSetName -eq "CheckSet")) {
    Write-Verbose "Proceeding with parameter set => view"
    if ($check.IsPresent -eq $true) {
      [string]$haveVer = Get-HPBIOSVersion -Target $target
      #check should return true if local BIOS is same or newer than the latest available remote BIOS.
      return ([string]$haveVer.TrimStart("0") -ge [string]$latestVer[0].Ver)
    }

    $args = @{}
    if ($all.IsPresent) {
      $args.Property = (@{ Name = 'Ver'; expr = { $_.Ver.TrimStart("0") } },"Date","Bin",`
           (@{ Name = 'RollbackAllowed'; expr = { [bool][int]$_.RB.trim() } }),`
           (@{ Name = 'Importance'; expr = { [Enum]::ToObject([BiosUpdateCriticality],[int]$_.L.trim()) } }),`
           (@{ Name = 'Dependency'; expr = { [string]$_.DP.trim() } }))
    }
    else {
      $args.Property = (@{ Name = 'Ver'; expr = { $_.Ver.TrimStart("0") } },"Date","Bin")
    }

    # for current platform: latest should return whichever is latest, between local and remote.
    # for any other platform specified: latest should return latest entry from SystemID.XML since we don't know local BIOSVersion
    if ($latest)
    {
      if ($PSBoundParameters.ContainsKey('Platform'))
      {
        # platform specified, do not read information from local system and return latest platform published
        $args.First = 1
      }
      else {
        $retrieved = 0
        # determine the local BIOS version
        [string]$haveVer = Get-HPBIOSVersion -Target $target
        # latest should return whichever is latest, between local and remote for current system.
        if ([string]$haveVer -ge [string]$latestVer[0].Ver)
        {
          # local is the latest. So, retrieve attributes other than BIOSVersion to print for latest
          for ($i = 0; $i -lt $refined_doc.Length; $i++) {
            if ($refined_doc[$i].Ver -eq $haveVer) {
              $haveVerFromDoc = $refined_doc[$i]
              $pso = [pscustomobject]@{
                Ver = $haveVerFromDoc.Ver
                Date = $haveVerFromDoc.Date
                Bin = $haveVerFromDoc.Bin
              }
              if ($all) {
                $pso | Add-Member -MemberType ScriptProperty -Name RollbackAllowed -Value { [bool][int]$haveVerFromDoc.RB.trim() }
                $pso | Add-Member -MemberType ScriptProperty -Name Importance -Value { [Enum]::ToObject([BiosUpdateCriticality],[int]$haveVerFromDoc.L.trim()) }
                $pso | Add-Member -MemberType ScriptProperty -Name Dependency -Value { [string]$haveVerFromDoc.DP.trim }
              }
              $retrieved = 1
              if ($pso) {
                formatBiosVersionsOutputList ($pso)
                return
              }
            }
          }
          if ($retrieved -eq 0) {
            Write-Verbose "retrieving entry from xml failed, get the information from CIM class."
            # calculating date from Win32_BIOS
            $year = (Get-CimInstance Win32_BIOS).ReleaseDate.Year
            $month = (Get-CimInstance Win32_BIOS).ReleaseDate.Month
            $day = (Get-CimInstance Win32_BIOS).ReleaseDate.Day
            $date = $year.ToString() + '-' + $month.ToString() + '-' + $day.ToString()
            Write-Verbose "date calculated from CIM Class is: $date"

            $currentVer = Get-HPBIOSVersion
            $pso = [pscustomobject]@{
              Ver = $currentVer
              Date = $date
              Bin = $null
            }
            if ($all) {
              $pso | Add-Member -MemberType ScriptProperty -Name RollbackAllowed -Value { $null }
              $pso | Add-Member -MemberType ScriptProperty -Name Importance -Value { $null }
              $pso | Add-Member -MemberType ScriptProperty -Name Dependency -Value { $null }
            }
            if ($pso) {
              $retrieved = 1
              formatBiosVersionsOutputList ($pso)
              return
            }
          }
        }
        else {
          # remote is the latest
          $args.First = 1
        }
      }
    }
    formatBiosVersionsOutputList ($refined_doc | Sort-Object -Property ver -Descending | Select-Object @args)
  }
  else {
    $download_params = @{}

    if ($version) {
      $latestVer = $refined_doc `
         | Where-Object { $_.Ver.TrimStart("0") -eq $version } `
         | Select-Object -Property Ver,Bin -First 1
    }

    if (-not $latestVer) { throw [System.ArgumentOutOfRangeException]"Version $version was not found." }

    if (($flash.IsPresent) -and (-not $saveAs)) {
      $saveAs = Get-HPPrivateTemporaryFileName -FileName $latestVer.Bin
      $download_params.NoClobber = "yes"
      Write-Verbose "Temporary file name for download is $saveAs"
    }
    else { $download_params.NoClobber = if ($overwrite.IsPresent) { "yes" } else { "no" } }

    Write-Verbose "Proceeding with parameter set => download, overwrite=$($download_params.NoClobber)"


    $remote_file = $latestVer.Bin
    $local_file = $latestVer.Bin
    $remote_ver = $latestVer.Ver

    if ($PSCmdlet.ParameterSetName -eq "FlashSetPassword" -or
      $PSCmdlet.ParameterSetName -eq "FlashSetSigningKeyFile" -or
      $PSCmdlet.ParameterSetName -eq "FlashSetSigningKeyCert") {
      $running = Get-HPBIOSVersion
      if ((-not $Force.IsPresent) -and ($running.TrimStart("0").trim() -ge $remote_ver.TrimStart("0").trim())) {
        Write-Host "This system is already running BIOS version $($remote_ver.TrimStart(`"0`").Trim()) or newer."
        Write-Host -ForegroundColor Cyan "You can specify -Force on the command line to proceed anyway."
        return
      }
    }

    if ($saveAs) {
      $local_file = $saveAs
    }

    [Environment]::CurrentDirectory = $pwd
    #if (-not [System.IO.Path]::IsPathRooted($to)) { $to = ".\$to" }

    $download_params.url = [string]"$Url/{0}/{1}" -f $platform,$remote_file
    $download_params.Target = [IO.Path]::GetFullPath($local_file)
    $download_params.progress = ($quiet.IsPresent -eq $false)
    Invoke-HPPrivateDownloadFile @download_params -panic

    if ($PSCmdlet.ParameterSetName -eq "FlashSetPassword" -or
      $PSCmdlet.ParameterSetName -eq "FlashSetSigningKeyFile" -or
      $PSCmdlet.ParameterSetName -eq "FlashSetSigningKeyCert") {
      if (-not $yes) {
        Write-Host -ForegroundColor Cyan "Are you sure you want to flash this system with version '$remote_ver'?"
        Write-Host -ForegroundColor Cyan "Current BIOS version is $(Get-HPBIOSVersion)."
        Write-Host -ForegroundColor Cyan "A reboot will be required for the operation to complete."
        $response = Read-Host -Prompt "Type 'Y' to continue and anything else to abort. Or specify -Yes on the command line to skip this prompt"
        if ($response -ne "Y") {
          Write-Verbose "User did not confirm and did not disable confirmation, aborting."
          return
        }
      }

      Write-Verbose "Passing to flash process with file $($download_params.target)"

      $update_params = @{
        file = $download_params.Target
        bitlocker = $bitlocker
        Force = $Force
        Password = $password
      }

      Update-HPFirmware @update_params -Verbose:$VerbosePreference
    }
  }

}
