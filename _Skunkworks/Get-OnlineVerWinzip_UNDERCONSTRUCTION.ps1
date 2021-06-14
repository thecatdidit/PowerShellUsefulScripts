$WikiWinzip = (Invoke-WebRequest -Uri "https://en.wikipedia.org/wiki/WinZip#cite_note-1" -UseBasicParsing)
#$Wikiwinzip = $WikiWinzip.Replace("&#91;","[")
#$Wikiwinzip = $WikiWinzip.Replace("&#93;","]")
#$Wikiwinzip = $WikiWinzip.Replace("&#59;",";")
#$Wikiwinzip = $WikiWinzip.Replace("&#32;"," ")

#wikiwinzip -match "Microsoft Windows"">Windows</a></th><td class=""infobox-data"">(?<date>.*)<span class=""noprint"">;"

$wikiwinzip.content -match "Microsoft Windows"">Windows</a></th><td class=""infobox-data"">(?<version>.*) \/ (?<date>.*)<span class=""noprint"">&#59;&#(?<when>.*)</span><span style=""display:none"">&#160"

$version = $Matches['version'].Split(" ")[0]
$date = $Matches['date'].Replace("&#160;", " ")

$site = "https://download.winzip.com/gl/nkln/winzip" + $version.Split(".")[0] + "-downwz.exe"
$sitedetails = "https://www.winzip.com/win/en/downwz.html"
