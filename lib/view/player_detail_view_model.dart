import 'package:flutter/material.dart';
import '../../models/players.dart';

class PlayerDetailViewModel extends ChangeNotifier {
  final Players player;

  PlayerDetailViewModel(this.player);

  Map<String, int> get totalStats {
    final totals = <String, int>{};
    if (player.statsGrid == null) return totals;

    for (var entry in player.statsGrid!) {
      entry.forEach((key, value) {
        if (['GF', 'GS', 'Aut', 'Ass', 'Amm', 'Esp', 'RigS', 'RigP'].contains(key)) {
          final v = (value ?? 0) as int;
          totals[key] = (totals[key] ?? 0) + v;
        }
      });
    }
    return totals;
  }

  double get fantamedia {
    final values = <double>[];
    for (var entry in player.statsGrid ?? []) {
      for (var key in ['VG', 'VC', 'VTS']) {
        if (entry[key] != null) {
          values.add(entry[key].toDouble());
        }
      }
    }
    return values.isEmpty ? 0.0 : values.reduce((a, b) => a + b) / values.length;
  }

  List<Map<String, dynamic>> get filteredStatsGrid {
    return player.statsGrid?.where((e) => e.values.any((v) => v != null)).toList() ?? [];
  }

  List<ChartEntry> get bonusMalusChartData {
    final list = <ChartEntry>[];
    for (int i = 0; i < (player.statsGrid?.length ?? 0); i++) {
      final m = player.statsGrid![i];
      list.add(ChartEntry(
        giornata: i + 1,
        gf: m['GF'] ?? 0,
        gs: m['GS'] ?? 0,
        ass: m['Ass'] ?? 0,
      ));
    }
    return list;
  }

  List<ChartEntry> get fantavotiChartData {
    final list = <ChartEntry>[];
    for (int i = 0; i < (player.statsGrid?.length ?? 0); i++) {
      final m = player.statsGrid![i];
      if (m['VG'] != null || m['VC'] != null || m['VTS'] != null) {
        list.add(ChartEntry(
          giornata: i + 1,
          vg: m['VG'],
          vc: m['VC'],
          vts: m['VTS'],
        ));
      }
    }
    return list;
  }
}

class ChartEntry {
  final int giornata;
  final int gf, gs, ass;
  final double? vg, vc, vts;

  ChartEntry({
    required this.giornata,
    this.gf = 0,
    this.gs = 0,
    this.ass = 0,
    this.vg,
    this.vc,
    this.vts,
  });
}
