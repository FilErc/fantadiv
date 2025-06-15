import 'package:cloud_firestore/cloud_firestore.dart';

class Squad {
  final String id;
  final String teamName;
  final String owner;
  final DateTime createdAt;
  final Map<DocumentReference, int>? referenceWithPrice;


  Squad({
    required this.id,
    required this.teamName,
    required this.owner,
    required this.createdAt,
    this.referenceWithPrice,
  });

  Map<String, dynamic> toMap() {
    return {
      'teamName': teamName,
      'owner': owner,
      'createdAt': createdAt,
      'referenceWithPrice': referenceWithPrice?.map((ref, price) => MapEntry(ref.path, price)),
    };
  }

  factory Squad.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final rawMap = data['referenceWithPrice'] as Map<String, dynamic>?;

    return Squad(
      id: doc.id,
      teamName: data['teamName'] ?? '',
      owner: data['owner'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      referenceWithPrice: rawMap?.map((path, price) => MapEntry(
        FirebaseFirestore.instance.doc(path),
        price is int ? price : int.tryParse(price.toString()) ?? 0,
      )),
    );
  }
}
