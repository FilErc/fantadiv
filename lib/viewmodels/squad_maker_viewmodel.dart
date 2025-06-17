import 'package:fantadiv/models/round.dart';
import 'package:fantadiv/models/squad.dart';
import 'package:flutter/material.dart';
import '../db/firebase_util_storage.dart';
import '../models/players.dart';

class SquadMakerViewModel extends ChangeNotifier {
  final FirebaseUtilStorage _firebaseUtil = FirebaseUtilStorage();

  Map<String, List<Players>> roleToPlayers = {
    'P': [],
    'D': [],
    'C': [],
    'A': [],
  };

  List<Players> _orderedBench = [];

  List<Players> get orderedBench => _orderedBench;

  void updateBenchOrder(List<Players> newOrder) {
    _orderedBench = newOrder;
    notifyListeners();
  }

  void initializeBench(List<Players> allPlayers, Set<String> starters) {
    _orderedBench = allPlayers
        .where((p) => !starters.contains(p.name))
        .toList();
    notifyListeners();
  }

  void setPlayerAt(String role, int index, Players player) {
    _orderedBench.removeWhere((p) => p.name == player.name);

    if (roleToPlayers[role]!.length > index && roleToPlayers[role]![index].name.isNotEmpty) {
      final removed = roleToPlayers[role]![index];
      _orderedBench.add(removed);
    }

    while (roleToPlayers[role]!.length <= index) {
      roleToPlayers[role]!.add(Players(name: '', position: '', team: '', alias: []));
    }

    roleToPlayers[role]![index] = player;
    notifyListeners();
  }

  Players? getPlayerAt(String role, int index) {
    if (roleToPlayers[role]!.length > index) {
      final p = roleToPlayers[role]![index];
      return p.name.isEmpty ? null : p;
    }
    return null;
  }

  void clearSquadWithStructure(Map<String, int> roleCounts) {
    roleToPlayers = {
      for (var key in roleCounts.keys)
        key: List.generate(roleCounts[key]!, (_) => Players(name: '', position: '', team: '', alias: [])),
    };
    _orderedBench.clear();
    notifyListeners();
  }

  bool isSquadComplete(Map<String, int> roleCounts) {
    for (var role in roleCounts.keys) {
      if (roleToPlayers[role]!.where((p) => p.name.isNotEmpty).length != roleCounts[role]) {
        return false;
      }
    }
    return true;
  }

  void confirmSquad(Round giornata, Squad squad) {
    final orderedRoles = ['P', 'D', 'C', 'A'];
    List<Players> titolari = [];

    for (var role in orderedRoles) {
      titolari.addAll(roleToPlayers[role]!.where((p) => p.name.isNotEmpty));
    }

    List<Players> panchinari = List.from(_orderedBench);
    List<Players> formazioneFinale = [...titolari, ...panchinari];

    print('--- GIORNATA SELEZIONATA ---');
    print('Day: ${giornata.day}');
    print('Timestamp: ${giornata.timestamp}');
    print('Giocata: ${giornata.boolean}');

    print('--- SQUAD ASSOCIATA ---');
    print(squad.id);

    print('--- FORMAZIONE COMPLETA ---');
    for (int i = 0; i < formazioneFinale.length; i++) {
      final tipo = i < 11 ? 'Titolare' : 'Panchinaro';
      print('${i + 1}. [$tipo] ${formazioneFinale[i].name}');
    }
  }

}
