import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'dart:io' show File;
import '../db/firebase_util_storage.dart';
import '../models/players.dart';
import 'listone_display_viewmodel.dart';

class ListoneImportViewModel extends ChangeNotifier {
  final FirebaseUtilStorage _storage = FirebaseUtilStorage();
  final ListoneDisplayViewModel _getterPlayer = ListoneDisplayViewModel();

  bool isLoading = false;

  Future<void> pickAndProcessFile() async {
    isLoading = true;
    notifyListeners();

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx'],
        withData: true,
      );

      if (result != null) {
        await _readExcelFile(result);
      }
    } catch (e) {
      print("Errore nell'importazione: $e");
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> _readExcelFile(FilePickerResult result) async {
    Uint8List? bytes;

    if (kIsWeb) {
      bytes = result.files.single.bytes;
    } else {
      final path = result.files.single.path;
      if (path == null) return;
      bytes = await File(path).readAsBytes();
    }

    final excel = Excel.decodeBytes(bytes!);
    const allowedSheets = {'Attaccanti', 'Centrocampisti', 'Difensori', 'Portieri'};

    List<Players> tempList = [];

    for (var table in excel.tables.keys) {
      if (!allowedSheets.contains(table)) continue;

      for (var row in excel.tables[table]!.rows) {
        final isEmptyRow = row.every((cell) {
          final value = cell?.value?.toString().trim();
          return value == null || value.isEmpty;
        });
        if (isEmptyRow) continue;

        List<String> rowData = row.map((cell) {
          String value = cell?.value?.toString() ?? "";
          if (value.contains(":")) value = value.split(":").last.trim();
          return value;
        }).toList();

        if (rowData[0] == 'Quotazioni Fantacalcio Stagione 2024 25' || rowData[0] == 'Id') continue;
        final name = rowData[3].trim();
        final position = rowData[1].trim();
        final team = rowData[4].trim();
        tempList.add(Players(name: name, position: position, team: team, alias: []));
      }
    }

    final existingPlayers = _getterPlayer.allPlayers;

    if (existingPlayers.isEmpty) {
      await _storage.savePlayersInBatch(tempList);
      return;
    }

    final Map<String, Players> existingMap = {
      for (var p in existingPlayers) p.name: p,
    };

    final Set<String> processedNames = {};
    List<Players> newPlayers = [];
    List<Players> updatedPlayers = [];
    List<Players> toDelete = [];

    for (var player in tempList) {
      final existing = existingMap[player.name];
      if (existing == null) {
        newPlayers.add(player);
      } else {
        processedNames.add(player.name);
        if (player.team != existing.team || player.position != existing.position) {
          final updated = Players(
            name: player.name,
            position: player.position,
            team: player.team,
            alias: [...existing.alias],
          );
          updatedPlayers.add(updated);
        }
      }
    }

    for (var existing in existingPlayers) {
      if (!tempList.any((p) => p.name == existing.name)) {
        toDelete.add(existing);
      }
    }

    if (newPlayers.isNotEmpty) {
      await _storage.savePlayersInBatch(newPlayers);
    }

    for (var updated in updatedPlayers) {
      await _storage.saveSinglePlayer(updated);
    }

    for (var player in toDelete) {
      await _storage.deletePlayer(player);
    }

    print("✅ Importazione completata.");
  }
}