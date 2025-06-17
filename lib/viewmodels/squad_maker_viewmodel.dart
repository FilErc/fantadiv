import 'package:flutter/material.dart';
import '../db/firebase_util_storage.dart';
import '../models/players.dart';

class SquadMakerViewModel extends ChangeNotifier {
  final FirebaseUtilStorage _firebaseUtil = FirebaseUtilStorage();

  Map<String, List<String>> roleToPlayers = {
    'P': [],
    'D': [],
    'C': [],
    'A': [],
  };

  List<String> _orderedBench = [];

  List<String> get orderedBench => _orderedBench;

  void updateBenchOrder(List<String> newOrder) {
    _orderedBench = newOrder;
    notifyListeners();
  }

  void initializeBench(List<Players> allPlayers, Set<String> starters) {
    _orderedBench = allPlayers
        .where((p) => !starters.contains(p.name))
        .map((p) => p.name)
        .toList();
    notifyListeners();
  }

  void setPlayerAt(String role, int index, String name) {
    _orderedBench.remove(name);

    if (roleToPlayers[role]!.length > index && roleToPlayers[role]![index].isNotEmpty) {
      final removed = roleToPlayers[role]![index];
      _orderedBench.add(removed);
    }

    while (roleToPlayers[role]!.length <= index) {
      roleToPlayers[role]!.add('');
    }

    roleToPlayers[role]![index] = name;
    notifyListeners();
  }

  String getPlayerAt(String role, int index) {
    if (roleToPlayers[role]!.length > index) {
      return roleToPlayers[role]![index];
    }
    return '';
  }

  void clearSquadWithStructure(Map<String, int> roleCounts) {
    roleToPlayers = {
      for (var key in roleCounts.keys)
        key: List.filled(roleCounts[key]!, '', growable: true),
    };
    _orderedBench.clear();
    notifyListeners();
  }

  bool isSquadComplete(Map<String, int> roleCounts) {
    for (var role in roleCounts.keys) {
      if (roleToPlayers[role]!.where((n) => n.isNotEmpty).length != roleCounts[role]) {
        return false;
      }
    }
    return true;
  }

  void confirmSquad() {
    final orderedRoles = ['P', 'D', 'C', 'A'];
    List<String> titolari = [];

    for (var role in orderedRoles) {
      titolari.addAll(roleToPlayers[role]!.where((name) => name.isNotEmpty));
    }

    List<String> panchinari = List.from(_orderedBench);

    List<String> formazioneFinale = [...titolari, ...panchinari];

    print('--- FORMAZIONE COMPLETA ---');
    for (int i = 0; i < formazioneFinale.length; i++) {
      final tipo = i < 11 ? 'Titolare' : 'Panchinaro';
      print('${i + 1}. [$tipo] ${formazioneFinale[i]}');
    }
  }

}

