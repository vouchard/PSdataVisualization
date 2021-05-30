#region update Tab1
#retrieve ICT Data
$g = (Get-Date).ToString()
Write-Host "$g :  updating.... "
#$frm_main.Title = "$g :  updating.... "
$lb_shift_info.content = getToday


$all_ict_data = get_ict_data
$ict_data = $all_ict_data|Where-Object{$_.judgement -eq "OK"}
$ict_data|Add-Member -MemberType ScriptProperty -Name hour -Value {(Get-Date($this.DateTime)).Hour}


##ICT_hourly_per_machine
$gr_ict_data_per_machine = $ict_data|Group-Object -Property hour,ict
$gr_ict_data_per_machine|Add-Member -MemberType ScriptProperty -Name hour -Value{$this.group[0].hour}
$gr_ict_data_per_machine|Add-Member -MemberType ScriptProperty -Name ICT -Value{$this.group[0].ICT}
$unique_grp = $gr_ict_data_per_machine|Select-Object -Property ICT -Unique
$unique_hr = $gr_ict_data_per_machine|Select-Object -Property hour -Unique

#create New DataSet for Graph
$db = @()
foreach($aa in $unique_hr){
    foreach($bb in $unique_grp){
        $customO = [psCustomObject]@{
            hour = $aa.hour
            ICT = $bb.ICT
            output = [int](($gr_ict_data_per_machine|Where-Object{($_.ICT -eq $bb.ICT) -and ($_.hour -eq $aa.hour)}).Count)
        }
$db += $customO     
    }

}

$ch_ICT_hourly_per_machine.Series.Clear()
$ch_ICT_hourly_per_machine.Legends.Clear()
foreach($aa in $unique_grp){
    $the_series = new_chartSeries -chart $ch_ICT_hourly_per_machine -seriesName $aa.ICT -chart_type StackedColumn
    $source_data = $db|Where-Object{$_.ICT -eq $aa.ICT}
    update_chartSeries -sourceData $source_data -xheader "hour" -yheader "Output" -chartSeries $the_series

}

new_legend -chart $ch_ICT_hourly_per_machine -docking "bottom" -font "asd"
#------------------------------

##ICT_hourly_per_model
$gr_ict_data_per_model = $ict_data|Group-Object -Property hour,Model
$gr_ict_data_per_model|Add-Member -MemberType ScriptProperty -Name hour -Value{$this.group[0].hour}
$gr_ict_data_per_model|Add-Member -MemberType ScriptProperty -Name Model -Value{$this.group[0].model}
$unique_grp_mdl = $gr_ict_data_per_model|Select-Object -Property Model -Unique
$unique_hr = $gr_ict_data_per_machine|Select-Object -Property hour -Unique

#create New DataSet for Graph
$db = @()
foreach($aa in $unique_hr){
    foreach($bb in $unique_grp_mdl){
        $customO = [psCustomObject]@{
            hour = $aa.hour
            model = $bb.model
            output = [int](($gr_ict_data_per_model|Where-Object{($_.model -eq $bb.model) -and ($_.hour -eq $aa.hour)}).Count)
        }
$db += $customO     
    }

}



$ch_ICT_hourly_per_model.Series.Clear()
foreach($aa in $unique_grp_mdl){
    $the_series = new_chartSeries -chart $ch_ICT_hourly_per_model -seriesName $aa.model -chart_type StackedColumn
    $source_data = $db|Where-Object{$_.model -eq $aa.model}
    update_chartSeries -sourceData $source_data -xheader "hour" -yheader "output" -chartSeries $the_series

}

$ch_ICT_hourly_per_model.Legends.Clear()
new_legend -chart $ch_ICT_hourly_per_model -docking "bottom" -font "asd"

#-------------------------------------------------------------------------------------------------------------------------




#retrieve FCT Data
$all_fct_data = get_fct_data
$fct_data = $all_fct_data|Where-Object{($_.judgement -eq "OK") -and ($_.ID -ne "") -and ($_.ID -ne $null)}


##FCT_hourly_per_machine
$gr_fct_data_per_machine = $fct_data|Group-Object -Property hour,fct_type
$gr_fct_data_per_machine|Add-Member -MemberType ScriptProperty -Name hour -Value{$this.group[0].hour}
$gr_fct_data_per_machine|Add-Member -MemberType ScriptProperty -Name fct_type -Value{$this.group[0].fct_type}
$unique_grp = $gr_fct_data_per_machine|Select-Object -Property fct_type -Unique
$unique_hr = $gr_fct_data_per_machine|Select-Object -Property hour -Unique

#create New DataSet for Graph
$db = @()
foreach($aa in $unique_hr){
    foreach($bb in $unique_grp){
        $customO = [psCustomObject]@{
            hour = $aa.hour
            fct = $bb.fct_type
            output = [int](($gr_fct_data_per_machine|Where-Object{($_.fct_type -eq $bb.fct_type) -and ($_.hour -eq $aa.hour)}).Count)
        }
$db += $customO     
    }

}
$db = $db|Where-Object{$_.hour -ne ""}
$ch_FCT_hourly_per_machine.Series.Clear()
foreach($aa in $unique_grp){
    $the_series = new_chartSeries -chart $ch_FCT_hourly_per_machine -seriesName $aa.fct_type -chart_type StackedColumn
    $source_data = $db|Where-Object{$_.fct -eq $aa.fct_type}
    update_chartSeries -sourceData $source_data -xheader "hour" -yheader "Output" -chartSeries $the_series

}
$ch_FCT_hourly_per_machine.Legends.Clear()
new_legend -chart $ch_FCT_hourly_per_machine -docking "bottom" -font "asd"
#------------------------------

##FCT_hourly_per_model
$gr_fct_data_per_model = $fct_data|Group-Object -Property hour,Model
$gr_fct_data_per_model|Add-Member -MemberType ScriptProperty -Name hour -Value{$this.group[0].hour}
$gr_fct_data_per_model|Add-Member -MemberType ScriptProperty -Name Model -Value{$this.group[0].model}
$unique_grp_mdl = $gr_fct_data_per_model|Select-Object -Property Model -Unique
$unique_hr = $gr_fct_data_per_machine|Select-Object -Property hour -Unique

#create New DataSet for Graph
$db = @()
foreach($aa in $unique_hr){
    foreach($bb in $unique_grp_mdl){
        $customO = [psCustomObject]@{
            hour = $aa.hour
            model = $bb.model
            output = [int](($gr_fct_data_per_model|Where-Object{($_.model -eq $bb.model) -and ($_.hour -eq $aa.hour)}).Count)
        }
$db += $customO     
    }

}


$db = $db|Where-Object{$_.hour -ne ""}
$ch_FCT_hourly_per_model.Series.Clear()
foreach($aa in $unique_grp_mdl){
    $the_series = new_chartSeries -chart $ch_FCT_hourly_per_model -seriesName $aa.model -chart_type StackedColumn
    $source_data = $db|Where-Object{$_.model -eq $aa.model}
    update_chartSeries -sourceData $source_data -xheader "hour" -yheader "output" -chartSeries $the_series

}

$ch_FCT_hourly_per_model.Legends.Clear()
new_legend -chart $ch_FCT_hourly_per_model -docking "bottom" -font "asd"

#-------------------------------------------------------------------------------------------------------------------------



$d = (Get-Date).ToString()
Write-Host "$d :  Update Complete!!"
#$frm_main.Title = "$d :  Update Complete!!"

#endregion

#region update Tab2
#POPULATING GRID

$ict_opr = $all_ict_data|Group-Object -Property ict
$ict_opr|Add-Member -MemberType ScriptProperty -Name Total_test -Value {($this.group|Measure-Object).Count}
$ict_opr|Add-Member -MemberType ScriptProperty -Name Total_NG -Value {($this.group|where-object{$_.Judgement -eq "NG"}|Measure-Object).Count}
$ict_opr|Add-Member -MemberType ScriptProperty -Name OPR -Value {[math]::Round((1 - $this.total_NG/$this.total_TEST),4)}
$ict_opr|Add-Member -MemberType ScriptProperty -Name OPR_perce -Value {($this.OPR).tostring("P")}
$ict_opr|Add-Member -MemberType ScriptProperty -Name Machine -Value {-join(($this.group[0]).ICT, " ICT")}
$ict_opr|Add-Member -MemberType ScriptProperty -Name Total_ok -Value {$this.total_test - $this.Total_ng}
#$ict_opr|Select-Object -Property total_test,total_ng,OPR,machine,total_ok

$fct_opr = $all_fct_data|Group-Object -Property line
$fct_opr|Add-Member -MemberType ScriptProperty -Name Total_test -Value {($this.group|Measure-Object).Count}
$fct_opr|Add-Member -MemberType ScriptProperty -Name Total_NG -Value {($this.group|where-object{$_.Judgement -eq "NG"}|Measure-Object).Count}
$fct_opr|Add-Member -MemberType ScriptProperty -Name OPR -Value {[math]::Round((1 - $this.total_NG/$this.total_TEST),4)}
$fct_opr|Add-Member -MemberType ScriptProperty -Name OPR_perce -Value {($this.OPR).tostring("P")}
$fct_opr|Add-Member -MemberType ScriptProperty -Name Line -Value {($this.group[0]).line}
$fct_opr|Add-Member -MemberType ScriptProperty -Name Total_ok -Value {$this.total_test - $this.Total_ng}



$fct_opr2 = $all_fct_data|Group-Object -Property fct_machine
$fct_opr2|Add-Member -MemberType ScriptProperty -Name Total_test -Value {($this.group|Where-Object{$_.ID -ne ""}|Measure-Object).Count}
$fct_opr2|Add-Member -MemberType ScriptProperty -Name Total_NG -Value {($this.group|where-object{$_.Judgement -eq "NG"}|Measure-Object).Count}
$fct_opr2|Add-Member -MemberType ScriptProperty -Name OPR -Value {[math]::Round((1 - $this.total_NG/$this.total_TEST),4)}
$fct_opr2|Add-Member -MemberType ScriptProperty -Name OPR_perce -Value {($this.OPR).tostring("P")}
$fct_opr2|Add-Member -MemberType ScriptProperty -Name machine -Value {($this.group[0]).fct_machine}
$fct_opr2|Add-Member -MemberType ScriptProperty -Name Total_ok -Value {$this.total_test - $this.Total_ng}






$ch_opr_per_machine.Series.Clear()
$ch_ICT_opr_per_model.Series.Clear()
$ch_FCT_opr_per_model.Series.Clear()

$s_ict_opr_per_model = new_chartseries -chart $ch_ict_opr_per_model -seriesName "ict_opr_per_model" -chart_type "column"
$s_fct_opr_per_model = new_chartseries -chart $ch_fct_opr_per_model -seriesName "fct_opr_per_model" -chart_type "column"
$s_opr_per_machine = new_chartseries -chart $ch_opr_per_machine -seriesName "opr_per_machine" -chart_type "column"











$all_grid_data = $ict_opr + $fct_opr2
$dg_ICT_opr.ItemsSource = $all_grid_data


$all_grid_data|Add-Member -MemberType ScriptProperty -Name opr100 -Value {$this.opr * 100}

update_chartseries -sourceData $all_grid_data -xheader "Name" -yheader "opr100" -chartSeries $s_opr_per_machine


$lb_l1_ict_opr.Content = ($ict_opr|Where-Object{$_.Name -eq "LINE1"}).OPR_perce
$lb_l2_ict_opr.Content = ($ict_opr|Where-Object{$_.Name -eq "LINE2"}).OPR_perce
$lb_l1_fct_opr.Content = ($fct_opr|Where-Object{$_.Name -eq "LINE1"}).OPR_perce
$lb_l2_fct_opr.Content = ($fct_opr|Where-Object{$_.Name -eq "LINE2"}).OPR_perce

$ict_opr_mdl = $all_ict_data|Group-Object -Property MODEL
$ict_opr_mdl|Add-Member -MemberType ScriptProperty -Name Total_test -Value {($this.group|Measure-Object).Count}
$ict_opr_mdl|Add-Member -MemberType ScriptProperty -Name Total_NG -Value {($this.group|where-object{$_.Judgement -eq "NG"}|Measure-Object).Count}
$ict_opr_mdl|Add-Member -MemberType ScriptProperty -Name OPR -Value {[math]::Round((1 - $this.total_NG/$this.total_TEST),4)}
$ict_opr_mdl|Add-Member -MemberType ScriptProperty -Name OPR_perce -Value {($this.OPR).tostring("P")}
$ict_opr_mdl|Add-Member -MemberType ScriptProperty -Name Model -Value {-join(($this.group[0]).MODEL)}
$ict_opr_mdl|Add-Member -MemberType ScriptProperty -Name Total_ok -Value {$this.total_test - $this.Total_ng}
$ict_opr_mdl|Add-Member -MemberType ScriptProperty -Name OPR100 -Value {$this.opr * 100}



$fct_opr_mdl = $all_fct_data|Group-Object -Property MODEL
$fct_opr_mdl|Add-Member -MemberType ScriptProperty -Name Total_test -Value {($this.group|Measure-Object).Count}
$fct_opr_mdl|Add-Member -MemberType ScriptProperty -Name Total_NG -Value {($this.group|where-object{$_.Judgement -eq "NG"}|Measure-Object).Count}
$fct_opr_mdl|Add-Member -MemberType ScriptProperty -Name OPR -Value {[math]::Round((1 - $this.total_NG/$this.total_TEST),4)}
$fct_opr_mdl|Add-Member -MemberType ScriptProperty -Name OPR_perce -Value {($this.OPR).tostring("P")}
$fct_opr_mdl|Add-Member -MemberType ScriptProperty -Name Model -Value {-join(($this.group[0]).MODEL)}
$fct_opr_mdl|Add-Member -MemberType ScriptProperty -Name Total_ok -Value {$this.total_test - $this.Total_ng}
$fct_opr_mdl|Add-Member -MemberType ScriptProperty -Name OPR100 -Value {$this.opr * 100}




update_chartseries -sourceData $ict_opr_mdl -xheader "model" -yheader "OPR100" -chartSeries $s_ict_opr_per_model
update_chartseries -sourceData $fct_opr_mdl -xheader "model" -yheader "OPR100" -chartSeries $s_fct_opr_per_model

$ch_ICT_opr_per_model.ChartAreas[0].Axisx.Enabled = 1


#endregion

#>