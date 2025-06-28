import 'dart:async';

import 'package:fantadiv/services/convertio_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:excel/excel.dart';
import 'listone_display_viewmodel.dart';
import '../db/firebase_util_storage.dart';
import '../models/players.dart';

class MarkViewModel extends ChangeNotifier {
  bool isLoading = false;
  final FirebaseUtilStorage _storage = FirebaseUtilStorage();
  final ListoneDisplayViewModel _filepicker;

  MarkViewModel(this._filepicker);

  Future<void> startAutoImport({
    required int giornata,
    required Future<Players?> Function(String name) onPlayerNotFound,
  }) async {
    isLoading = true;
    notifyListeners();
    await _importGiornata(giornata, onPlayerNotFound);
    isLoading = false;
    notifyListeners();
  }


  String? missingPlayerName;
  Function(Players?)? onResolvePlayer;
  bool isResolvingPlayer = false;

  Future<void> _importGiornata(
      int giornata,
      Future<Players?> Function(String name) onPlayerNotFound,
      ) async {
    final file = await ConvertioService.scaricaConvertiERiformatta(giornata);
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

          Players? player = _findPlayer(name, team);

          if (player == null) {
            missingPlayerName = name;
            isResolvingPlayer = true;
            notifyListeners();

            player = await _waitForPlayerSelection();
            isResolvingPlayer = false;
            if (player == null) continue;
          }



          final giornataIndex = giornata - 1;
          final lastIndex = rawValue.length - 1;

          final vts = double.tryParse(rawValue[lastIndex - 18].replaceAll(',', '.')) ?? 0.0;
          final vc = double.tryParse(rawValue[lastIndex - 23].replaceAll(',', '.')) ?? 0.0;
          final raw = rawValue[lastIndex - 28].replaceAll(',', '.');
          final cuttle = double.tryParse(raw) ?? 0.0;
          final vg = (cuttle * 10).truncateToDouble() / 10;
          final rS = int.tryParse(rawValue[lastIndex - 4]) ?? 0;
          final rT = int.tryParse(rawValue[lastIndex - 5]) ?? 0;
          final rigP = int.tryParse(rawValue[lastIndex - 6]) ?? 0;
          final rigS = int.tryParse(rawValue[lastIndex - 7]) ?? 0;
          final esp = int.tryParse(rawValue[lastIndex - 10]) ?? 0;
          final amm = int.tryParse(rawValue[lastIndex - 11]) ?? 0;
          final ass = int.tryParse(rawValue[lastIndex - 14]) ?? 0;
          final aut = int.tryParse(rawValue[lastIndex - 15]) ?? 0;
          final gs = int.tryParse(rawValue[lastIndex - 16]) ?? 0;
          final gf = int.tryParse(rawValue[lastIndex - 17]) ?? 0;

          player.statsGrid ??= List.generate(38, (_) => {});
          player.statsGrid![giornataIndex] = {
            'GF': gf,
            'GS': gs,
            'Aut': aut,
            'Ass': ass,
            'Amm': amm,
            'Esp': esp,
            'RigS': rigS,
            'RigP': rigP,
            'RigTrasf': rT,
            'RigSbagliato': rS,
            'VG': vg,
            'VC': vc,
            'VTS': vts,
          };
        }
      }
    } else {
      print("⚠️ Conversione fallita per giornata $giornata");
    }
    await Future.delayed(const Duration(milliseconds: 300));
    await _saveAllPlayersToFirestore();
  }

  Future<Players?> _waitForPlayerSelection() async {
    final completer = Completer<Players?>();
    onResolvePlayer = (Players? selected) {
      missingPlayerName = null;
      notifyListeners();
      completer.complete(selected);
    };
    return completer.future;
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
          final aliasMatch =
          p.alias.any((alias) => alias.trim().toLowerCase().contains(lower));
          return (nameMatch || aliasMatch);
        },
      );
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

      if (token.length == 1) {
        break;
      }
      if (token.contains('.')) {
        nameBuffer.write(token);
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
