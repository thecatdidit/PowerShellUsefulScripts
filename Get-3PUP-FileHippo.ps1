<#	
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2016 v5.2.129
	 Revision:	v7
	 Last Modified: 27 August 2018
	 Created by:   	Jay Harper (github.com/thecatdidit/powershellusefulscripts)
	 Organizaiton: 	Happy Days Are Here Again
	 Filename:     	Get-3PUP-FileHippo.ps1
	===========================================================================
	.DESCRIPTION
	This script is designed to query for the current versions of third party products
	that are supported on a current assignment.
	The 3PUP versions are checked via FileHippo and emailed at the end of the script.
        You can configure all aspects of the email (SMTP server, recipients, body, etc.)
        The body is designed to be an HTML-based grid for easy access
        Especially useful for those in smaller shops or those that have no third party add-in/catalog in their ConfigMgr/WSUS systems. 
#>

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$tabName = "Third Party Software"
#Create Table object
$table = New-Object system.Data.DataTable "$tabName"

#Define Columns
$col1 = New-Object system.Data.DataColumn Software, ([string])
$col2 = New-Object system.Data.DataColumn Version, ([string])
$col3 = New-Object system.Data.DataColumn DateAdded, ([string])
$col4 = New-Object system.Data.DataColumn Previous, ([string])

#Add the Columns
$table.columns.add($col1)
$table.columns.add($col2)
$table.columns.add($col3)
$table.columns.add($col4)

#Create a row
$row = $table.NewRow()

# Add application entries to the table.
# Application versions are pulled from entries on FileHippo.com
# Subsequent apps can be added as $app10xxx, $app11xxx,
# The final table is sorted alphabetically
# 

<#
    Adobe Flash Player

    Current: http://filehippo.com/download_adobe-flash-player/tech
    History: http://filehippo.com/download_adobe-flash-player/history/
#>

$app1Name = ("Adobe Flash Player AX/NPAPI/PPAPI")
$app1URL = (curl -Uri https://filehippo.com/download_adobe-flash-player/tech -UseBasicParsing | Select-Object Content -ExpandProperty Content)

$app1URL -match "<title>Download Adobe Flash Player (?<content>.*) - FileHippo.com</title>"  | Out-Null
$app1Version = ($matches['content'])

$app1URL -match "Date added:</span> <span class=""field-value"">`r`n    (?<content>.*)</span>" | Out-Null
$app1Date = ($matches['content'])

$app1PreviousURL = (curl -Uri http://filehippo.com/download_adobe-flash-player/history/ -UseBasicParsing | Select-Object Content -ExpandProperty Content)
$app1PreviousURL -match "/"" class=""internal-link large bold history-list-font-fix"">Adobe Flash Player (?<content>.*)</a>" | Out-Null
$app1PreviousVersion = ($matches['content'])

$row.Software = $app1Name
$row.Version = $app1Version
$row.DateAdded = $app1Date
$row.Previous = $app1PreviousVersion
$table.Rows.Add($row)


<#
	Google Chrome

	Current: http://filehippo.com/download_google_chrome/tech
	History: http://filehippo.com/download_google_chrome/history
#>

$row = $table.NewRow()

$app2Name = ("Google Chrome")
$app2URL = (curl -Uri http://filehippo.com/download_google_chrome/tech -UseBasicParsing | Select-Object Content -ExpandProperty Content)

$app2URL -match "<title>Download Google Chrome (?<content>.*) - FileHippo.com</title>" | Out-Null
$app2Version = ($matches['content'])

$app2URL -match "Date added:</span> <span class=""field-value"">`r`n    (?<content>.*)</span>"
$app2Date = ($matches['content'])

$app2PreviousURL = (curl -Uri http://filehippo.com/download_google_chrome/history/ -UseBasicParsing | Select-Object Content -ExpandProperty Content)
$app2PreviousURL -match "/"" class=""internal-link large bold history-list-font-fix"">Google Chrome (?<content>.*?)</a>" | Out-Null
$app2PreviousVersion = ($matches['content'])

$row.Software = $app2Name
$row.Version = $app2Version
$row.DateAdded = $app2Date
$row.Previous= $app2PreviousVersion
$table.Rows.Add($row)

<#
    Mozilla Firefox

    Current: http://filehippo.com/download_firefox_64/
    History: http://filehippo.com/download_firefox_64/history/
#>

$row = $table.NewRow()

$app3Name = ("Mozilla Firefox")
$app3URL = (curl -Uri http://filehippo.com/download_firefox_64/ -UseBasicParsing | Select-Object Content -ExpandProperty Content)

$app3URL -match "<title>Download Firefox (?<content>.*) 64-bit - FileHippo.com</title>" | Out-Null
$app3Version = ($matches['content'])

$app3URL -match "Date added:</span> <span class=""field-value"">`r`n    (?<content>.*)</span>"
$app3Date = ($matches['content'])

$app3PreviousURL = (curl -Uri http://filehippo.com/download_firefox_64/history/ -UseBasicParsing | Select-Object Content -ExpandProperty Content)
$app3PreviousURL -match "/"" class=""internal-link large bold history-list-font-fix"">Firefox (?<content>.*?) 64-bit</a>" | Out-Null
$app3PreviousVersion = ($matches['content'])

$row.Software = $app3Name
$row.Version = $app3Version
$row.DateAdded = $app3Date
$row.Previous = $app3PreviousVersion
$table.Rows.Add($row)

<#
    Adobe Air

    Current: http://filehippo.com/download_adobe_air/ 
    History: http://filehippo.com/download_itunes/history/
#>

$row = $table.NewRow()

$app5Name = ("Adobe Air")
$app5URL = (curl -Uri http://filehippo.com/download_adobe_air/ -UseBasicParsing | Select-Object Content -ExpandProperty Content)

$app5URL -match "<title>Download Adobe Air (?<content>.*) - FileHippo.com</title>" | Out-Null
$app5Version = ($matches['content'])

$app5URL -match "Date added:</span> <span class=""field-value"">`r`n    (?<content>.*)</span>"
$app5Date = ($matches['content'])

$app5PreviousURL = (curl -Uri http://filehippo.com/download_adobe_air/history -UseBasicParsing | Select-Object Content -ExpandProperty Content)
$app5PreviousURL -match "/"" class=""internal-link large bold history-list-font-fix"">Adobe Air (?<content>.*?)</a>" | Out-Null
$app5PreviousVersion = ($matches['content'])

$row.Software = $app5Name
$row.Version = $app5Version
$row.DateAdded = $app5Date
$row.Previous= $app5PreviousVersion
$table.Rows.Add($row)

<#
    Apple iTunes

    Current: http://filehippo.com/download_itunes/64/
    History: http://filehippo.com/download_itunes/64/history
#>

$row = $table.NewRow()

$app6Name = ("Apple iTunes")
$app6URL = (Invoke-WebRequest -Uri http://filehippo.com/download_itunes/64/ -UseBasicParsing | Select-Object Content -ExpandProperty Content)

$app6URL -match "<span style=""font-weight: normal"">(?<content>.*)</span>" | Out-Null
$app6Version = ($matches['content'])

$app6URL -match "Date added:</span> <span class=""field-value"">`r`n    (?<content>.*)</span>"
$app6Date = ($matches['content'])

$app6PreviousURL = (curl -Uri http://filehippo.com/download_itunes/history/ -UseBasicParsing | Select-Object Content -ExpandProperty Content)
$app6PreviousURL -match "s/(?<content>.*)/"" class=""internal-link large bold history-list-font-fix"">iTunes (?<content>.*?)</a>" | Out-Null
$app6PreviousVersion = ($matches['content'])

$row.Software = $app6Name
$row.Version = $app6Version
$row.DateAdded = $app6Date
$row.Previous = $app6PreviousVersion
$table.Rows.Add($row)


<#
    Oracle Java Runtime Engine (JRE)

    Current: http://filehippo.com/download_jre/32/
    History: http://filehippo.com/download_jre/history/
#>


$row = $table.NewRow()

$app7Name = ("Java RE")
$app7URL = (curl -Uri http://filehippo.com/download_jre/32/ -UseBasicParsing | Select-Object Content -ExpandProperty Content)

$app7URL -match "<span style=""font-weight: normal"">(?<content>.*)</span>" | Out-Null
$app7Version = ($matches['content'])

$app7URL -match "Date added:</span> <span class=""field-value"">`r`n    (?<content>.*)</span>"
$app7Date = ($matches['content'])

$app7PreviousURL = (curl -Uri http://filehippo.com/download_jre/history/ -UseBasicParsing | Select-Object Content -ExpandProperty Content)
$app7PreviousURL -match "jre/(?<content>.*)/"" class=""internal-link large bold history-list-font-fix"">Java Runtime Environment (?<content>.*?)</a>" | Out-Null
$app7PreviousVersion = ($matches['content'])

$row.Software = $app7Name
$row.Version = $app7Version
$row.DateAdded = $app7Date
$row.Previous = $app7PreviousVersion
$table.Rows.Add($row)


<#
    Adobe Acrobat Reader DC

    Current: http://filehippo.com/download_adobe-acrobat-reader-dc/
    History: http://filehippo.com/download_adobe-acrobat-reader-dc/history
#>


$row = $table.NewRow()

$app8Name = ("Acrobat Reader DC")
$app8URL = (curl -Uri http://filehippo.com/download_adobe-acrobat-reader-dc/ -UseBasicParsing | Select-Object Content -ExpandProperty Content)

$app8URL -match "<title>Download Adobe Acrobat Reader DC (?<content>.*) - FileHippo.com</title>" | Out-Null
$app8Version = ($matches['content'])

$app8URL -match "Date added:</span> <span class=""field-value"">`r`n    (?<content>.*)</span>"
$app8Date = ($matches['content'])

$app8PreviousURL = (curl -Uri http://filehippo.com/download_adobe-acrobat-reader-dc/history -UseBasicParsing | Select-Object Content -ExpandProperty Content)
$app8PreviousURL -match "dc/(?<content>.*)/"" class=""internal-link large bold history-list-font-fix"">Adobe Acrobat Reader DC (?<content>.*?)</a>" | Out-Null
$app8PreviousVersion = ($matches['content'])

$row.Software = $app8Name
$row.Version = $app8Version
$row.DateAdded = $app8Date
$row.Previous= $app8PreviousVersion
$table.Rows.Add($row)


<#
    Notepad++

    Current: http://filehippo.com/download_notepad/ 
    History: http://filehippo.com/download_notepad/history/
#>

$row = $table.NewRow()

$app9Name = ("Notepad++")
$app9URL = (curl -Uri http://filehippo.com/download_notepad/ -UseBasicParsing | Select-Object Content -ExpandProperty Content)

$app9URL -match "<title>Download Notepad\+\+ (?<content>.*) - FileHippo.com" | Out-Null
$app9Version = ($matches['content'])

$app9URL -match "Date added:</span> <span class=""field-value"">`r`n    (?<content>.*)</span>"
$app9Date = ($matches['content'])
 
$app9PreviousURL = (curl -Uri http://filehippo.com/download_notepad/history/ -UseBasicParsing | Select-Object Content -ExpandProperty Content)
$app9PreviousURL -match "d/(?<content>.*)/"" class=""internal-link large bold history-list-font-fix"">Notepad\+\+ (?<content>.*?)</a>" | Out-Null
$app9PreviousVersion = ($matches['content'])

$row.Software = $app9Name
$row.Version = $app9Version
$row.DateAdded = $app9Date
$row.Previous = $app9PreviousVersion
$table.Rows.Add($row)


# Create an HTML version of the DataTable
#$table = $table | Sort-Object Software

$html = "<table><tr><td><b><u>Software</u></b></td><td><b><u>Version</u></b></td><td><b><u>Previous</u></b></td></tr>"
foreach ($row in $table.Rows)
{
	$html += "<tr><td>" + $row[0] + "</td><td>" + $row[1] + "</td></tr>" + $row[2] + "</td></tr>" + $row[3]
}
$html += "</table>"

#Generating a style template for the body of the email
$Style = "
<style>
    TABLE{border-width: 1px;border-style: solid;border-color: black;border-collapse: collapse;}
    TH{border-width: 1px;padding: 3px;border-style: solid;border-color: black;}
    TD{border-width: 1px;padding: 3px;border-style: solid;border-color: black;}
</style>
"

$table = ($table | Sort-Object Software | ConvertTo-Html -Title "Third Party Apps" -Property Software, Version, Previous, DateAdded -Head $Style) | Out-String

# Send the email
$smtpserver = "yourmailserver.com"
$from = "sender@contoso.com"
$to = "mainrecipient@contoso.com"
$cc = "someotherfolks@contoso.com"
$date = Get-Date -UFormat "%A %d %B %Y - %r"
$subject = "Third Party Apps Report - $date"
$body =  "<br /> GENERATED AS OF <b>$date</b><br /><br />" + $body
Send-MailMessage -smtpserver $smtpserver -from $from -to $to -subject $subject -Cc $cc -body $table -bodyashtml
