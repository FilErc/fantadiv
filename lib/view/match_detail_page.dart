import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/match.dart';
import '../models/players.dart';
import '../viewmodels/file_picker_viewmodel.dart';
import '../viewmodels/match_details_viewmodel.dart';

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
            padding: const EdgeInsets.all(16),
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
                const SizedBox(height: 20),
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
                              ...matchVM.startersTeam1.map((player) => _buildPlayerBox(player, giornataIndex)),
                              const SizedBox(height: 12),
                              const Center(child: Text("Panchina", style: TextStyle(color: Colors.redAccent))),
                              const SizedBox(height: 6),
                              ...matchVM.benchTeam1.map((player) => _buildPlayerBox(player, giornataIndex, isBench: true)),
                            ],
                          ),
                        ),
                      ),
                      const VerticalDivider(color: Colors.white54, width: 32),
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
                              ...matchVM.startersTeam2.map((player) => _buildPlayerBox(player, giornataIndex, alignRight: true)),
                              const SizedBox(height: 12),
                              const Center(child: Text("Panchina", style: TextStyle(color: Colors.redAccent))),
                              const SizedBox(height: 6),
                              ...matchVM.benchTeam2.map((player) => _buildPlayerBox(player, giornataIndex, isBench: true, alignRight: true)),
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

  Widget _buildPlayerBox(Players player, int index, {bool isBench = false, bool alignRight = false}) {
    final Map<String, dynamic>? stats = (player.statsGrid != null && player.statsGrid!.length > index)
        ? player.statsGrid![index]
        : null;

    final voteTextStyle = const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold);
    final labelStyle = const TextStyle(color: Colors.grey, fontSize: 10);

    final nameWidget = Text(
      player.name,
      textAlign: alignRight ? TextAlign.right : TextAlign.left,
      style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold),
    );

    // Team 1 order: VG, VC, VTS
    final leftStatsWidgets = [
      _buildStatColumn("VG", stats?['VG'], voteTextStyle, labelStyle),
      const SizedBox(width: 8),
      _buildStatColumn("VC", stats?['VC'], voteTextStyle, labelStyle),
      const SizedBox(width: 8),
      _buildStatColumn("VTS", stats?['VTS'], voteTextStyle, labelStyle),
    ];

    // Team 2 order: VTS, VC, VG
    final rightStatsWidgets = [
      _buildStatColumn("VTS", stats?['VTS'], voteTextStyle, labelStyle),
      const SizedBox(width: 8),
      _buildStatColumn("VC", stats?['VC'], voteTextStyle, labelStyle),
      const SizedBox(width: 8),
      _buildStatColumn("VG", stats?['VG'], voteTextStyle, labelStyle),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          color: isBench ? Colors.grey[850] : Colors.grey[900],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: alignRight
              ? [...rightStatsWidgets, const SizedBox(width: 12), Expanded(child: Align(alignment: Alignment.centerRight, child: nameWidget))]
              : [Expanded(child: Align(alignment: Alignment.centerLeft, child: nameWidget)), const SizedBox(width: 12), ...leftStatsWidgets],
        ),
      ),
    );
  }

  Widget _buildStatColumn(String label, dynamic value, TextStyle voteStyle, TextStyle labelStyle) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: labelStyle),
        const SizedBox(height: 4),
        Text(value != null ? value.toString() : "-", style: voteStyle),
      ],
    );
  }
}
