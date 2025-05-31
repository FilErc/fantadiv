import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html_parser;
import '../models/players.dart';
import '../db/firebase_util_storage.dart';

class MarkViewModel extends ChangeNotifier {
  final FirebaseUtilStorage _firebaseUtil = FirebaseUtilStorage();
  bool isLoading = false;
  int giornata = 0;

  double? parseVoto(String raw) {
    final cleaned = raw.trim().toUpperCase();
    if (cleaned == 'SV') return null;
    return double.tryParse(cleaned);
  }

  Future<void> fetchAndStoreAllPages() async {
    isLoading = true;
    notifyListeners();

    for (int page = 685; page <= 722; page++) {
      final url = 'https://www.fantapazz.com/fantacalcio/voti-ufficiali/$page';
      debugPrint('📄 Analizzando URL: $url');

      try {
        final response = await http.get(Uri.parse(url));
        if (response.statusCode == 200) {
          final document = html_parser.parse(response.body);
          final clubCards = document.querySelectorAll('.card');

          for (var card in clubCards) {
            final squadra = card.querySelector('.nomeClub')?.text.trim() ?? 'Sconosciuta';
            final rows = card.querySelectorAll('table tbody tr');

            for (var row in rows) {
              final cells = row.querySelectorAll('td');
              if (cells.length >= 9) {
                final ruolo = cells[0].text.trim();
                final nome = cells[1].text.trim();

                final votoFantapazz = parseVoto(cells[2].text);
                final votoGds = parseVoto(cells[6].text); // ⬅️ GdS
                final votoCdS = parseVoto(cells[8].text); // ⬅️ Corriere dello Sport

                final playerDoc = await _firebaseUtil.findPlayerInAnyRole(nome);
                if (playerDoc == null) {
                  debugPrint('❌ Giocatore non trovato in nessun ruolo: $nome - $squadra');
                  continue;
                }

                final player = Players.fromMap(playerDoc.data() as Map<String, dynamic>);

                List<Map<String, dynamic>> stats = player.statsGrid != null
                    ? player.statsGrid!.map((row) {
                  return row.map((key, value) =>
                      MapEntry(key, value is num ? value.toDouble() : value));
                }).toList()
                    : List.generate(38, (_) => {
                  'fp': null,
                  'gds': null,
                  'cds': null,
                  'gol': 0.0,
                  'ass': 0.0,
                  'aut': 0.0,
                  'amm': 0.0,
                  'esp': 0.0,
                  'rig': 0.0,
                  'rigS': 0.0,
                  'rigPar': 0.0,
                  'rigSB': 0.0,
                  'golSubiti': 0.0,
                  'pi': 0.0,
                });

                if (votoFantapazz != null) stats[giornata]['fp'] = votoFantapazz;
                if (votoGds != null)       stats[giornata]['gds'] = votoGds;
                if (votoCdS != null)       stats[giornata]['cds'] = votoCdS;

                final icons = row.querySelectorAll('.imgBonus');
                for (final icon in icons) {
                  final className = icon.className;

                  if (className.contains('imgBonus_golFa') || className.contains('imgBonus_rigFa')) {
                    stats[giornata]['gol'] = (stats[giornata]['gol'] ?? 0.0) + 1.0;
                    stats[giornata]['rig'] = (stats[giornata]['rig'] ?? 0.0) + 1.0;
                  } else if (className.contains('imgBonus_golSu')) {
                    stats[giornata]['golSubiti'] = (stats[giornata]['golSubiti'] ?? 0.0) + 1.0;
                  } else if (className.contains('imgBonus_rigPa')) {
                    stats[giornata]['rigPar'] = (stats[giornata]['rigPar'] ?? 0.0) + 1.0;
                  } else if (className.contains('imgBonus_rigSb')) {
                    stats[giornata]['rigSB'] = (stats[giornata]['rigSB'] ?? 0.0) + 1.0;
                    stats[giornata]['rig'] = (stats[giornata]['rig'] ?? 0.0) + 1.0;
                  } else if (className.contains('imgBonus_aut')) {
                    stats[giornata]['aut'] = (stats[giornata]['aut'] ?? 0.0) + 1.0;
                  } else if (className.contains('imgBonus_ass')) {
                    stats[giornata]['ass'] = (stats[giornata]['ass'] ?? 0.0) + 1.0;
                  } else if (className.contains('imgBonus_amm')) {
                    stats[giornata]['amm'] = (stats[giornata]['amm'] ?? 0.0) + 1.0;
                  } else if (className.contains('imgBonus_esp')) {
                    stats[giornata]['esp'] = (stats[giornata]['esp'] ?? 0.0) + 1.0;
                  } else if (className.contains('imgBonus_pi')) {
                    stats[giornata]['pi'] = (stats[giornata]['pi'] ?? 0.0) + 1.0;
                  }
                }

                await playerDoc.reference.update({'statsGrid': stats});
              }
            }
          }

          giornata++;
        } else {
          debugPrint('❌ Errore HTTP pagina $page: ${response.statusCode}');
        }
      } catch (e) {
        debugPrint('❌ Errore caricando pagina $url: $e');
      }
    }

    isLoading = false;
    notifyListeners();
  }
}
