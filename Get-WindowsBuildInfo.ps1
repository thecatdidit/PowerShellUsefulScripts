<#
	===========================================================================
	 Created with: 	VS Code 1.56.1/ISE 19043
	 Revision:      v1
	 Last Modified: 21 June 2021
	 Created by:   	Jay Harper (github.com/thecatdidit/powershellusefulscripts)
	 Organizaiton: 	Happy Days Are Here Again
	 Filename:     	Get-WindowsBuildInfo.ps1
	===========================================================================
	.CHANGELOG
	    [2021.06.21]
	    Script creation

	.SYNOPSIS
        This script returns the current build and date of Windows 10 versions.
        
	.DESCRIPTION
        Data for this script is obtained from ChangeWindows.org. This is a
        'rudimentary' stub that I hope to update with additional features.
        Parameters for release channels, something along those lines.

	.EXAMPLE
           PS> Get-WindowsBuildInfo
           Title                            BuildNumber BuildDate 
           -----                            ----------- --------- 
           21H1/19043 - May 2021 Update     19043.1052  2021-06-08
           20H2/19042 - October 2020 Update 19042.1052  2021-06-08
           2004/19041 - May 2020 Update     19041.1052  2021-06-08
           1909/18363 - October 2019 Update 18363.1645  2021-06-15
           1809/17763 - October 2018 Update 18363.1645  2021-06-15

	.OUTPUTS
            Information on Windows releases including Title, Build Number
            and Build Date

    .NOTES
            Resources/Credits:
            https://github.com/itsontheb
#>

function Get-WindowsBuildInfo {

    $WindowsBuilds=@()
    ##
    #May 2021 Update (21H1/.19043)
    ##
    $21H1Title = "21H1/19043 - May 2021 Update"
    $21H1 = (Invoke-WebRequest -Uri "https://changewindows.org/platforms/pc/releases/windows-10-may-2021-update" -UseBasicParsing).Content.Replace("&quot;","""")
    $21H1 -match "{""name"":""SAC"",""order"":5,""color"":""#46c429"",""disabled"":false,""flight"":{""version"":""(?<build>.*)"",""date"":""(?<date>.*) 00:00:00""}"
    $21H1BuildDate = $Matches['date']
    $21H1BuildNumber = $matches['build']
    
    $Temp = New-Object System.Object
    $Temp | Add-Member -MemberType NoteProperty -Name Title -Value $21H1Title
    $Temp | Add-Member -MemberType NoteProperty -Name BuildNumber -Value $21H1BuildNumber
    $Temp | Add-Member -MemberType NoteProperty -Name BuildDate -Value $21H1BuildDate
    $WindowsBuilds += $Temp
    
    ##
    #October 2020 Update (20H2/.19042)
    ##
    $20H2Title = "20H2/19042 - October 2020 Update"
    $20H2 = (Invoke-WebRequest -Uri "https://changewindows.org/platforms/pc/releases/windows-10-october-2020-update" -UseBasicParsing).Content.Replace("&quot;","""")
    $20H2 -match "{""name"":""SAC"",""order"":5,""color"":""#46c429"",""disabled"":false,""flight"":{""version"":""(?<build>.*)"",""date"":""(?<date>.*) 00:00:00""}"
    $20H2BuildDate = $Matches['date']
    $20H2BuildNumber = $matches['build']
    
    $Temp = New-Object System.Object
    $Temp | Add-Member -MemberType NoteProperty -Name Title -Value $20H2Title
    $Temp | Add-Member -MemberType NoteProperty -Name BuildNumber -Value $20H2BuildNumber
    $Temp | Add-Member -MemberType NoteProperty -Name BuildDate -Value $20H2BuildDate
    $WindowsBuilds += $Temp
    
    ##
    #May 2020 Update (20H1/.19041)
    ##
    $2004Title = "2004/19041 - May 2020 Update"
    $2004 = (Invoke-WebRequest -Uri "https://changewindows.org/platforms/pc/releases/windows-10-may-2020-update" -UseBasicParsing).Content.Replace("&quot;","""")
    $2004 -match "{""name"":""SAC"",""order"":5,""color"":""#46c429"",""disabled"":false,""flight"":{""version"":""(?<build>.*)"",""date"":""(?<date>.*) 00:00:00""}"
    $2004BuildDate = $Matches['date']
    $2004BuildNumber = $Matches['build']
    
    $Temp = New-Object System.Object
    $Temp | Add-Member -MemberType NoteProperty -Name Title -Value $2004Title
    $Temp | Add-Member -MemberType NoteProperty -Name BuildNumber -Value $2004BuildNumber
    $Temp | Add-Member -MemberType NoteProperty -Name BuildDate -Value $2004BuildDate
    $WindowsBuilds += $Temp
    
    ##
    #October 2019 Update (1909/.18363)
    ##
    $1909Title = "1909/18363 - October 2019 Update"
    $1909 = (Invoke-WebRequest -Uri "https://changewindows.org/platforms/pc/releases/windows-10-november-2019-update" -UseBasicParsing).Content.Replace("&quot;","""")
    $1909 -match "{""name"":""SAC"",""order"":5,""color"":""#46c429"",""disabled"":false,""flight"":{""version"":""(?<build>.*)"",""date"":""(?<date>.*) 00:00:00""}"
    $1909BuildDate = $Matches['date']
    $1909BuildNumber = $matches['build']
    
    $Temp = New-Object System.Object
    $Temp | Add-Member -MemberType NoteProperty -Name Title -Value $1909Title
    $Temp | Add-Member -MemberType NoteProperty -Name BuildNumber -Value $1909BuildNumber
    $Temp | Add-Member -MemberType NoteProperty -Name BuildDate -Value $1909BuildDate
    $WindowsBuilds += $Temp
    
    ##
    #October 2018 Update (1809/.17763)
    #
    $1809Title = "1809/17763 - October 2018 Update"
    $1809 = (Invoke-WebRequest -Uri "https://changewindows.org/platforms/pc/releases/windows-10-october-2018-update" -UseBasicParsing).Content.Replace("&quot;","""")
    $1809 -match "{""name"":""SAC"",""order"":5,""color"":""#46c429"",""disabled"":false,""flight"":{""version"":""(?<build>.*)"",""date"":""(?<date>.*) 00:00:00""}" | Out-Null
    $1809BuildDate = $Matches['date']
    $1809BuildNumber = $matches['build']
    
    $Temp = New-Object System.Object
    $Temp | Add-Member -MemberType NoteProperty -Name Title -Value $1809Title
    $Temp | Add-Member -MemberType NoteProperty -Name BuildNumber -Value $1809BuildNumber
    $Temp | Add-Member -MemberType NoteProperty -Name BuildDate -Value $1809BuildDate
    $WindowsBuilds += $Temp
    
    $WindowsBuilds
    } #END function Get-WindowsBuildInfo
