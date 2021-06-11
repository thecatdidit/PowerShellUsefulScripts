function Get-WUStatusToGridView {
$UpdateDetails = @()
$wu = (new-object -com "Microsoft.Update.Searcher").QueryHistory(2,$wu.gettotalhistorycount()) | where Title -Match "KB" | select Date, Title, Description | Out-GridView
$total = $wu.GetTotalHistoryCount()

$totalupdates = $wu.GetTotalHistoryCount()
$all = $wu.QueryHistory(0,$totalupdates) | Where Title -Match "KB"

foreach ($update in $all) {

    $Fullstat = New-Object System.Object
    $start = $update.title.IndexOf("KB") 
    $end = $update.title.IndexOf(")")
    $kb = $update.title.substring($start,$end-$start)
    $title = $update.title
    $date = $update.date
    $description = $update.description

    $Fullstat | Add-Member -Type NoteProperty -Name Title -Value $title
    $Fullstat | Add-Member -Type NoteProperty -Name Date -Value $date
    $Fullstat | Add-Member -Type NoteProperty -Name KB -Value $kb
    $Fullstat | Add-Member -Type NoteProperty -Name Description -Value $description

    $UpdateDetails += $Fullstat
}
    $UpdateDetails | Out-GridView
}
#END functation Get-WUStatusToGridView
