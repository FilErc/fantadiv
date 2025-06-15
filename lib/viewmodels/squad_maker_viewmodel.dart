import 'package:flutter/material.dart';

class SquadMakerViewModel extends ChangeNotifier {
  final List<String> _selectedPlayers = [];

  List<String> get selectedPlayers => _selectedPlayers;

  void addPlayer(String playerName) {
    if (!_selectedPlayers.contains(playerName)) {
      _selectedPlayers.add(playerName);
      notifyListeners();
    }
  }

  void removePlayer(String playerName) {
    _selectedPlayers.remove(playerName);
    notifyListeners();
  }

  void confirmSquad() {
    // TODO: logica per salvare la formazione (es. su Firebase)
    print("Formazione confermata: $_selectedPlayers");
  }
}
