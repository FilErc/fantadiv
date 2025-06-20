import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../db/firebase_util_storage.dart';
import '../models/round.dart';

class TimeViewModel extends ChangeNotifier {
  final FirebaseUtilStorage _storage = FirebaseUtilStorage();

  List<Round> _rounds = [];
  bool _loading = true;

  List<Round> get rounds => _rounds;
  bool get isLoading => _loading;

  TimeViewModel() {
    fetchRounds();
  }

  Future<void> fetchRounds() async {
    _loading = true;
    notifyListeners();

    _rounds = await _storage.getAllRounds();
    _loading = false;
    notifyListeners();
  }

  Future<void> updateTimestamp(int roundIndex, DateTime newTimestamp) async {
    if (roundIndex < 0 || roundIndex >= _rounds.length) return;

    final oldRound = _rounds[roundIndex];

    final updatedRound = Round(
      oldRound.day,
      oldRound.matches,
      timestamp: newTimestamp,
      boolean: oldRound.boolean,
    );

    _rounds[roundIndex] = updatedRound;

    try {
      await _storage.updateRound(updatedRound.day, updatedRound);
      notifyListeners();
    } catch (e) {
      print("Errore durante l'aggiornamento del timestamp: $e");
    }
  }

}
