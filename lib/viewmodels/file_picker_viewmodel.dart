import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:excel/excel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../db/firebase_util_storage.dart';
import '../models/players.dart';

import 'dart:io' show File;


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
      withData: true, // NECESSARIO per Web
    );

    if (result != null) {
      print("📂 File selezionato: ${result.files.single.name}");
      await _readExcelFile(result);
      _alreadyLoaded = true;
    } else {
      print("⚠️ Nessun file selezionato");
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _readExcelFile(FilePickerResult result) async {
    try {
      Uint8List? bytes;

      if (kIsWeb) {
        bytes = result.files.single.bytes;
        if (bytes == null) {
          return;
        }
      } else {
        final path = result.files.single.path;
        if (path == null) {
          return;
        }
        final file = File(path);
        bytes = await file.readAsBytes();
      }

      final excel = Excel.decodeBytes(bytes!);
      print("📄 Tabelle trovate: ${excel.tables.keys}");

      const allowedSheets = {
        'Attaccanti',
        'Centrocampisti',
        'Difensori',
        'Portieri',
      };

      for (var table in excel.tables.keys) {
        if (!allowedSheets.contains(table)) {
          print("⛔ Tabella ignorata: $table");
          continue;
        }

        print("📋 Leggo tabella visibile: $table");

        for (var row in excel.tables[table]!.rows) {
          final isEmptyRow = row.every((cell) {
            final value = cell?.value?.toString().trim();
            return value == null || value.isEmpty;
          });

          if (isEmptyRow) continue;

          List<String> rowData = [];
          for (var cell in row) {
            String value = cell?.value?.toString() ?? "";
            if (value.contains(":")) value = value.split(":").last.trim();
            rowData.add(value);
          }

          print("➡️ Riga: $rowData");
          await _storage.storePlayers(rowData);
        }
      }


      print("✅ Importazione completata con successo.");
      print("────────────────────────────");
    } catch (e) {
      print("❌ Errore durante la lettura del file Excel: $e");
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
    } else {
      _alreadyLoaded = false;
    }

    isLoadingPlayers = false;
    notifyListeners();
  }
}
