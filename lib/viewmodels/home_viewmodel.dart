import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../db/firebase_util_storage.dart';
import '../models/calendar.dart';

class HomeViewModel extends ChangeNotifier {
  final FirebaseUtilStorage _storage = FirebaseUtilStorage();
  int _selectedIndex = 0;
  bool _isAdmin = false;
  bool _isLoading = true;
  List<Round> _allRounds = []; // Store fetched calendar data

  int get selectedIndex => _selectedIndex;
  bool get isAdmin => _isAdmin;
  bool get isLoading => _isLoading;
  List<Round> get allRounds => _allRounds; // Expose data to UI

  bool _isDisposed = false; // Added flag to check if the ViewModel is disposed

  HomeViewModel() {
    checkUserPermissions();
    getCalendar();
  }

  // Ensure that we don't notify listeners after disposal
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
}
