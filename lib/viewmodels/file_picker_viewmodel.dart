import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:excel/excel.dart';

import '../db/firebase_util_storage.dart';
import '../models/players.dart';

class FilePickerViewModel extends ChangeNotifier {
  final FirebaseUtilStorage _storage = FirebaseUtilStorage();
  String? _filePath;
  bool _isLoading = false;
  bool _alreadyLoaded = false;
  bool isLoadingPlayers = false;

  final Map<String, List<Players>> _playersByPosition = {};
  Map<String, List<Players>> get playersByPosition => _playersByPosition;

  String? get filePath => _filePath;
  bool get isLoading => _isLoading;
  bool get alreadyLoaded => _alreadyLoaded;

  FilePickerViewModel() {
    checker();
  }

  Future<void> pickAndProcessFile() async {
    _isLoading = true;
    notifyListeners();

    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xls', 'xlsx'],
    );

    if (result != null) {
      _filePath = result.files.single.path;
      if (_filePath != null) {
        await _readExcelFile(_filePath!);
        _alreadyLoaded = true;
      }
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _readExcelFile(String path) async {
    try {
      var file = File(path);
      var bytes = file.readAsBytesSync();
      var excel = Excel.decodeBytes(bytes);

      for (var table in excel.tables.keys) {
        for (var row in excel.tables[table]!.rows) {
          List<String> rowData = [];
          for (var cell in row) {
            String value = cell?.value?.toString() ?? "";
            if (value.contains(":")) {
              value = value.split(":").last.trim();
            }
            rowData.add(value);
          }

          await _storage.storePlayers(rowData);
        }
      }
    } catch (e) {
      print("Errore durante la lettura del file Excel: $e");
    }
  }

  Future<void> checker() async {
    isLoadingPlayers = true;
    notifyListeners();

    if (await _storage.checkPlayers()) {
      _alreadyLoaded = true;

      List<QuerySnapshot<Object?>> snapshots = await _storage.loadPlayers();

      for (var snap in snapshots) {
        for (var doc in snap.docs) {
          final player = Players.fromMap(doc.data() as Map<String, dynamic>);
          final pos = player.position;

          _playersByPosition.putIfAbsent(pos, () => []);
          _playersByPosition[pos]!.add(player);
        }
      }
    }
    else{
      _alreadyLoaded = false;
    }

    isLoadingPlayers = false;
    notifyListeners();
  }
}
