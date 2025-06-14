import 'package:cloud_firestore/cloud_firestore.dart';
import 'match.dart';

class Round {
  final int day;
  final List<Match> matches;
  final DateTime? timestamp;
  final bool boolean;

  Round(this.day, this.matches, {this.timestamp, this.boolean = false});

  factory Round.fromMap(Map<String, dynamic> map) {
    return Round(
      map['day'],
      (map['matches'] as List<dynamic>)
          .map((m) => Match.fromMap(m))
          .toList(),
      timestamp: map['timestamp'] != null
          ? (map['timestamp'] as Timestamp).toDate()
          : null,
      boolean: map['boolean'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'day': day,
      'matches': matches.map((m) => m.toMap()).toList(),
      if (timestamp != null) 'timestamp': timestamp,
      'boolean': boolean,
    };
  }
}
