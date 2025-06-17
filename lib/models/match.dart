class Match {
  final String team1;
  final String team2;
  final int gT1;
  final int gT2;
  final int sT1;
  final int sT2;
  late List<String> pT1;
  late List<String> pT2;

  Match(
      this.team1,
      this.team2, {
        this.gT1 = 0,
        this.gT2 = 0,
        this.sT1 = 0,
        this.sT2 = 0,
        this.pT1 = const [],
        this.pT2 = const [],
      });

  factory Match.fromMap(Map<String, dynamic> map) {
    return Match(
      map['team1'],
      map['team2'],
      gT1: map['gT1'] ?? 0,
      gT2: map['gT2'] ?? 0,
      sT1: map['sT1'] ?? 0,
      sT2: map['sT2'] ?? 0,
      pT1: List<String>.from(map['pT1'] ?? []),
      pT2: List<String>.from(map['pT2'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'team1': team1,
      'team2': team2,
      'gT1': gT1,
      'gT2': gT2,
      'sT1': sT1,
      'sT2': sT2,
      'pT1': pT1,
      'pT2': pT2,
    };
  }
}
