import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'dart:io' show File;
import '../db/firebase_util_storage.dart';
import '../models/players.dart';

class ListoneImportViewModel extends ChangeNotifier {
  final FirebaseUtilStorage _storage = FirebaseUtilStorage();

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

    final newPlayers = <Players>[];
    final seenNames = <String>{};

    final currentPlayersByPosition = await _storage.loadPlayers();
    final currentAllPlayers = currentPlayersByPosition.values.expand((x) => x).toList();

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

        if (rowData.length < 5) continue;

        final name = rowData[3].trim();
        final position = rowData[1].trim();
        final team = rowData[4].trim();
        seenNames.add(name.toLowerCase());

        final existing = currentAllPlayers.firstWhere(
              (p) => p.name.toLowerCase() == name.toLowerCase(),
          orElse: () => Players(name: name, position: position, team: team, alias: []),
        );

        final updated = Players(
          name: existing.name,
          position: position,
          team: team,
          alias: existing.alias,
        );
        newPlayers.add(updated);

      }
    }

    final toDelete = currentAllPlayers.where((p) => !seenNames.contains(p.name.toLowerCase())).toList();

    final batch = FirebaseFirestore.instance.batch();

    for (final player in toDelete) {
      final docId = player.name.replaceAll(' ', '_').toLowerCase();
      final docRef = FirebaseFirestore.instance.collection('players').doc(docId);
      batch.delete(docRef);
    }

    await _storage.savePlayersInBatch(newPlayers);
    await batch.commit();

    print("✅ Importazione completata. Aggiornati: ${newPlayers.length}, Rimossi: ${toDelete.length}");
  }
}
