import 'package:flutter/material.dart';
import '../models/match.dart';
import '../models/players.dart';

class MatchDetailsViewModel extends ChangeNotifier {
  final Match match;
  final List<Players> allPlayers;

  MatchDetailsViewModel({required this.match, required this.allPlayers});

  List<Players> get startersTeam1 => _getPlayers(match.pT1.take(11));
  List<Players> get benchTeam1 => _getPlayers(match.pT1.skip(11));

  List<Players> get startersTeam2 => _getPlayers(match.pT2.take(11));
  List<Players> get benchTeam2 => _getPlayers(match.pT2.skip(11));

  List<Players> _getPlayers(Iterable<String> names) {
    return names
        .map((name) => allPlayers.firstWhere(
          (p) => p.name == name,
      orElse: () => Players(name: name, position: '', team: '', alias: []),
    ))
        .toList();
  }
  String calculateFantaVoto(Map<String, dynamic>? stats, dynamic value) {
    if (stats == null || value == null) return '-';

    double votoBase = value is num ? value.toDouble() : double.tryParse(value.toString()) ?? 0.0;
    double bonus = 0.0;

    bonus += (stats['GF'] ?? 0) * 3;
    bonus += (stats['RigTrasf'] ?? 0) * 3;
    bonus += (stats['RigS'] ?? 0) * 3;
    bonus += (stats['Ass'] ?? 0) * 1;
    bonus += (stats['RigP'] ?? 0) * 3;

    bonus -= (stats['Aut'] ?? 0) * 3;
    bonus -= (stats['RigSbagliato'] ?? 0) * 3;
    bonus -= (stats['Esp'] ?? 0) * 1;
    bonus -= (stats['GS'] ?? 0) * 1;
    bonus -= (stats['Amm'] ?? 0) * 0.5;

    double totale = votoBase + bonus;
    return totale.toStringAsFixed(1);
  }

}
