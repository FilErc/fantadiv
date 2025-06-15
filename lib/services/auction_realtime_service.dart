import 'package:firebase_database/firebase_database.dart';

class AuctionRealtimeService {
  final DatabaseReference _auctionRef = FirebaseDatabase.instance.ref('auction');

  Stream<DatabaseEvent> watchSlot(String slotId) {
    return _auctionRef.child(slotId).onValue;
  }

  Future<void> setPlayer({
    required String slotId,
    required String role,
    required int index,
    required String name,
    required int price,
  }) async {
    final ref = _auctionRef.child('$slotId/role/$role/$index');
    await ref.set({
      'name': name,
      'price': price,
    });
  }

  Future<void> setSquad(String slotId, String squadName) async {
    await _auctionRef.child('$slotId/squad').set(squadName);
  }

  Future<Map<String, dynamic>> fetchAllAuctionData() async {
    final snapshot = await _auctionRef.get();
    if (snapshot.exists) {
      return Map<String, dynamic>.from(snapshot.value as Map);
    }
    return {};
  }

  Future<void> clearPlayer(String slotId, String role, int index) async {
    await _auctionRef.child('$slotId/role/$role/$index').remove();
  }

  Future<void> clearSlot(String slotId) async {
    await _auctionRef.child(slotId).remove();
  }
}
