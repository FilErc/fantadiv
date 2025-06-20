import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/match.dart';
import '../models/players.dart';
import '../viewmodels/file_picker_viewmodel.dart';
import '../viewmodels/match_details_viewmodel.dart';

final Map<String, List<String>> statIcons = {
  'GF': ['⚽', 'Goal'],
  'Ass': ['🎯', 'Assist'],
  'RigTrasf': ['🥅', 'Rigore Segnato'],
  'RigSbagliato': ['❌', 'Rigore Sbagliato'],
  'Esp': ['🟥', 'Espulsione'],
  'Amm': ['🟨', 'Ammonizione'],
  'GS': ['⛳', 'Goal Subito'],
  'RigP': ['🥊', 'Rigore Parato'],
  'Aut': ['🔴', 'Autogol'],
  'RigS': ['⚽', 'Rigore Segnato'],
};

class MatchDetailsPage extends StatelessWidget {
  final Match match;
  final int day;

  const MatchDetailsPage({super.key, required this.match, required this.day});

  @override
  Widget build(BuildContext context) {
    return Consumer<FilePickerViewModel>(
      builder: (context, fileVM, _) {
        final allPlayers = fileVM.allPlayers;
        final giornataIndex = day - 1;
        final matchVM = MatchDetailsViewModel(match: match, allPlayers: allPlayers);

        return Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.amber,
            title: const Text("Dettagli Match", style: TextStyle(color: Colors.black)),
            centerTitle: true,
          ),
          body: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Center(
                        child: Text(
                          match.team1,
                          style: const TextStyle(color: Colors.amber, fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const Text("VS", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    Expanded(
                      child: Center(
                        child: Text(
                          match.team2,
                          style: const TextStyle(color: Colors.amber, fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Gol: ${match.gT1}", style: const TextStyle(color: Colors.white)),
                              Text("Somma voti: ${match.sT1}", style: const TextStyle(color: Colors.white70)),
                              const SizedBox(height: 12),
                              const Center(child: Text("Titolari", style: TextStyle(color: Colors.greenAccent))),
                              const SizedBox(height: 6),
                              ...matchVM.startersTeam1.map((player) => _buildPlayerBox(player, giornataIndex, matchVM)),
                              const SizedBox(height: 12),
                              const Center(child: Text("Panchina", style: TextStyle(color: Colors.redAccent))),
                              const SizedBox(height: 6),
                              ...matchVM.benchTeam1.map((player) => _buildPlayerBox(player, giornataIndex, matchVM, isBench: true)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(width: 1, color: Colors.white30),
                      const SizedBox(width: 6),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text("Gol: ${match.gT2}", style: const TextStyle(color: Colors.white)),
                              Text("Somma voti: ${match.sT2}", style: const TextStyle(color: Colors.white70)),
                              const SizedBox(height: 12),
                              const Center(child: Text("Titolari", style: TextStyle(color: Colors.greenAccent))),
                              const SizedBox(height: 6),
                              ...matchVM.startersTeam2.map((player) => _buildPlayerBox(player, giornataIndex, matchVM, alignRight: true)),
                              const SizedBox(height: 12),
                              const Center(child: Text("Panchina", style: TextStyle(color: Colors.redAccent))),
                              const SizedBox(height: 6),
                              ...matchVM.benchTeam2.map((player) => _buildPlayerBox(player, giornataIndex, matchVM, isBench: true, alignRight: true)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPlayerBox(
      Players player,
      int index,
      MatchDetailsViewModel matchVM, {
        bool isBench = false,
        bool alignRight = false,
      }) {
    final Map<String, dynamic>? stats = (player.statsGrid != null && player.statsGrid!.length > index)
        ? player.statsGrid![index]
        : null;

    final voteTextStyle = const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold);
    final labelStyle = const TextStyle(color: Colors.grey, fontSize: 10);

    final nameText = Text(
      player.name,
      overflow: TextOverflow.ellipsis,
      textAlign: alignRight ? TextAlign.right : TextAlign.left,
      style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold),
    );

    final positionBadge = Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _color(player.position),
      ),
      alignment: Alignment.center,
      child: Text(
        player.position,
        style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 12),
      ),
    );

    final emojiLine = _buildBonusEmojiLine(stats);

    final nameWithBadge = Column(
      crossAxisAlignment: alignRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: alignRight
              ? [Expanded(child: nameText), const SizedBox(width: 6), positionBadge]
              : [positionBadge, const SizedBox(width: 6), Expanded(child: nameText)],
        ),
        if (emojiLine.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              emojiLine,
              textAlign: alignRight ? TextAlign.right : TextAlign.left,
              style: const TextStyle(fontSize: 14),
            ),
          ),
      ],
    );

    final leftStatsWidgets = [
      _buildStatColumn("VG", stats?['VG'], matchVM.calculateFantaVoto(stats, stats?['VG']), voteTextStyle, labelStyle),
      const SizedBox(width: 6),
      _buildStatColumn("VC", stats?['VC'], matchVM.calculateFantaVoto(stats, stats?['VC']), voteTextStyle, labelStyle),
      const SizedBox(width: 6),
      _buildStatColumn("VTS", stats?['VTS'], matchVM.calculateFantaVoto(stats, stats?['VTS']), voteTextStyle, labelStyle),
    ];

    final rightStatsWidgets = [
      _buildStatColumn("VTS", stats?['VTS'], matchVM.calculateFantaVoto(stats, stats?['VTS']), voteTextStyle, labelStyle),
      const SizedBox(width: 6),
      _buildStatColumn("VC", stats?['VC'], matchVM.calculateFantaVoto(stats, stats?['VC']), voteTextStyle, labelStyle),
      const SizedBox(width: 6),
      _buildStatColumn("VG", stats?['VG'], matchVM.calculateFantaVoto(stats, stats?['VG']), voteTextStyle, labelStyle),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
        decoration: BoxDecoration(
          color: isBench ? Colors.grey[850] : Colors.grey[900],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: alignRight
              ? [...rightStatsWidgets, const SizedBox(width: 6), Expanded(child: nameWithBadge)]
              : [Expanded(child: nameWithBadge), const SizedBox(width: 6), ...leftStatsWidgets],
        ),
      ),
    );
  }

  String _buildBonusEmojiLine(Map<String, dynamic>? stats) {
    if (stats == null) return '';

    final buffer = StringBuffer();

    statIcons.forEach((key, value) {
      final emoji = value[0];
      final count = (stats[key] ?? 0);
      if (count is int && count > 0) {
        buffer.write(emoji * count);
      }
    });

    return buffer.toString();
  }

  Widget _buildStatColumn(String label, dynamic value, String fantavoto, TextStyle voteStyle, TextStyle labelStyle) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: labelStyle),
        const SizedBox(height: 2),
        Text(value != null ? value.toString() : "-", style: voteStyle),
        const SizedBox(height: 2),
        Text(fantavoto.isNotEmpty ? fantavoto : "-", style: voteStyle),
      ],
    );
  }

  Color _color(String code) {
    switch (code) {
      case 'A':
        return Colors.red;
      case 'C':
        return Colors.lightBlue;
      case 'D':
        return Colors.green;
      case 'P':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}
