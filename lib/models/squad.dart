import 'package:cloud_firestore/cloud_firestore.dart';

class Squad {
  final String id;
  final String teamName;
  final String owner;
  final DateTime createdAt;
  final List<DocumentReference>? reference;

  Squad({
    required this.id,
    required this.teamName,
    required this.owner,
    required this.createdAt,
    this.reference,
  });

  Map<String, dynamic> toMap() {
    return {
      'teamName': teamName,
      'owner': owner,
      'createdAt': createdAt,
      'reference': reference?.map((ref) => ref.path).toList(),
    };
  }

  factory Squad.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return Squad(
      id: doc.id,
      teamName: data['teamName'] ?? '',
      owner: data['owner'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      reference: data['reference'] != null
          ? (data['reference'] as List).map((path) => FirebaseFirestore.instance.doc(path)).toList()
          : null,
    );
  }
}
