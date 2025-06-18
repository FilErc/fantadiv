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
}
