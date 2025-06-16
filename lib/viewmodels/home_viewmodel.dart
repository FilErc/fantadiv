import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../db/firebase_util_storage.dart';
import '../models/round.dart';
import '../services/server_time_service.dart';

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

  String _countdown = '';
  String get countdown => _countdown;

  Timer? _countdownTimer;
  Duration? _countdownDuration;
  DateTime? _serverTimeFetchedAt;

  HomeViewModel() {
    checkUserPermissions();
    getCalendar();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _countdownTimer?.cancel();
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
      notifyListeners();
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

    if (firstIncompleteRound != null && firstIncompleteRound!.timestamp != null) {
      startCountdownTimer();
    }
  }

  int get firstIncompleteIndex {
    return allRounds.indexWhere((r) => r.boolean == false);
  }

  Round? get firstIncompleteRound {
    final index = firstIncompleteIndex;
    return index != -1 ? allRounds[index] : null;
  }

  void startCountdownTimer() async {
    final round = firstIncompleteRound;
    if (round == null || round.timestamp == null) return;

    final serverNow = await ServerTimeService.fetchServerTime();
    if (serverNow == null) {
      _countdown = "Errore nel recupero dell'orario server";
      if (!_isDisposed) notifyListeners();
      return;
    }

    _serverTimeFetchedAt = DateTime.now();
    _countdownDuration = round.timestamp!.difference(serverNow);

    _updateCountdown();
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) => _updateCountdown());
  }


  void _updateCountdown() {
    if (_countdownDuration == null || _serverTimeFetchedAt == null) {
      _countdown = "Nessuna data disponibile";
      if (!_isDisposed) notifyListeners();
      return;
    }

    final elapsed = DateTime.now().difference(_serverTimeFetchedAt!);
    final remaining = _countdownDuration! - elapsed;

    if (remaining.isNegative) {
      _countdown = "In corso o già passato";
    } else {
      final days = remaining.inDays;
      final hours = remaining.inHours % 24;
      final minutes = remaining.inMinutes % 60;
      final seconds = remaining.inSeconds % 60;
      _countdown = "$days giorni, $hours ore, $minutes minuti, $seconds secondi rimanenti";
    }

    if (!_isDisposed) notifyListeners();
  }

  bool get isCountdownReady {
    return _countdown.isNotEmpty &&
        _countdown != "Nessuna data disponibile" &&
        _countdown != "Errore nel recupero dell'orario server";
  }
}
