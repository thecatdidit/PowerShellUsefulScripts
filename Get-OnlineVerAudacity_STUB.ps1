<#
This is just some scratch code I've cobbled to begin this function. The script will be renamed when it is ready.
Thank you!
Jay
19 May 2021
#>

$Site = "https://www.audacityteam.org/download/windows/"
$SiteWiki = "https://wiki.audacityteam.org/wiki/Audacity_Versions"
$SiteContent = Invoke-WebRequest -Uri $Site -UseBasicParsing
$SiteWikiContent = Invoke-WebRequest -Uri $SiteWiki -UseBasicParsing

##
# Retrieve version from Audacity Wiki
##
if ($SiteWikiContent.Content -match "title=""Release Notes (?<Version>.*)"">")
    {
       $AppVersion = $Matches['Version']
    }
else
    {
       $AppVersion = "UNAVAILABLE"
    }

##
# Retrieve version from Audacity Wiki
##
if ($SiteWikiContent.Content -match"</a></span>`n</td>`n<td>(?<ReleaseDate>.*)`n</td>")
    {
        $AppReleaseDate = $Matches['ReleaseDate']
    }
else
    {
        $AppReleaseDate = "UNAVAILABLE"
    }

    {
        $AppVersion = "UNAVAILABLE"
    }
