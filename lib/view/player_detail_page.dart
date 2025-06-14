import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../../models/players.dart';
import '../viewmodels/home_viewmodel.dart';
import '../viewmodels/player_detail_viewmodel.dart';

class PlayerDetailPage extends StatefulWidget {
  final Players player;

  const PlayerDetailPage({super.key, required this.player});

  @override
  State<PlayerDetailPage> createState() => _PlayerDetailPageState();
}

class _PlayerDetailPageState extends State<PlayerDetailPage> {
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
                    primaryYAxis: NumericAxis(
                      labelStyle: TextStyle(color: Colors.white),
                      majorGridLines: const MajorGridLines(width: 0),
                    ),
                    legend: const Legend(isVisible: true, textStyle: TextStyle(color: Colors.white)),
                    tooltipBehavior: TooltipBehavior(enable: true),
                    series: <CartesianSeries<ChartEntryBonusMalus, int>>[
                      ColumnSeries<ChartEntryBonusMalus, int>(
                        dataSource: vm.bonusMalusAggregati,
                        xValueMapper: (e, _) => e.giornata,
                        yValueMapper: (e, _) => e.bonus,
                        name: 'Bonus',
                        color: Colors.green,
                        enableTooltip: true,
                      ),
                      ColumnSeries<ChartEntryBonusMalus, int>(
                        dataSource: vm.bonusMalusAggregati,
                        xValueMapper: (e, _) => e.giornata,
                        yValueMapper: (e, _) => e.malus,
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
                        dataSource: votiData,
                        xValueMapper: (e, _) => e.giornata,
                        yValueMapper: (e, _) => e.vg,
                        name: 'VG',
                        color: Colors.greenAccent,
                        enableTooltip: true,
                      ),
                      LineSeries<ChartEntry, int>(
                        dataSource: votiData,
                        xValueMapper: (e, _) => e.giornata,
                        yValueMapper: (e, _) => e.vc,
                        name: 'VC',
                        color: Colors.cyan,
                        enableTooltip: true,
                      ),
                      LineSeries<ChartEntry, int>(
                        dataSource: votiData,
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
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('Giornata $giornata', style: const TextStyle(color: Colors.amber, fontSize: 16)),
                            const SizedBox(height: 12),
                            _buildStatsRow([
                              _buildStatBox('📘', 'Voto Corriere dello Sport', stats['VC'], isAdmin: isAdmin, onChanged: (v) => vm.editableStats[index]['VC'] = int.tryParse(v) ?? 0),
                              _buildStatBox('📗', 'Voto Gazzetta dello Sport', stats['VG'], isAdmin: isAdmin, onChanged: (v) => vm.editableStats[index]['VG'] = int.tryParse(v) ?? 0),
                              _buildStatBox('📒', 'Voto Tutto Sport', stats['VTS'], isAdmin: isAdmin, onChanged: (v) => vm.editableStats[index]['VTS'] = int.tryParse(v) ?? 0),
                            ]),
                            const SizedBox(height: 8),
                            _buildStatsRow([
                              _buildStatBox('⚽', 'Goal', stats['GF'], isAdmin: isAdmin, onChanged: (v) => vm.editableStats[index]['GF'] = int.tryParse(v) ?? 0),
                              _buildStatBox('🎯', 'Assist', stats['Ass'], isAdmin: isAdmin, onChanged: (v) => vm.editableStats[index]['Ass'] = int.tryParse(v) ?? 0),
                              _buildStatBox('✅', 'Rigore Segnato', stats['RigTrasf'], isAdmin: isAdmin, onChanged: (v) => vm.editableStats[index]['RigTrasf'] = int.tryParse(v) ?? 0),
                              _buildStatBox('❌', 'Rigore Sbagliato', stats['RigSbagliato'], isAdmin: isAdmin, onChanged: (v) => vm.editableStats[index]['RigSbagliato'] = int.tryParse(v) ?? 0),
                            ]),
                            const SizedBox(height: 8),
                            _buildStatsRow([
                              _buildStatBox('🟥', 'Espulsione', stats['Esp'], isAdmin: isAdmin, onChanged: (v) => vm.editableStats[index]['Esp'] = int.tryParse(v) ?? 0),
                              _buildStatBox('🟨', 'Ammonizione', stats['Amm'], isAdmin: isAdmin, onChanged: (v) => vm.editableStats[index]['Amm'] = int.tryParse(v) ?? 0),
                            ]),
                            const SizedBox(height: 8),
                            _buildStatsRow([
                              _buildStatBox('🧤', 'Goal Subito', stats['GS'], isAdmin: isAdmin, onChanged: (v) => vm.editableStats[index]['GS'] = int.tryParse(v) ?? 0),
                              _buildStatBox('🎯', 'Rigore Parato', stats['RigP'], isAdmin: isAdmin, onChanged: (v) => vm.editableStats[index]['RigP'] = int.tryParse(v) ?? 0),
                            ]),
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

  Widget _buildStatsRow(List<Widget> children) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8,
      runSpacing: 8,
      children: children,
    );
  }

  Widget _buildStatBox(String emoji, String label, dynamic value, {bool isAdmin = false, Function(String)? onChanged}) {
    return Container(
      width: 110,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey[700],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 4),
          Text(label, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 10)),
          const SizedBox(height: 4),
          isAdmin
              ? SizedBox(
            height: 24,
            child: TextFormField(
              initialValue: value?.toString() ?? '0',
              style: const TextStyle(color: Colors.amber, fontSize: 14),
              textAlign: TextAlign.center,
              decoration: const InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                border: InputBorder.none,
              ),
              keyboardType: TextInputType.number,
              onChanged: onChanged,
            ),
          )
              : Text(
            value?.toString() ?? '',
            style: const TextStyle(color: Colors.amber, fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
