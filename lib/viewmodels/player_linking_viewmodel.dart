import 'package:flutter/material.dart';
import '../models/players.dart';

class PlayerLinkingViewModel extends ChangeNotifier {
  final String searchName;
  final List<Players> allPlayers;

  PlayerLinkingViewModel(this.searchName, this.allPlayers) {
    _refreshFilteredPlayers();
  }

  Players? _selectedPlayer;
  Players? get selectedPlayer => _selectedPlayer;

  List<Players> filteredPlayers = [];

  void selectPlayer(Players player) {
    _selectedPlayer = player;
    if (!player.alias.contains(searchName)) {
      player.alias.add(searchName);
    }
    final index = allPlayers.indexWhere((p) => p.name == player.name && p.team == player.team);
    if (index != -1) {
      allPlayers[index] = player;
    }

    _refreshFilteredPlayers();
    notifyListeners();
  }


  void search(String query) {
    final lower = query.trim().toLowerCase();
    _refreshFilteredPlayers();
    filteredPlayers = filteredPlayers.where((p) {
      return p.name.toLowerCase().contains(lower) ||
          p.alias.any((alias) => alias.toLowerCase().contains(lower));
    }).toList();
    notifyListeners();
  }


  void _refreshFilteredPlayers() {
    filteredPlayers = allPlayers.where((p) => !p.alias.contains(searchName)).toList();
  }
}
