import 'package:flutter/material.dart';
import '../db/firebase_util_storage.dart';
import '../models/players.dart';

class ListoneDisplayViewModel extends ChangeNotifier {
  final FirebaseUtilStorage _storage = FirebaseUtilStorage();

  bool isLoading = false;
  bool isSearching = false;
  List<Players> searchResults = [];
  Players? searchedPlayer;

  final Map<String, List<Players>> _playersByPosition = {};
  Map<String, List<Players>> get playersByPosition => _playersByPosition;

  ListoneDisplayViewModel() {
    loadPlayers();
  }

  List<Players> get allPlayers {
    return _playersByPosition.values.expand((list) => list).toList();
  }

  Future<void> loadPlayers() async {
    isLoading = true;
    notifyListeners();

    try {
      final grouped = await _storage.loadPlayers();
      _playersByPosition.clear();
      _playersByPosition.addAll(grouped);
    } catch (e) {
      print("Errore nel caricamento giocatori: $e");
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> searchPlayersByFragment(String fragment) async {
    searchResults.clear();
    isSearching = true;
    notifyListeners();

    final lower = fragment.toLowerCase();
    final seen = <String>{};

    for (final group in _playersByPosition.values) {
      for (final p in group) {
        final match = p.name.toLowerCase().contains(lower) || p.alias.any((a) => a.toLowerCase().contains(lower));
        if (match && !seen.contains(p.name)) {
          searchResults.add(p);
          seen.add(p.name);
        }
      }
    }

    isSearching = false;
    notifyListeners();
  }
}
