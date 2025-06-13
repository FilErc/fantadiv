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
  List<ChartEntryBonusMalus> get bonusMalusAggregati {
    final List<ChartEntryBonusMalus> list = [];

    for (int i = 0; i < player.statsGrid!.length; i++) {
      final stats = player.statsGrid?[i];

      double bonus = 0;
      double malus = 0;

      // Bonus
      bonus += (stats?['GF'] ?? 0) * 3;
      bonus += (stats?['Ass'] ?? 0) * 1;
      bonus += (stats?['RigP'] ?? 0) * 3;
      if (player.position == 'P' && (stats?['GS'] ?? 0) == 0) {
        bonus += 1;
      }

      // Malus
      malus += (stats?['Amm'] ?? 0) * 0.5;
      malus += (stats?['Esp'] ?? 0) * 1;
      malus += (stats?['Aut'] ?? 0) * 3;
      if (player.position == 'P') {
        malus += (stats?['GS'] ?? 0) * 1;
      }

      // Inserisci solo se almeno uno non è 0
      if (bonus != 0 || malus != 0) {
        list.add(ChartEntryBonusMalus(giornata: i + 1, bonus: bonus, malus: -malus));
      }
    }

    return list;
  }
}
class ChartEntryBonusMalus {
  final int giornata;
  final double bonus;
  final double malus;

  ChartEntryBonusMalus({required this.giornata, required this.bonus, required this.malus});
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
