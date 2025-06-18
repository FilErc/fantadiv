import 'package:flutter/material.dart';
import '../models/match.dart';

class MatchDetailsPage extends StatelessWidget {
  final Match match;

  const MatchDetailsPage({super.key, required this.match});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Dettagli Match"),
        backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "${match.team1} vs ${match.team2}",
              style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Text("Gol ${match.team1}: ${match.gT1}", style: const TextStyle(color: Colors.white, fontSize: 18)),
            Text("Gol ${match.team2}: ${match.gT2}", style: const TextStyle(color: Colors.white, fontSize: 18)),
            const SizedBox(height: 12),
            Text("Somma voti ${match.team1}: ${match.sT1}", style: const TextStyle(color: Colors.white70, fontSize: 16)),
            Text("Somma voti ${match.team2}: ${match.sT2}", style: const TextStyle(color: Colors.white70, fontSize: 16)),
            const SizedBox(height: 20),
            Text("Titolari ${match.team1}:", style: const TextStyle(color: Colors.amber, fontSize: 16)),
            ...match.pT1.map((name) => Text(name, style: const TextStyle(color: Colors.white))),
            const SizedBox(height: 12),
            Text("Titolari ${match.team2}:", style: const TextStyle(color: Colors.amber, fontSize: 16)),
            ...match.pT2.map((name) => Text(name, style: const TextStyle(color: Colors.white))),
          ],
        ),
      ),
    );
  }
}
