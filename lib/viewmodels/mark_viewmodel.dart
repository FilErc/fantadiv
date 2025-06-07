import 'package:fantadiv/services/convertio_service.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:excel/excel.dart';
import 'file_picker_viewmodel.dart';
import '../db/firebase_util_storage.dart';
import '../models/players.dart';

class MarkViewModel extends ChangeNotifier {
  int _currentGiornata = 1;
  bool isLoading = false;
  final FirebaseUtilStorage _storage = FirebaseUtilStorage();
  FilePickerViewModel? filePicker;

  void init(FilePickerViewModel filePicker) {
    this.filePicker = filePicker;
  }

  void startAutoImport() {
    isLoading = true;
    notifyListeners();
    _importNext();
  }

  void _importNext() async {
    if (_currentGiornata > 38) {
      print("🎉 Completato");
      await _saveAllPlayersToFirestore();
      isLoading = false;
      notifyListeners();
      return;
    }

    final url =
        'https://www.pianetafanta.it/voti-ufficiosi-excel.asp?giornataScelta=$_currentGiornata&searchBonus=';

    print('⬇️ Scarico giornata $_currentGiornata: $url');

    try {
      final response = await http.get(Uri.parse(url));
      final tempDir = await getTemporaryDirectory();
      final xlsFile = File('${tempDir.path}/giornata$_currentGiornata.xls');
      await xlsFile.writeAsBytes(response.bodyBytes);

      final convertedFile = await ConvertioService.convertXlsToXlsx(xlsFile);
      if (convertedFile != null) {
        final bytes = convertedFile.readAsBytesSync();
        final excel = Excel.decodeBytes(bytes);

        for (var table in excel.tables.keys) {
          final rows = excel.tables[table]!.rows;
          for (int i = 0; i < rows.length; i++) {
            final row = rows[i];
            final values = row.map((e) => e?.value.toString().trim() ?? '').toList();

            if (values.length < 10 && i + 2 < rows.length) {
              final line2 = excel.tables[table]!.rows[i + 1]
                  .map((e) => e?.value.toString().trim() ?? '').toList();
              values.insertAll(0, line2);
              values.insertAll(0, row.map((e) => e?.value.toString().trim() ?? ''));
              i += 2;
            }

            if (values.length < 35) continue;
            if (values[1].toUpperCase().startsWith("ALL")) continue;

            final name = values[1].replaceAll(RegExp(r'\s+'), ' ').trim();
            final team = values[4];

            final player = _findPlayer(name, team);
            if (player == null) {
              print("❌ Giocatore non trovato: $name ($team)");
              continue;
            }

            final giornataIndex = _currentGiornata - 1;
            player.statsGrid ??= List.generate(38, (_) => {});

            player.statsGrid![giornataIndex] = {
              'GF': int.tryParse(values[6]) ?? 0,
              'GS': int.tryParse(values[7]) ?? 0,
              'Aut': int.tryParse(values[8]) ?? 0,
              'Ass': int.tryParse(values[9]) ?? 0,
              'Amm': int.tryParse(values[18]) ?? 0,
              'Esp': int.tryParse(values[19]) ?? 0,
              'Gdv': int.tryParse(values[20]) ?? 0,
              'Gdp': int.tryParse(values[21]) ?? 0,
              'RigS': int.tryParse(values[22]) ?? 0,
              'RigP': int.tryParse(values[23]) ?? 0,
              'Rt': int.tryParse(values[24]) ?? 0,
              'Rs': int.tryParse(values[25]) ?? 0,
              'T': int.tryParse(values[26]) ?? 0,
              'VG': double.tryParse(values[30].replaceAll(',', '.')) ?? 0.0,
              'VC': double.tryParse(values[31].replaceAll(',', '.')) ?? 0.0,
              'VTS': double.tryParse(values[32].replaceAll(',', '.')) ?? 0.0,
            };
          }
        }
      } else {
        print("⚠️ Conversione fallita per giornata $_currentGiornata");
      }
    } catch (e) {
      print("❌ Errore giornata $_currentGiornata: $e");
    }

    _currentGiornata++;
    await Future.delayed(const Duration(milliseconds: 300));
    _importNext();
  }

  Future<void> _saveAllPlayersToFirestore() async {
    if (filePicker == null) return;
    for (final player in filePicker!.allPlayers) {
      try {
        await _storage.savePlayer(player);
        print("✅ Salvato su Firestore: ${player.name}");
      } catch (e) {
        print("❌ Errore salvataggio ${player.name}: $e");
      }
    }
  }

  Players? _findPlayer(String name, String team) {
    if (filePicker == null) return null;
    final lower = name.toLowerCase();
    try {
      return filePicker!.allPlayers.firstWhere(
            (p) => (p.name.toLowerCase().contains(lower) ||
            p.alias.any((alias) => alias.toLowerCase().contains(lower))) &&
            p.team.toLowerCase() == team.toLowerCase(),
      );
    } catch (_) {
      return null;
    }
  }
}
