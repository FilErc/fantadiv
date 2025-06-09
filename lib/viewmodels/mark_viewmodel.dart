import 'package:fantadiv/services/convertio_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:excel/excel.dart';
import 'file_picker_viewmodel.dart';
import '../db/firebase_util_storage.dart';
import '../models/players.dart';

class MarkViewModel extends ChangeNotifier {
  int _currentGiornata = 1;
  bool isLoading = false;
  final FirebaseUtilStorage _storage = FirebaseUtilStorage();
  final FilePickerViewModel _filepicker;
  MarkViewModel(this._filepicker);

  bool _shouldPause = false;
  void pauseLoop() => _shouldPause = true;
  void resumeLoop() => _shouldPause = false;

  Future<void> startAutoImport({
    required Future<Players?> Function(String name) onPlayerNotFound,
  }) async {
    isLoading = true;
    notifyListeners();
    await _importNext(onPlayerNotFound);
    isLoading = false;
    notifyListeners();
  }

  Future<void> _importNext(
      Future<Players?> Function(String name) onPlayerNotFound,
      ) async {
    if (_currentGiornata > 38) {
      print("🎉 Completato");
      await _saveAllPlayersToFirestore();
      return;
    }

    final file = await ConvertioService.scaricaConvertiERiformatta(_currentGiornata);
    if (file != null) {
      final excel = Excel.decodeBytes(await file.readAsBytes());
      for (var table in excel.tables.keys) {
        final rows = excel.tables[table]!.rows;
        for (int i = 0; i < rows.length; i++) {
          final row = rows[i];
          final values = row.map((e) => e?.value.toString().trim() ?? '').toList();
          print(values);
          if (values.isEmpty) continue;

          final rawValue = values[0].split(" ");
          final parsed = num.tryParse(rawValue[0]);
          if (parsed == null) continue;

          final result = extractNameAndTeam(values[0]);
          final name = result['name']!;
          final team = result['team']!;
          final index = int.tryParse(result['index']!);

          Players? player = _findPlayer(name, team);
          print(player?.alias);

          if (player == null) {
            _shouldPause = true;
            player = await onPlayerNotFound(name);
            _shouldPause = false;
          }

          if (player == null) continue;

          final giornataIndex = _currentGiornata - 1;
          final lastIndex = rawValue.length - 1;
          final vg = double.tryParse(rawValue[lastIndex].replaceAll(',', '.')) ?? 0.0;
          final vc = double.tryParse(rawValue[lastIndex - 1].replaceAll(',', '.')) ?? 0.0;
          final vts = double.tryParse(rawValue[lastIndex - 2].replaceAll(',', '.')) ?? 0.0;
          player.statsGrid ??= List.generate(38, (_) => {});
          player.statsGrid![giornataIndex] = {
            'GF': int.tryParse(rawValue[index! + 1]) ?? 0,
            'GS': int.tryParse(rawValue[index + 2]) ?? 0,
            'Aut': int.tryParse(rawValue[index + 3]) ?? 0,
            'Ass': int.tryParse(rawValue[index + 4]) ?? 0,
            'Amm': int.tryParse(rawValue[index + 13]) ?? 0,
            'Esp': int.tryParse(rawValue[index + 14]) ?? 0,
            'Gdv': int.tryParse(rawValue[index + 15]) ?? 0,
            'Gdp': int.tryParse(rawValue[index + 16]) ?? 0,
            'RigS': int.tryParse(rawValue[index + 17]) ?? 0,
            'RigP': int.tryParse(rawValue[index + 18]) ?? 0,
            'Rt': int.tryParse(rawValue[index + 19]) ?? 0,
            'Rs': int.tryParse(rawValue[index + 20]) ?? 0,
            'T': int.tryParse(rawValue[index + 21]) ?? 0,
            'VG': vg,
            'VC': vc,
            'VTS': vts,
          };
          while (_shouldPause) {
            await Future.delayed(const Duration(milliseconds: 100));
          }
        }
      }
    } else {
      print("⚠️ Conversione fallita per giornata $_currentGiornata");
    }

    _currentGiornata++;
    await Future.delayed(const Duration(milliseconds: 300));
    await _importNext(onPlayerNotFound);
  }

  Future<void> _saveAllPlayersToFirestore() async {
    await _storage.savePlayersInBatch(_filepicker.allPlayers);
  }

  Players? _findPlayer(String name, String team) {
    final lower = name.toLowerCase();
    try {
      return allPlayers.firstWhere(
              (p) {
            final nameMatch = p.name.toLowerCase().contains(lower);
            final aliasMatch = p.alias.any((alias) => alias.trim().toLowerCase().contains(lower));
            //final teamMatch = p.team.toLowerCase() == team.toLowerCase();
            return (nameMatch || aliasMatch);
          },);
    } catch (_) {
      return null;
    }
  }

  List<Players> get allPlayers => _filepicker.allPlayers;

  Map<String, String> extractNameAndTeam(String fullString) {
    final tokens = fullString
        .split(' ')
        .where((element) => element.trim().isNotEmpty)
        .toList();

    int index = 1;
    StringBuffer nameBuffer = StringBuffer();
    int teamIndex = 0;

    while (index < tokens.length) {
      final token = tokens[index];

      if (token.contains('.')) {
        teamIndex = index + 3;
      } else if (token.length == 1) {
        teamIndex = index + 2;
      }


      if (token.contains('.') || token.length == 1) {
        break;
      }

      nameBuffer.write('$token ');
      index++;
    }

    final name = nameBuffer.toString().trim();
    final team = teamIndex < tokens.length ? tokens[teamIndex] : '';

    return {
      'name': name,
      'team': team,
      'index': teamIndex.toString(),
    };
  }
}
