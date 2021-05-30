add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName System.windows.forms
add-type -AssemblyName System.drawing
add-type -AssemblyName WindowsformsIntegration
Add-Type -AssemblyName system.windows.forms.datavisualization

Remove-Job * -Force
Remove-Module *
Remove-Variable * -ErrorAction SilentlyContinue

$master_path = "C:\EA\EA_Visualization"
$module_path = Join-Path -Path $master_path -ChildPath "Programs\ea_vis_mod_.psm1"

$ict_script_path = Join-Path -Path $master_path -ChildPath "Programs\ICT_data_gather.ps1"
$fct_script_path = Join-Path -Path $master_path -ChildPath "Programs\FCT_data_gather.ps1"

Import-Module $module_path
Import-Module $fct_script_path
Import-Module $ict_script_path


$vs_code = "C:\Users\CANON\Documents\Visual Studio 2015\Projects\WpfApplication5\WpfApplication5\MainWindow.xaml"
#$frm_main = get-wpfWindow $vs_code
$frm_main = get-wpfWindow "C:\EA\EA_Visualization\programs\MainWindow.xaml"




$ICT_hourly_per_machine = $frm_main.FindName("L1_hourly_per_machine")
$FCT_hourly_per_machine = $frm_main.FindName("L2_hourly_per_machine")
$ICT_hourly_per_model = $frm_main.FindName("L1_hourly_per_model")
$FCT_hourly_per_model = $frm_main.FindName("L2_hourly_per_model")

$lb_l1_ict_opr = $frm_main.FindName("lb_l1_ict_opr")
$lb_l1_fct_opr = $frm_main.FindName("lb_l1_fct_opr")
$lb_l2_ict_opr = $frm_main.FindName("lb_l2_ict_opr")
$lb_l2_fct_opr = $frm_main.FindName("lb_l2_fct_opr")

$tbc = $frm_main.FindName("tabControl")
$cb = $frm_main.findName("cb_auto_view")


$ch_ICT_hourly_per_machine = new_chart -name "ch_ICT_hourly_per_machine"
$ch_FCT_hourly_per_machine = new_chart -name "ch_FCT_hourly_per_machine"
$ch_ICT_hourly_per_model = new_chart -name "ch_ICT_hourly_per_model"
$ch_FCT_hourly_per_model = new_chart -name "ch_FCT_hourly_per_model"


$S_ICT_hourly_per_machine = new_chartseries -chart $ch_ICT_hourly_per_machine -seriesName "ICT_hourly_per_machine" -chart_type "Bar"
$S_FCT_hourly_per_machine = new_chartseries -chart $ch_FCT_hourly_per_machine -seriesName "FCT_hourly_per_machine" -chart_type "Bar"
$S_ICT_hourly_per_model = new_chartseries -chart $ch_ICT_hourly_per_model -seriesName "ICT_hourly_per_model" -chart_type "Bar"
$S_FCT_hourly_per_model = new_chartseries -chart $ch_FCT_hourly_per_model -seriesName "FCT_hourly_per_model" -chart_type "Bar"


$ict_opr_per_model = $frm_main.FindName("ict_opr_per_model")
$fct_opr_per_model = $frm_main.FindName("fct_opr_per_model")
$opr_per_machine = $frm_main.FindName("opr_per_machine")


#$ICT_L1_all_OPR = $frm_main.FindName("ch_ict_opr_L1")
#$ICT_L2_all_OPR = $frm_main.FindName("ch_ict_opr_L2")
#$FCT_L1_all_OPR = $frm_main.FindName("ch_fct_opr_L1")
#$FCT_L2_all_OPR = $frm_main.FindName("ch_fct_opr_L2")

$ch_ICT_L1_all_OPR = new_chart -name "ICT Line1 OPR"
$ch_FCT_L1_all_OPR = new_chart -name "FCT Line1 OPR"
$ch_ICT_L2_all_OPR = new_chart -name "ICT Line2 OPR"
$ch_FCT_L2_all_OPR = new_chart -name "FCT Line2 OPR"

$ch_ict_opr_per_model = new_chart -name "ICT OPR PER MODEL"
$ch_fct_opr_per_model = new_chart -name "FCT OPR PER MODEL"
$ch_opr_per_machine = new_chart -name "opr_per_machine"




$ch_fct_opr_per_model.ChartAreas[0].axisx.MajorGrid.LineWidth = 0
$ch_fct_opr_per_model.ChartAreas[0].axisy.MajorGrid.LineWidth = 0
$ch_ict_opr_per_model.ChartAreas[0].axisx.MajorGrid.LineWidth = 0
$ch_ict_opr_per_model.ChartAreas[0].axisy.MajorGrid.LineWidth = 0
$ch_opr_per_machine.ChartAreas[0].AxisX.MajorGrid.LineWidth = 0
$ch_opr_per_machine.ChartAreas[0].Axisy.MajorGrid.LineWidth = 0

$ch_opr_per_machine.ChartAreas[0].AxisX.LabelStyle.Angle = 40
$ch_fct_opr_per_model.ChartAreas[0].axisx.LabelStyle.Angle = 40
$ch_ict_opr_per_model.ChartAreas[0].axisx.LabelStyle.Angle = 40



$lb_shift_info = $frm_main.FindName("lb_shift_info")
$dg_ICT_opr = $frm_main.FindName("dg_ICT_opr")


 #    $timer.Dispose()

$ICT_hourly_per_machine.Child = $ch_ICT_hourly_per_machine
$FCT_hourly_per_machine.Child = $ch_FCT_hourly_per_machine
$ICT_hourly_per_model.Child = $ch_ICT_hourly_per_model
$FCT_hourly_per_model.Child = $ch_FCT_hourly_per_model


#ICT_L1_all_OPR.child = $ch_ICT_L1_all_OPR
#$ICT_L2_all_OPR.child = $ch_ICT_L2_all_OPR
#$FCT_L1_all_OPR.child = $ch_fCT_L1_all_OPR
#$FCT_L2_all_OPR.child = $ch_fCT_L2_all_OPR

$ict_opr_per_model.Child = $ch_ict_opr_per_model
$fct_opr_per_model.Child = $ch_fct_opr_per_model
$opr_per_machine.child = $ch_opr_per_machine

$timer = New-Object System.Windows.Forms.Timer
$timer.Interval = 15000
$timer.Enabled = $true


$timer.add_tick({
$script:ctr ++
    $frm_main.Title = Get-Date
    . "C:\ea\EA_Visualization\programs\timer_tick.ps1"

    $allow_auto_view = $cb.IsChecked
    $sw_counter = $script:ctr ++ -gt 10


    $sw_decide = $allow_auto_view -and $sw_counter


if($sw_decide){
    $si = $tbc.SelectedIndex
    if($si -eq 1){
        $tbc.SelectedIndex = 0}
        else{
        $tbc.SelectedIndex = 1}
        $script:ctr = 0
    }
})


$frm_main.add_closed({
     $timer.Dispose()
})


$frm_main.ShowDialog()
 
