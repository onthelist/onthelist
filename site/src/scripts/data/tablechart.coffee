class ChartRack extends $D._DataLoader
  name: 'charts'
  model_name: 'chart'

$D.charts = new ChartRack

do $D.charts.sync

