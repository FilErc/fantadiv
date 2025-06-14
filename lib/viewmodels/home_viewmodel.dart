import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../db/firebase_util_storage.dart';
import '../models/round.dart';

class HomeViewModel extends ChangeNotifier {
  final FirebaseUtilStorage _storage = FirebaseUtilStorage();
  int _selectedIndex = 0;
  bool _isAdmin = false;
  bool _isLoading = true;
  List<Round> _allRounds = [];

  int get selectedIndex => _selectedIndex;
  bool get isAdmin => _isAdmin;
  bool get isLoading => _isLoading;
  List<Round> get allRounds => _allRounds;

  bool _isDisposed = false;

  HomeViewModel() {
    checkUserPermissions();
    getCalendar();
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  Future<void> checkUserPermissions() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String email = user.email ?? "";
      final QuerySnapshot query = await FirebaseFirestore.instance
          .collection('permissionPlus')
          .get();

      for (var doc in query.docs) {
        final data = doc.data() as Map<String, dynamic>;
        if (data['who'] == email && data['kind'] == 'admin') {
          _isAdmin = true;
          break;
        }
      }
    }

    _isLoading = false;

    if (!_isDisposed) {
      notifyListeners(); // Only notify listeners if the ViewModel is not disposed
    }
  }

  void updateSelectedIndex(int index) {
    _selectedIndex = index;
    if (!_isDisposed) {
      notifyListeners();
    }
  }

  Future<void> getCalendar() async {
    _allRounds = await _storage.getAllRounds();
    if (!_isDisposed) {
      notifyListeners();
    }
  }

  int get firstIncompleteIndex {
    return allRounds.indexWhere((r) => r.boolean == false);
  }

  Round? get firstIncompleteRound {
    final index = firstIncompleteIndex;
    return index != -1 ? allRounds[index] : null;
  }

  String getCountdownToFirstIncomplete() {
    final round = firstIncompleteRound;
    if (round == null || round.timestamp == null) return "Nessuna data disponibile";

    final now = DateTime.now();
    final diff = round.timestamp!.difference(now);

    if (diff.isNegative) return "In corso o già passato";

    final days = diff.inDays;
    final hours = diff.inHours % 24;
    final minutes = diff.inMinutes % 60;

    return "$days giorni, $hours ore, $minutes minuti rimanenti";
  }
}
