function getToday{
$refTime1 = get-date("08:00")
$refTime2 = get-date("20:00")
$now = Get-Date

$test1 = $now -ge $refTime1
$test2 = $now -le $refTime2

if ($test1 -and $test2)
    {$filename = get-date -UFormat "%y%m%d_DS"}
    elseif($now -gt $refTime2){$filename = get-date -UFormat "%y%m%d_NS"}
    elseif($now -lt $refTime1){
            $ystrday = $now.AddDays(-1)
            $filename = Get-Date $ystrday -UFormat "%y%m%d_NS"
            }
$filename
}

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
    #$legend.Font = $font
    $legend.Alignment = "Center"
}
