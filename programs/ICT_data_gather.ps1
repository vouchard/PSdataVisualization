function get_ict_data{

$master_path = "C:\EA\EA_Visualization"
$module_path = Join-Path -Path $master_path -ChildPath "Programs\ea_vis_mod_.psm1"
$ict_path = Join-Path -Path $master_path -ChildPath "paths\ICT_PATH.txt"

Import-Module $module_path

$all_ict = Import-Csv $ict_path
$ict_header = "DateTime","ID","MODEL","JUDGEMENT"
$today_log = -join((getToday),".txt")
$combined_ict_log = Join-Path -Path $master_path -ChildPath "logs\ICT\$today_log"


foreach($ict in $all_ict){
    $log_path = Join-Path -Path $ict.PATH -ChildPath "logs\Pershift\$today_log"
    if((test-path -Path $log_path)){
    $ict_data = Import-Csv $log_path -Header $ict_header
    $ict_data|Add-Member -MemberType NoteProperty -Name "ICT" -Value $ict.ICT_NAME
    $all_ict_data +=$ict_data
    }
}
$all_ict_data|Export-Csv $combined_ict_log -NoTypeInformation
$all_ict_data

}