import 'players.dart';

class Match {
  final String team1;
  final String team2;
  final int gT1; //gol team1
  final int gT2; //gol team2
  final int sT1; //punteggio team1
  final int sT2; //punteggio team2
  final List<Players> pT1; //formazione team1
  final List<Players> pT2; //formazione team2

  Match(this.team1, this.team2, {this.gT1 = 0, this.gT2 = 0, this.pT1 = const [], this.pT2 = const [], this.sT1 = 0, this.sT2 = 0});
}

class Round {
  final int day;
  final List<Match> matches;

  Round(this.day, this.matches);
}