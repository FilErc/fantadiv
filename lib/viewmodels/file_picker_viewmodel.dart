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
  List<Players> _playersStored = [];
  bool isLoadingPlayers = false; // Stato per il caricamento
  List<Players> get playersStored => _playersStored;

  String? get filePath => _filePath;

  bool get isLoading => _isLoading;

  bool get alreadyLoaded => _alreadyLoaded;


  FilePickerViewModel(){
    checker();
  }

  Future<void> pickAndProcessFile() async {
    _isLoading = true;
    notifyListeners(); // Notifica alla UI l'inizio del caricamento

    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xls', 'xlsx'],
    );

    if (result != null) {
      _filePath = result.files.single.path;

      if (_filePath != null) {
        await _readExcelFile(_filePath!);
      }
    }

    _isLoading = false;
    notifyListeners(); // Notifica alla UI la fine del caricamento
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
            if (cell != null) {
              var value = cell.value.toString();
              if (value.contains(":")) {
                value = value
                    .split(":")
                    .last
                    .trim();
              }
              rowData.add(value);
            } else {
              rowData.add("");
            }
          }
          _storage.storePlayers(rowData);
        }
      }
    } catch (e) {
      print("Errore durante la lettura del file Excel: $e");
    }
  }

  Future<void> checker() async {
    isLoadingPlayers = true; // Mostra il caricamento
    notifyListeners();

    if (await _storage.checkPlayers()) {
      _alreadyLoaded = true;

      // Carica tutti gli snapshot da Firestore
      List<QuerySnapshot<Object?>> snapshots = await _storage.loadPlayers();

      // Unisce tutti i documenti e li trasforma in oggetti Players
      _playersStored = snapshots
          .expand((querySnapshot) => querySnapshot.docs)
          .map((doc) => Players.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    }

    isLoadingPlayers = false; // Nasconde il caricamento
    notifyListeners();
  }
}