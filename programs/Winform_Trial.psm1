Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName System.windows.forms
add-type -AssemblyName System.drawing
add-type -AssemblyName WindowsformsIntegration
Add-Type -AssemblyName system.windows.forms.datavisualization

$path = "C:\MI_Monitoring\MI_Data\201021_ds.txt" 
$hourlycapmi = Import-Csv "C:\MI_Monitoring\MI_csvfiles\MI_Hourly_Capacity.txt"
#$currentmodel = Get-Content "C:\MI_Monitoring\MI_csvfiles\MI_Model.txt"
$now = Get-Date

function get-wpfWindow{
param($xamlPath)#xaml from get-content,
$xamlContent = get-content $xamlPath
[xml]$xaml = @"
$xamlContent
"@

$reader = (New-Object System.Xml.XmlNodeReader $xaml)
$window = [Windows.Markup.XamlReader]::load($reader)

$window
}

function new_chart{
param($name)
    $chart = New-Object system.windows.forms.datavisualization.charting.chart
    $chart_area = New-Object system.windows.forms.datavisualization.charting.chartArea
    $chart.chartAreas.add($chart_area)
    $chart.ChartAreas[0].AxisX.Interval = 1
    $chart.Name = $name
    $chart

}

function new_chartSeries{
param($chart,$seriesName,$chart_type)
    $chart_series = New-Object system.windows.forms.datavisualization.charting.series
    $types =  [system.windows.forms.datavisualization.charting.serieschartType]
    $chart_series.charttype = $types::$chart_type
    $chart_series.name = $seriesName

    $chart.series.add($chart_series)
    #$chart_series[$seriesName].LegendText ="#VALX (#VALY)"
    $chart.Series[$seriesName]
}

function update_chartSeries{
param($sourceData,$xheader,$yheader,$chartSeries)
    $x = [System.Collections.ArrayList]::new()
    $y = [System.Collections.ArrayList]::new()

    foreach($aa in $sourceData){
        $x += [string]$aa.($xheader)
        $y += [int]$aa.($yheader)

    }
    $chartSeries.points.DataBindXY($x,$y)

    foreach($aa in $chartSeries.points){
        if($aa.Yvalues -gt 0){
            $aa.label = $aa.Yvalues
        }
    }

}

function new_legend{
param($chart,$docking,$font)
    $legend = New-Object System.Windows.Forms.DataVisualization.Charting.Legend
    $chart.Legends.Add($legend)
    $legend.Docking = $docking
    $legend.BorderColor = "black"
    $legend.Font = $font
    $legend.Alignment = "Center"
}



################Charts Data Gathering################
function now{
    Get-Date -uFormat "%y-%m-%d %I:%M %p "
}

function startDate{
    param($date)
    $time = Get-Date($date)
    $timemin = 60 - $time.Minute
    $time = $time.AddMinutes($timemin)
    $time = $time.AddSeconds(-($time.Second))
    $time = $time.AddHours(-1)
    $time = Get-Date($time) -UFormat "%I %p"
    $time
    #$time.ToShortTimeString()
}
function endDate{
    param($date)
    $time = Get-Date($date)
    $timemin = 60 - $time.Minute
    $time = $time.AddMinutes($timemin)
    $time = $time.AddSeconds(-($time.Second))
    $time = Get-Date($time) -UFormat "%I %p"
    $time
    #$time.ToShortTimeString()
}

function get_shift_data{
    $now = Get-Date

    if($now -ge (Get-Date("8:00:00 AM")) -and $now -lt (Get-Date("3:24:59 PM"))){
        $shiftname = Get-Date -UFormat "%y%m%d_ds"
        $test = Test-Path "C:\MI_Monitoring\MI_Data\$shiftname.txt"
        if($test -eq $true){
            $machcsv = Import-Csv "C:\MI_Monitoring\MI_Data\$shiftname.txt"
            $machcsv
        }else{
            $shiftname = (Get-Date).AddDays(-1)
            $shiftname = Get-Date($shiftname) -UFormat "%y%m%d_ns"
            $machcsv = Import-Csv "C:\MI_Monitoring\MI_Data\$shiftname.txt"
            $machcsv
        }
            
    }elseif($now -ge (Get-Date("3:25:00 PM")) -and $now -lt (Get-Date("11:59:59 PM"))){
        $shiftname = Get-Date -UFormat "%y%m%d_ns"
        $test = Test-Path "C:\MI_Monitoring\MI_Data\$shiftname.txt"
        if($test -eq $true){
            $machcsv = Import-Csv "C:\MI_Monitoring\MI_Data\$shiftname.txt"
            $machcsv
        }else{
            $shiftname = Get-Date -UFormat "%y%m%d_ds"
            $machcsv = Import-Csv "C:\MI_Monitoring\MI_Data\$shiftname.txt"
            $machcsv
        }

        
    }else{
        $shiftname = (Get-Date).AddDays(-1)
        $shiftname = Get-Date($shiftname) -UFormat "%y%m%d_ns"
        $machcsv = Import-Csv "C:\MI_Monitoring\MI_Data\$shiftname.txt"
        $machcsv
    }
    
}

 
function count_model{
    param($src,$pcbmodel,$stime,$name)
    $filtr = $src|Where-Object{$_.Model -eq $pcbmodel -and $_.TimeSpan -eq $name}
    #-and $_.Stime -eq $stime
    $filtr = $filtr.Count
    $filtr
}

function total_output{
param($src)
    #$counter = $src|Select-Object count
    foreach($total in $src){
        [int]$total2 = [int]$total2 + [int]$total.Count
    
    }
    [int]$total2
}

function total_delay{
param($src,$pcbmodel,$mainpath)
    foreach($x in $mainpath){
        [decimal]$dur = ($x.Duration -split " ")[0]
        [decimal]$mstop = [decimal]$mstop + [decimal]$dur
    }

    foreach($xm in $pcbmodel){
        $csvhrly = $hourlycapmi|Where-Object{$xm.model -match $_.PartNumber}
        $csvhrly = $csvhrly|Select-Object -Property HourlyCapacity
        $hrly = $csvhrly.HourlyCapacity 

        $filtr = $src|Where-Object{$_.Name -eq $xm.Model}  
        $totalsec = (($filtr.Group).TotalTime|Measure-Object -Sum).Sum
        [decimal]$totalmins = [decimal]$totalsec/60
        [decimal]$timespent = ([decimal]$filtr.Count/[decimal]$hrly)*60

        [decimal]$totaldelay = [decimal]$totaldelay + ([decimal]$timespent-[decimal]$totalmins)
    }
    [decimal]$totaldelay = [decimal]$totaldelay + [decimal]$mstop
    [decimal]::Round($totaldelay,2)
}

function acttarget{
param($src,$pcbmodel,$hourlyC,$mainpath)
    #$mstop = $mainpath
    #[decimal]$mstop = ($mstop|Measure-Object -Sum).Sum
    foreach($x in $mainpath){
        [decimal]$dur = ($x.Duration -split " ")[0]
        [decimal]$mstop = [decimal]$mstop + [decimal]$dur
    }

    foreach($xm in $pcbmodel){
        $csvhrly = $hourlycapmi|Where-Object{$xm.model -match $_.PartNumber}|Select-Object -Property HourlyCapacity
        $hrly = $csvhrly.HourlyCapacity

        $filtr = $src|Where-Object{$_.Name -eq $xm.Model}  
        $totalsec = (($filtr.Group).TotalTime|Measure-Object -Sum).Sum
        [decimal]$totalmins = [decimal]$totalsec/60
        [decimal]$timespent = ([decimal]$filtr.Count/[decimal]$hrly)*60

        [decimal]$totaltime = [decimal]$totaltime+[decimal]$totalmins
        [decimal]$totaltimespent = [decimal]$totaltimespent+[decimal]$timespent

    }
    [decimal]$totaltime = [decimal]$totaltime - [decimal]$mstop
    #[decimal]$totaltimespent = [decimal]$totaltimespent - [decimal]$mstop
    [decimal]$acttarget = ([decimal]$totaltimespent/[decimal]$totaltime)
    [decimal]$acttarget = [decimal]$acttarget*100
    [decimal]::Round($acttarget,2)

}

function ATPM_hourly{
param($src,$pcbmodel,$stime)
    $filtr = $src|Where-Object{$_.Stime -eq $stime -and $pcbmodel -match $_.ATModel} #$_.Stime -eq $stime -and 

    $atpm = (($filtr.Group).TotalTime|Measure-Object -Sum).Sum
    $atpm

}
function target_hourly{
param($atpm,$model)
    $csvhrly = $hourlycapmi|Where-Object{$model -match $_.PartNumber}
    $csvhrly = $csvhrly|Select-Object -Property HourlyCapacity
    $hrly = $csvhrly.HourlyCapacity

    [decimal]$trgthrly = [decimal]$atpm * [decimal]$hrly
    [decimal]$trgthrly = [decimal]$trgthrly/3600
    [int]$trgthrly
    #[decimal]::Round($trgthrly,2) 


}
function actual_target{
param($src,$tspan)
    $acttrgt = $src|Where-Object{$_.Timespan -eq $tspan}
    $acctrgt = $acttrgt|Select-Object PCBTarget

    foreach($x in $acttrgt){
        [decimal]$total = [decimal]$total + [decimal]$x.PCBTarget 
    }
    [int]$total
    #[decimal]$total

}


function total_shift_output{
    $source = get_shift_data #Import-Csv "C:\MI_Monitoring\MI_Data\200805_ds.txt"
    $source|Add-Member -MemberType ScriptProperty -Name StartTime -Value {startDate -date ($this.Date)} -Force
    $source|Add-Member -MemberType ScriptProperty -Name TSpan -Value {-join((startDate -date $this.Date),"-",(endDate -date $this.Date))} -Force
    $grouped = $source|Group-Object PCBModel,StartTime,TSpan|Select-Object Count,Name
    $grouped|Add-Member -MemberType ScriptProperty -Name Model -Value {($this.name -split ", ")[0]}
    $grouped|Add-Member -MemberType ScriptProperty -Name TimeSpan -Value {($this.name -split ", ")[2]}
    $model = $grouped|Select-Object Model -Unique
    $count = $grouped|Select-Object count
   
    $modelcount = (-join(total_output -src $count))
    $modelcount
    
}


function total_shift_delay{
    $now = Get-Date
    $date = Get-Date -UFormat "%D"
    if($now -ge (Get-Date("8:10:00 AM")) -and $now -lt (Get-Date("3:24:59 PM"))){
        $shift = Get-Date -UFormat "%y%m%d_ds"
        $a = -join('"',$date,'"',",",'"8:00:00 AM - 08:00:00 AM"',",",'"0 mins."',",",'"Shift Maintenance"')     
    }elseif($now -ge (Get-Date("3:25:00 PM")) -and $now -lt (Get-Date("3:39:59 PM"))){
        $shift = Get-Date -UFormat "%y%m%d_ns"
        $a = -join('"',$date,'"',",",'"8:00:00 PM - 08:00:00 PM"',",",'"0 mins."',",",'"Shift Maintenance"')
    }else{
        $shift = (Get-Date).AddDays(-1)
        $shift = Get-Date($shift) -UFormat "%y%m%d_ns"
    }
    $test = Test-Path "C:\MI_Monitoring\MI_Downtime_Data\$shift.txt"
    
    $header = -join('"Date"',",",'"TimeSpan"',",",'"Duration"',",",'"Reason"')
    if($test -eq $false){
        $header|Out-File "C:\MI_Monitoring\MI_Downtime_Data\$shift.txt"
        $a|Out-File "C:\MI_Monitoring\MI_Downtime_Data\$shift.txt" -Append 
    }

    $source = get_shift_data #Import-Csv "C:\MI_Monitoring\MI_Data\200805_ds.txt"
    $grouped = $source|Group-Object PCBModel,StartTime,TSpan|Select-Object Count,Name
    $grouped|Add-Member -MemberType ScriptProperty -Name Model -Value {($this.name -split ", ")[0]}
    $model = $grouped|Select-Object Model -Unique
    $hourly = $source|Group-Object PCBModel
    
    $mpath = Import-Csv "C:\MI_Monitoring\MI_Downtime_Data\$shift.txt"
    $shiftdelay = (total_delay -src $hourly -pcbmodel $model -mainpath $mpath)
    $shiftdelay

}

function total_shift_acctarget{
    $now = Get-Date
    $date = Get-Date -UFormat "%D"
    if($now -ge (Get-Date("8:10:00 AM")) -and $now -lt (Get-Date("3:24:59 PM"))){
        $shift = Get-Date -UFormat "%y%m%d_ds"
        $a = -join('"',$date,'"',",",'"8:00:00 AM - 08:00:00 AM"',",",'"0 mins."',",",'"Shift Maintenance"')     
    }elseif($now -ge (Get-Date("3:25:00 PM")) -and $now -lt (Get-Date("3:39:59 PM"))){
        $shift = Get-Date -UFormat "%y%m%d_ns"
        $a = -join('"',$date,'"',",",'"8:00:00 PM - 08:00:00 PM"',",",'"0 mins."',",",'"Shift Maintenance"')
    }else{
        $shift = (Get-Date).AddDays(-1)
        $shift = Get-Date($shift) -UFormat "%y%m%d_ns"
    }
    $test = Test-Path "C:\MI_Monitoring\MI_Downtime_Data\$shift.txt"
    
    $header = -join('"Date"',",",'"TimeSpan"',",",'"Duration"',",",'"Reason"')
    if($test -eq $false){
        $header|Out-File "C:\MI_Monitoring\MI_Downtime_Data\$shift.txt"
        $a|Out-File "C:\MI_Monitoring\MI_Downtime_Data\$shift.txt" -Append 
    }



    $source = get_shift_data #Import-Csv "C:\MI_Monitoring\MI_Data\200805_ds.txt"
    $source|Add-Member -MemberType ScriptProperty -Name StartTime -Value {startDate -date ($this.Date)} -Force
    $source|Add-Member -MemberType ScriptProperty -Name TSpan -Value {-join((startDate -date $this.Date),"-",(endDate -date $this.Date))} -Force
    $grouped = $source|Group-Object PCBModel,StartTime,TSpan|Select-Object Count,Name
    $grouped|Add-Member -MemberType ScriptProperty -Name Model -Value {($this.name -split ", ")[0]}
    $grouped|Add-Member -MemberType ScriptProperty -Name TimeSpan -Value {($this.name -split ", ")[2]}
    $model = $grouped|Select-Object Model -Unique
    $hourly = $source|Group-Object PCBModel

    $mpath = Import-Csv "C:\MI_Monitoring\MI_Downtime_Data\$shift.txt"
    $accttarget = (-join (acttarget -src $hourly -pcbmodel $model -mainpath $mpath),"%")
    $accttarget


}


function mi_trouble{
    $now = Get-Date
    if($now -ge (Get-Date("8:00:00 AM")) -and $now -lt (Get-Date("3:24:59 PM"))){
        $shiftday = Get-Date -UFormat "%y%m%d_ds"
        #$shift = "Day"        
    }elseif($now -ge (Get-Date("3:25:00 PM")) -and $now -lt (Get-Date("11:59:59 PM"))){
        $shiftday = Get-Date -UFormat "%y%m%d_ns"
        #$shift = "Night"
    }else{
        $shiftday = (Get-Date).AddDays(-1)
        $shiftday = Get-Date($shiftday) -UFormat "%y%m%d_ns"
        #$shift = "Night"
    }

    $test = Test-Path "C:\MI_Monitoring\MI_Daily_Trouble\$shiftday.txt"
    if($test -eq $false){
        $trouble = Import-Csv "C:\MI_Monitoring\MI_Daily_Trouble\no_trouble.txt"
    }else{
        $trouble = Import-Csv "C:\MI_Monitoring\MI_Daily_Trouble\$shiftday.txt"
    }

    $trouble
}

function current_model{
param($currentmodel)
    $runningmodel = get_shift_data
    $runningmodel = $runningmodel|Where-Object{$_.PCBModel -eq $currentmodel}|Group-Object PCBModel
    $runningmodel = $runningmodel.Count
    $runningmodel

}
