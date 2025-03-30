class Players {
  final String name;
  final String position;
  final String team;
  final List<String> alias;

  Players({
    required this.name,
    required this.position,
    required this.team,
    required this.alias,
  });

  // Factory method to create a Players object from Firestore data
  factory Players.fromMap(Map<String, dynamic> data) {
    return Players(
      name: data['name'] ?? 'Unknown',
      position: data['position'] ?? 'Unknown',
      team: data['team'] ?? 'Unknown',
      alias: data['alias'] != null ? List<String>.from(data['alias']) : [],
    );
  }

  // Convert Players object back to a Map for Firestore storage
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'position': position,
      'team': team,
      'alias': alias,
    };
  }
}
