import 'package:flutter/material.dart';
import '../../models/players.dart';

class PlayerDetailPage extends StatelessWidget {
  final Players player;

  const PlayerDetailPage({super.key, required this.player});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(player.name),
        backgroundColor: Colors.amber,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _infoTile('Nome', player.name),
            _infoTile('Squadra', player.team),
            _infoTile('Ruolo', _label(player.position)),
            const SizedBox(height: 16),
            const Divider(thickness: 1.5),
            const SizedBox(height: 8),
            Text('Alias:', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            ...player.alias.map((a) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text('• $a', style: const TextStyle(color: Colors.white70)),
            )),
            const SizedBox(height: 20),
            if (player.statsGrid != null && player.statsGrid!.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(thickness: 1.5),
                  const SizedBox(height: 8),
                  Text('Statistiche:', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  _buildStatsTable(player.statsGrid!),
                ],
              )
            else
              const Text('Nessuna statistica disponibile', style: TextStyle(color: Colors.white54)),
          ],
        ),
      ),
    );
  }

  Widget _infoTile(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 16))),
        ],
      ),
    );
  }

  Widget _buildStatsTable(List<Map<String, dynamic>> grid) {
    final headers = grid.first.keys.toList();

    return Table(
      border: TableBorder.all(color: Colors.amber),
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      children: [
        TableRow(
          decoration: const BoxDecoration(color: Colors.amber),
          children: headers.map((h) => Padding(
            padding: const EdgeInsets.all(6),
            child: Text(h, style: const TextStyle(fontWeight: FontWeight.bold)),
          )).toList(),
        ),
        ...grid.map((row) {
          return TableRow(
            children: headers.map((key) {
              return Padding(
                padding: const EdgeInsets.all(6),
                child: Text(row[key].toString()),
              );
            }).toList(),
          );
        }),
      ],
    );
  }

  String _label(String code) {
    switch (code) {
      case 'A': return 'Attaccante';
      case 'C': return 'Centrocampista';
      case 'D': return 'Difensore';
      case 'P': return 'Portiere';
      default: return code;
    }
  }
}
