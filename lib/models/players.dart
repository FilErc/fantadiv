class Players {
  final String name;
  final String position;
  final String team;
  final List<String>? alias;
  final List<List<int>>? statsGrid;
  final int? goals;
  final int? assists;
  final int? yellowCards;
  final int? redCards;

  Players({
    required this.name,
    required this.position,
    required this.team,
    required this.alias,
    this.statsGrid,
    this.goals,
    this.assists,
    this.yellowCards,
    this.redCards,
  });

  factory Players.fromMap(Map<String, dynamic> data) {
    return Players(
      name: data['name'] ?? 'Unknown',
      position: data['position'] ?? 'Unknown',
      team: data['team'] ?? 'Unknown',
      alias: data['alias'] != null ? List<String>.from(data['alias']) : [],
      statsGrid: data['statsGrid'] != null
          ? List<List<int>>.from(
        (data['statsGrid'] as List).map(
              (row) => List<int>.from(row),
        ),
      )
          : null,
      goals: data['goals'],
      assists: data['assists'],
      yellowCards: data['yellowCards'],
      redCards: data['redCards'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'position': position,
      'team': team,
      'alias': alias,
      'statsGrid': statsGrid,
      'goals': goals,
      'assists': assists,
      'yellowCards': yellowCards,
      'redCards': redCards,
    };
  }
}
