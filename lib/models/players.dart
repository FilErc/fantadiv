class Players {
  final String name;
  final String position;
  final String team;
  final List<String> alias;
  List<Map<String, dynamic>>? statsGrid;

  Players({
    required this.name,
    required this.position,
    required this.team,
    required this.alias,
    this.statsGrid,
  });

  factory Players.fromMap(Map<String, dynamic> data) {
    return Players(
      name: data['name'] ?? 'Unknown',
      position: data['position'] ?? 'Unknown',
      team: data['team'] ?? 'Unknown',
      alias: data['alias'] != null ? List<String>.from(data['alias']) : [],
      statsGrid: data['statsGrid'] != null
          ? List<Map<String, dynamic>>.from(
          (data['statsGrid'] as List).map((row) => Map<String, dynamic>.from(row)))
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'position': position,
      'team': team,
      'alias': alias,
      'statsGrid': statsGrid,
    };
  }
}
