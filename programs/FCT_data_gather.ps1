#Remove-Module *
#Remove-Variable * -ErrorAction SilentlyContinue
function get_fct_data{
$master_path = "C:\EA\EA_Visualization"
$module_path = Join-Path -Path $master_path -ChildPath "Programs\ea_vis_mod_.psm1"
$fct_path = Join-Path -Path $master_path -ChildPath "paths\FCT_PATH.txt"

Import-Module $module_path

$all_fct = Import-Csv $fct_path
$fct_header = "ID","Barcode","MODEL","Hour","JUDGEMENT","Remarks"
$today_log = -join((getToday),".txt")
$combined_fct_log = Join-Path -Path $master_path -ChildPath "logs\fct\$today_log"


foreach($fct in $all_fct){
    $log_path = Join-Path -Path $fct.machine -ChildPath "\Datalogger\logs\$today_log"
    if(Test-Path $log_path ){
    $fct_data = Import-Csv $log_path -Header $fct_header
    $fct_data|Add-Member -MemberType NoteProperty -Name "fct_machine" -Value $fct.fct_machine
    $fct_data|Add-Member -MemberType NoteProperty -Name "fct_type" -Value $fct.fct_type
    $fct_data|Add-Member -MemberType NoteProperty -Name "line" -Value $fct.line
    $all_fct_data += $fct_data
  }
}
$all_fct_data|Export-Csv $combined_fct_log -NoTypeInformation
$all_fct_data
}