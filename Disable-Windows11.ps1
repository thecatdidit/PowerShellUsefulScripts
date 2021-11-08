function Show-MessageBox {
  [CmdletBinding(PositionalBinding=$false)]
  param(
    [Parameter(Mandatory, Position=0)]
    [string] $Message,
    [Parameter(Position=1)]
    [string] $Title,
    [Parameter(Position=2)]
    [ValidateSet('OK', 'OKCancel', 'AbortRetryIgnore', 'YesNoCancel', 'YesNo', 'RetryCancel')]
    [string] $Buttons = 'OK',
    [ValidateSet('Information', 'Warning', 'Stop')]
    [string] $Icon = 'Information',
    [ValidateSet(0, 1, 2)]
    [int] $DefaultButtonIndex
  )

  # So that the $IsLinux and $IsMacOS PS Core-only
  # variables can safely be accessed in WinPS.
  Set-StrictMode -Off

  $buttonMap = @{ 
    'OK'               = @{ buttonList = 'OK'; defaultButtonIndex = 0 }
    'OKCancel'         = @{ buttonList = 'OK', 'Cancel'; defaultButtonIndex = 0; cancelButtonIndex = 1 }
    'AbortRetryIgnore' = @{ buttonList = 'Abort', 'Retry', 'Ignore'; defaultButtonIndex = 2; ; cancelButtonIndex = 0 }; 
    'YesNoCancel'      = @{ buttonList = 'Yes', 'No', 'Cancel'; defaultButtonIndex = 2; cancelButtonIndex = 2 };
    'YesNo'            = @{ buttonList = 'Yes', 'No'; defaultButtonIndex = 0; cancelButtonIndex = 1 }
    'RetryCancel'      = @{ buttonList = 'Retry', 'Cancel'; defaultButtonIndex = 0; cancelButtonIndex = 1 }
  }

  $numButtons = $buttonMap[$Buttons].buttonList.Count
  $defaultIndex = [math]::Min($numButtons - 1, ($buttonMap[$Buttons].defaultButtonIndex, $DefaultButtonIndex)[$PSBoundParameters.ContainsKey('DefaultButtonIndex')])
  $cancelIndex = $buttonMap[$Buttons].cancelButtonIndex

  if ($IsLinux) { 
    Throw "Not supported on Linux." 
  }
  elseif ($IsMacOS) {

    $iconClause = if ($Icon -ne 'Information') { 'as ' + $Icon -replace 'Stop', 'critical' }
    $buttonClause = "buttons { $($buttonMap[$Buttons].buttonList -replace '^', '"' -replace '$', '"' -join ',') }"

    $defaultButtonClause = 'default button ' + (1 + $defaultIndex)
    if ($null -ne $cancelIndex -and $cancelIndex -ne $defaultIndex) {
      $cancelButtonClause = 'cancel button ' + (1 + $cancelIndex)
    }

    $appleScript = "display alert `"$Title`" message `"$Message`" $iconClause $buttonClause $defaultButtonClause $cancelButtonClause"            #"

    Write-Verbose "AppleScript command: $appleScript"

    # Show the dialog.
    # Note that if a cancel button is assigned, pressing Esc results in an
    # error message indicating that the user canceled.
    $result = $appleScript | osascript 2>$null

    # Output the name of the button chosen (string):
    # The name of the cancel button, if the dialog was canceled with ESC, or the
    # name of the clicked button, which is reported as "button:<name>"
    if (-not $result) { $buttonMap[$Buttons].buttonList[$buttonMap[$Buttons].cancelButtonIndex] } else { $result -replace '.+:' }
  }
  else { # Windows
    Add-Type -Assembly System.Windows.Forms        
    # Show the dialog.
    # Output the chosen button as a stringified [System.Windows.Forms.DialogResult] enum value,
    # for consistency with the macOS behavior.
    [System.Windows.Forms.MessageBox]::Show($Message, $Title, $Buttons, $Icon, $defaultIndex * 256).ToString()
  }

}

##
#Check for 'C:\NPSS_Setup' directory
#If not found, the directory will be created
##


##
#Identify registry keys involved in the fix
##
$RegKey1 = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate"
$RegKey2 = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU"

##
#Add parent registry keys if not already present
##
if (!(Test-Path -LiteralPath $RegKey1)) { New-Item $Regkey1 -Force -ErrorAction SilentlyContinue }
if (!(Test-Path -LiteralPath $RegKey2)) { New-Item $Regkey2 -Force -ErrorAction SilentlyContinue }

##
#Add registry entries to effect Windows 11 disablement
##
New-ItemProperty -LiteralPath $RegKey1 -Name 'TargetReleaseVersion' -Value 1 -PropertyType DWord -Force -ErrorAction SilentlyContinue
New-ItemProperty -LiteralPath $RegKey1 -Name 'ProductVersion' -Value '' -PropertyType String -Force -ErrorAction SilentlyContinue
New-ItemProperty -LiteralPath $RegKey1 -Name 'TargetReleaseVersionInfo' -Value '21H1' -PropertyType String -Force -ErrorAction SilentlyContinue;

##
#Confirm that the above registry entries have been added
##
$RegCheck1 = (Get-ItemPropertyValue HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate -Name TargetReleaseVersion) -eq 1
$RegCheck2 = (Get-ItemPropertyValue HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate -Name TargetReleaseVersionInfo) -eq '21H1'
$RegCheck3 = (Get-ItemPropertyValue HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate -Name ProductVersion) -eq ''

if ($RegCheck1 -and $RegCheck2 -and $regcheck3) {

Show-MessageBox -Message "*Windows 11 Deployment Prevention Patch is SUCCESSFUL*" -Title "PATCH SUCCESSFUL" -Buttons OK -Icon Information

}

else {

Show-MessageBox -Message "*Windows 11 Deployment Prevention Patch HAS FAILED*. Please run the utility again" -Title "PATCH FAILED" -Buttons OK -Icon Warning

}
