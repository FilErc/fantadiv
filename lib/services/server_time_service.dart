import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tzdata;

class ServerTimeService {
  static bool _initialized = false;
  static DateTime? _cachedServerTime;

  static Future<DateTime?> fetchServerTime() async {
    try {
      if (_cachedServerTime != null) return _cachedServerTime;

      if (!_initialized) {
        tzdata.initializeTimeZones();
        _initialized = true;
      }

      final docRef = FirebaseFirestore.instance.collection('serverTime').doc('sync');
      await docRef.set({'ts': FieldValue.serverTimestamp()});

      final snapshot = await docRef.get(const GetOptions(source: Source.server));
      final serverTimestamp = snapshot.data()?['ts'] as Timestamp?;

      if (serverTimestamp == null) return null;

      final utc = serverTimestamp.toDate();
      final location = tz.getLocation('Europe/Rome');
      final romeTime = tz.TZDateTime.from(utc, location);

      _cachedServerTime = romeTime;
      return romeTime;
    } catch (e) {
      print("Errore nel recuperare l'orario dal server Firestore: $e");
      return null;
    }
  }
}
