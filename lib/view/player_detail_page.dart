import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../../models/players.dart';
import '../viewmodels/home_viewmodel.dart';
import 'player_detail_view_model.dart';

class PlayerDetailPage extends StatefulWidget {
  final Players player;

  const PlayerDetailPage({super.key, required this.player});

  @override
  State<PlayerDetailPage> createState() => _PlayerDetailPageState();
}

class _PlayerDetailPageState extends State<PlayerDetailPage> {
  int bonusStartIndex = 0;
  int votiStartIndex = 0;
  final int pageSize = 5;

  @override
  Widget build(BuildContext context) {
    final isAdmin = context.watch<HomeViewModel>().isAdmin;

    return ChangeNotifierProvider(
      create: (_) => PlayerDetailViewModel(widget.player),
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: Text(widget.player.name),
          backgroundColor: Colors.amber,
          foregroundColor: Colors.black,
        ),
        body: Consumer<PlayerDetailViewModel>(
          builder: (context, vm, _) {
            final votiData = vm.fantavotiChartData;

            return Padding(
              padding: const EdgeInsets.all(12),
              child: ListView(
                children: [
                  Center(
                    child: Text(
                      'Totali Stagionali:',
                      style: TextStyle(fontSize: 20, color: Colors.amber),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      vm.totalStats.entries.map((e) => '${e.key}=${e.value}').join(', ') +
                          (vm.fantamedia > 0 ? ' | Fantamedia=${vm.fantamedia.toStringAsFixed(2)}' : ''),
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(child: Text('Grafico Bonus/Malus', style: TextStyle(fontSize: 20, color: Colors.amber))),
                  SfCartesianChart(
                    backgroundColor: Colors.black,
                    primaryXAxis: NumericAxis(
                      title: AxisTitle(text: 'Giornata', textStyle: TextStyle(color: Colors.white)),
                      labelStyle: TextStyle(color: Colors.white),
                      initialVisibleMaximum: 10,
                      majorGridLines: const MajorGridLines(width: 0),
                      axisLabelFormatter: (AxisLabelRenderDetails details) {
                        return ChartAxisLabel(details.value.toInt().toString(), TextStyle(color: Colors.white));
                      },
                    ),
                    zoomPanBehavior: ZoomPanBehavior(
                      enablePanning: true,
                      zoomMode: ZoomMode.x,
                      enableMouseWheelZooming: true,
                      enablePinching: true,
                    ),
                    primaryYAxis: NumericAxis(labelStyle: TextStyle(color: Colors.white),majorGridLines: const MajorGridLines(width: 0),),
                    legend: const Legend(isVisible: true, textStyle: TextStyle(color: Colors.white)),
                    tooltipBehavior: TooltipBehavior(enable: true),
                    series: <CartesianSeries<ChartEntryBonusMalus, int>>[
                      ColumnSeries<ChartEntryBonusMalus, int>(
                        dataSource: List.generate(
                          vm.bonusMalusAggregati.length,
                              (i) => vm.bonusMalusAggregati[i],
                        ),
                        xValueMapper: (e, _) => e.giornata,
                        yValueMapper: (e, _) => e.bonus ?? 0,
                        name: 'Bonus',
                        color: Colors.green,
                        enableTooltip: true,
                      ),
                      ColumnSeries<ChartEntryBonusMalus, int>(
                        dataSource: List.generate(
                          vm.bonusMalusAggregati.length,
                              (i) => vm.bonusMalusAggregati[i],
                        ),
                        xValueMapper: (e, _) => e.giornata,
                        yValueMapper: (e, _) => e.malus ?? 0,
                        name: 'Malus',
                        color: Colors.red,
                        enableTooltip: true,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Center(child: Text('Grafico Fantavoti', style: TextStyle(fontSize: 20, color: Colors.amber))),
                  SfCartesianChart(
                    backgroundColor: Colors.black,
                    primaryXAxis: NumericAxis(
                      title: AxisTitle(text: 'Giornata', textStyle: TextStyle(color: Colors.white)),
                      labelStyle: TextStyle(color: Colors.white),
                      interval: 1,
                      initialVisibleMaximum: 10,
                      majorGridLines: const MajorGridLines(width: 0),
                      axisLabelFormatter: (AxisLabelRenderDetails details) {
                        return ChartAxisLabel(details.value.toInt().toString(), TextStyle(color: Colors.white));
                      },
                    ),
                    primaryYAxis: NumericAxis(
                      labelStyle: TextStyle(color: Colors.white),
                      majorGridLines: const MajorGridLines(width: 0),
                    ),
                    zoomPanBehavior: ZoomPanBehavior(
                      enablePanning: true,
                      zoomMode: ZoomMode.x,
                      enableMouseWheelZooming: true,
                      enablePinching: true,
                    ),
                    legend: const Legend(isVisible: true, textStyle: TextStyle(color: Colors.white)),
                    tooltipBehavior: TooltipBehavior(enable: true),
                    series: <CartesianSeries<ChartEntry, int>>[
                      LineSeries<ChartEntry, int>(
                        dataSource: List.generate(votiData.length, (i) => votiData[i]),
                        xValueMapper: (e, _) => e.giornata,
                        yValueMapper: (e, _) => e.vg,
                        name: 'VG',
                        color: Colors.greenAccent,
                        enableTooltip: true,
                      ),
                      LineSeries<ChartEntry, int>(
                        dataSource: List.generate(votiData.length, (i) => votiData[i]),
                        xValueMapper: (e, _) => e.giornata,
                        yValueMapper: (e, _) => e.vc,
                        name: 'VC',
                        color: Colors.cyan,
                        enableTooltip: true,
                      ),
                      LineSeries<ChartEntry, int>(
                        dataSource: List.generate(votiData.length, (i) => votiData[i]),
                        xValueMapper: (e, _) => e.giornata,
                        yValueMapper: (e, _) => e.vts,
                        name: 'VTS',
                        color: Colors.orangeAccent,
                        enableTooltip: true,
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  Center(child: Text('Statistiche per Giornata', style: TextStyle(fontSize: 20, color: Colors.amber))),
                  ...List.generate(vm.editableStats.length, (index) {
                    final giornata = index + 1;
                    final stats = vm.editableStats[index];
                    return Card(
                      color: Colors.grey[850],
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                              child: Text('Giornata $giornata', style: TextStyle(color: Colors.amber)),
                            ),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: stats.keys.map((key) {
                                return SizedBox(
                                  width: 90,
                                  child: isAdmin
                                      ? TextFormField(
                                    initialValue: stats[key]?.toString() ?? '0',
                                    style: TextStyle(color: Colors.white),
                                    decoration: InputDecoration(
                                      labelText: key,
                                      labelStyle: TextStyle(color: Colors.white70, fontSize: 12),
                                      enabledBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(color: Colors.white38),
                                      ),
                                    ),
                                    keyboardType: TextInputType.number,
                                    onChanged: (value) {
                                      vm.editableStats[index][key] = int.tryParse(value) ?? 0;
                                    },
                                  )
                                      : Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(key, style: TextStyle(color: Colors.white60, fontSize: 12)),
                                      Text('${stats[key]}', style: TextStyle(color: Colors.white)),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                  if (isAdmin)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Center(
                        child: ElevatedButton(
                          onPressed: () async {
                            await vm.saveEditedStatsToFirestore();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("✅ Statistiche salvate")),
                            );
                          },
                          child: const Text('Salva'),
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
