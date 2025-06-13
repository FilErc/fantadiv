// Aggiornamento della PlayerDetailPage con i grafici prima delle statistiche e scrolling orizzontale

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../../models/players.dart';
import 'player_detail_view_model.dart';

class PlayerDetailPage extends StatelessWidget {
  final Players player;

  const PlayerDetailPage({super.key, required this.player});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PlayerDetailViewModel(player),
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: Text(player.name),
          backgroundColor: Colors.amber,
          foregroundColor: Colors.black,
        ),
        body: Consumer<PlayerDetailViewModel>(
          builder: (context, vm, _) => Padding(
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

                Center(child: Text('Grafico Bonus/Malus', style: TextStyle(fontSize: 20, color: Colors.amber))),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    width: vm.bonusMalusChartData.length * 40.0,
                    child: SfCartesianChart(
                      backgroundColor: Colors.black,
                      primaryXAxis: NumericAxis(
                        title: AxisTitle(text: 'Giornata', textStyle: TextStyle(color: Colors.white)),
                        labelStyle: TextStyle(color: Colors.white),
                      ),
                      zoomPanBehavior: ZoomPanBehavior(
                        enablePanning: true,
                        zoomMode: ZoomMode.x,
                        enableMouseWheelZooming: true,
                        enablePinching: true,
                      ),
                      primaryYAxis: NumericAxis(labelStyle: TextStyle(color: Colors.white)),
                      legend: const Legend(isVisible: true, textStyle: TextStyle(color: Colors.white)),
                      tooltipBehavior: TooltipBehavior(enable: true),
                      series: <CartesianSeries<ChartEntry, int>>[
                        ColumnSeries<ChartEntry, int>(
                          dataSource: vm.bonusMalusChartData.where((e) => e.gf != 0).toList(),
                          xValueMapper: (e, _) => e.giornata,
                          yValueMapper: (e, _) => e.gf,
                          name: 'GF',
                          color: Colors.amber,
                          enableTooltip: true,
                        ),
                        ColumnSeries<ChartEntry, int>(
                          dataSource: vm.bonusMalusChartData.where((e) => e.gs != 0).toList(),
                          xValueMapper: (e, _) => e.giornata,
                          yValueMapper: (e, _) => e.gs,
                          name: 'GS',
                          color: Colors.red,
                          enableTooltip: true,
                        ),
                      ],
                    ),
                  ),
                ),


                const SizedBox(height: 16),
                Center(child: Text('Grafico Fantavoti', style: TextStyle(fontSize: 20, color: Colors.amber))),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    width: vm.fantavotiChartData.length * 40.0,
                    child: SfCartesianChart(
                      backgroundColor: Colors.black,
                      primaryXAxis: NumericAxis(
                        title: AxisTitle(text: 'Giornata', textStyle: TextStyle(color: Colors.white)),
                        labelStyle: TextStyle(color: Colors.white),
                      ),
                      zoomPanBehavior: ZoomPanBehavior(
                        enablePanning: true,
                        zoomMode: ZoomMode.x,
                        enableMouseWheelZooming: true,
                        enablePinching: true,
                      ),
                      primaryYAxis: NumericAxis(labelStyle: TextStyle(color: Colors.white)),
                      legend: const Legend(isVisible: true, textStyle: TextStyle(color: Colors.white)),
                      tooltipBehavior: TooltipBehavior(enable: true),
                      series: <CartesianSeries<ChartEntry, int>>[
                        LineSeries<ChartEntry, int>(
                          dataSource: vm.fantavotiChartData.where((e) => e.vg != null).toList(),
                          xValueMapper: (e, _) => e.giornata,
                          yValueMapper: (e, _) => e.vg,
                          name: 'VG',
                          color: Colors.greenAccent,
                          enableTooltip: true,
                        ),
                        LineSeries<ChartEntry, int>(
                          dataSource: vm.fantavotiChartData.where((e) => e.vc != null).toList(),
                          xValueMapper: (e, _) => e.giornata,
                          yValueMapper: (e, _) => e.vc,
                          name: 'VC',
                          color: Colors.cyan,
                          enableTooltip: true,
                        ),
                        LineSeries<ChartEntry, int>(
                          dataSource: vm.fantavotiChartData.where((e) => e.vts != null).toList(),
                          xValueMapper: (e, _) => e.giornata,
                          yValueMapper: (e, _) => e.vts,
                          name: 'VTS',
                          color: Colors.orangeAccent,
                          enableTooltip: true,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),
                Center(child: Text('Statistiche per Giornata:', style: TextStyle(fontSize: 20, color: Colors.amber))),
                ...vm.filteredStatsGrid.asMap().entries.map((e) {
                  final index = e.key;
                  final stats = e.value;

                  final giorno = 'Giornata ${index + 1}';

                  final valori = stats.entries.where((entry) =>
                  entry.value != null && entry.value != 0 && ['GF','GS','Aut','Amm','Esp','RigS','RigP'].contains(entry.key)
                  ).map((entry) => '${entry.key}=${entry.value}').join(', ');

                  final voti = ['VG', 'VC', 'VTS']
                      .where((k) => stats[k] != null)
                      .map((k) => '$k=${stats[k]}').join(', ');

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Center(
                      child: Text(
                        '$giorno: $valori${voti.isNotEmpty ? ' | $voti' : ''}',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
