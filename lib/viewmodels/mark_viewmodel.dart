import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html_parser;
import '../models/players.dart';
import 'package:fantadiv/viewmodels/file_picker_viewmodel.dart';

class MarkViewModel extends ChangeNotifier {
  bool isLoading = false;
  int giornata = 0;
  final FilePickerViewModel fViewmodel = FilePickerViewModel();

  final Map<String, Players> _playersToUpdate = {}; // Salvataggio locale

  double? parseVoto(String raw) {
    final cleaned = raw.trim().toUpperCase();
    if (cleaned == 'SV') return null;
    return double.tryParse(cleaned);
  }

  Future<void> fetchAndStoreFromPianetaFanta() async {
    if (kIsWeb || !Platform.isAndroid) {
      debugPrint("❌ Operazione supportata solo su Android");
      return;
    }

    isLoading = true;
    notifyListeners();

    try {
      final url = 'https://www.pianetafanta.it/voti-ufficiali.asp';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode != 200) {
        debugPrint("❌ Errore HTTP: ${response.statusCode}");
        return;
      }

      final document = html_parser.parse(response.body);
      final tableRows = document.querySelectorAll("table tr");

      for (final row in tableRows) {
        final cells = row.querySelectorAll("td");
        if (cells.length >= 9) {
          final ruolo = cells[0].text.trim();
          final nome = cells[1].text.trim();
          final votoFp = parseVoto(cells[2].text);
          final votoGds = parseVoto(cells[6].text);
          final votoCds = parseVoto(cells[8].text);

          final player = fViewmodel.findPlayerInAnyRole(nome);
          if (player == null) {
            debugPrint('❌ Giocatore non trovato: $nome ($ruolo)');
            continue;
          }

          List<Map<String, dynamic>> stats = player.statsGrid != null
              ? player.statsGrid!.map((r) => {...r}).toList()
              : List.generate(38, (_) => {
            'fp': null, 'gds': null, 'cds': null,
            'gol': 0.0, 'ass': 0.0, 'aut': 0.0,
            'amm': 0.0, 'esp': 0.0, 'rig': 0.0,
            'rigS': 0.0, 'rigPar': 0.0, 'rigSB': 0.0,
            'golSubiti': 0.0, 'pi': 0.0,
          });

          if (votoFp != null) stats[giornata]['fp'] = votoFp;
          if (votoGds != null) stats[giornata]['gds'] = votoGds;
          if (votoCds != null) stats[giornata]['cds'] = votoCds;

          // Applica bonus UNA sola volta per tipo per riga
          final icons = row.querySelectorAll('.imgBonus');
          final Set<String> bonusApplicati = {};

          for (final icon in icons) {
            final className = icon.className;

            void increment(String key) {
              if (!bonusApplicati.contains(key)) {
                stats[giornata][key] = (stats[giornata][key] ?? 0.0) + 1.0;
                bonusApplicati.add(key);
              }
            }

            if (className.contains('imgBonus_golFa') || className.contains('imgBonus_rigFa')) {
              increment('gol');
              increment('rig');
            } else if (className.contains('imgBonus_golSu')) {
              increment('golSubiti');
            } else if (className.contains('imgBonus_rigPa')) {
              increment('rigPar');
            } else if (className.contains('imgBonus_rigSb')) {
              increment('rigSB');
              increment('rig');
            } else if (className.contains('imgBonus_aut')) {
              increment('aut');
            } else if (className.contains('imgBonus_ass')) {
              increment('ass');
            } else if (className.contains('imgBonus_amm')) {
              increment('amm');
            } else if (className.contains('imgBonus_esp')) {
              increment('esp');
            } else if (className.contains('imgBonus_pi')) {
              increment('pi');
            }
          }
          _playersToUpdate[player.name] = player;
        }
      }

      debugPrint("✅ Giocatori aggiornati localmente: ${_playersToUpdate.length}");
    } catch (e, stack) {
      debugPrint('❌ Errore durante il parsing: $e');
      debugPrint(stack.toString());
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
