import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/players.dart';
import '../models/round.dart';
import '../models/squad.dart';
import '../models/match.dart';

class FirebaseUtilStorage {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<bool> hasTeam() async {
    final String? email = _auth.currentUser?.email;
    if (email == null) return false;

    QuerySnapshot query = await _firestore
        .collection('squad')
        .where('owner', isEqualTo: email)
        .get();

    return query.docs.isNotEmpty;
  }

  Future<Squad?> getUserTeam() async {
    final String? email = _auth.currentUser?.email;
    if (email == null) return null;

    QuerySnapshot query = await _firestore
        .collection('squad')
        .where('owner', isEqualTo: email)
        .get();

    if (query.docs.isEmpty) return null;
    return Squad.fromDocument(query.docs.first);
  }

  Future<void> createTeam(String teamName) async {
    final String? email = _auth.currentUser?.email;
    if (email == null) return;

    DocumentReference newDocRef = _firestore.collection('squad').doc();
    Squad squad = Squad(
      id: newDocRef.id,
      teamName: teamName,
      owner: email,
      createdAt: DateTime.now(),
      reference: [],
    );

    await newDocRef.set(squad.toMap());
  }

  Future<void> updateTeamName(String teamId, String newName) async {
    await _firestore.collection('squad').doc(teamId).update({
      'teamName': newName,
    });
  }

  Future<void> resetPassword() async {
    final String? email = _auth.currentUser?.email;
    if (email != null) {
      await _auth.sendPasswordResetEmail(email: email);
    }
  }

  Future<List<String>> getSquads() async {
    try {
      QuerySnapshot querySnapshot = await _firestore.collection('squad').get();

      List<String> squadNames = querySnapshot.docs
          .map((doc) => doc['teamName'] as String)
          .toList();

      return squadNames;
    } catch (e) {
      print('Errore durante il recupero delle squadre: $e');
      return [];
    }
  }

  Future<void> saveRound(int i, List<Match> listOfMatch) async {
    await _firestore.collection('rounds').doc('${i + 1}').set({
      'day': i + 1,
      'matches': listOfMatch.map((match) {
        return {
          'team1': match.team1,
          'team2': match.team2,
          'gT1': match.gT1,
          'gT2': match.gT2,
          'sT1': match.sT1,
          'sT2': match.sT2,
          'pT1': match.pT1.map((p) => p.toMap()).toList(),
          'pT2': match.pT2.map((p) => p.toMap()).toList(),
        };
      }).toList(),
      'timestamp': DateTime(2030, 3, 15, 10, 30),
      'boolean': false,
    });
  }

  Future<void> saveCalendar(int selectedNumMatches) async {
    try {
      QuerySnapshot querySnapshot = await _firestore.collection('rounds').get();
      int i = 0;
      List<Round> roundsList = [];
      for (var doc in querySnapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        List<Match> matches = (data['matches'] as List<dynamic>).map((matchData) {
          return Match(
            matchData['team1'],
            matchData['team2'],
            gT1: matchData['gT1'] ?? 0,
            gT2: matchData['gT2'] ?? 0,
            sT1: matchData['sT1'] ?? 0,
            sT2: matchData['sT2'] ?? 0,
            pT1: (matchData['pT1'] as List<dynamic>?)
                ?.map((playerData) => Players.fromMap(playerData))
                .toList() ??
                [],
            pT2: (matchData['pT2'] as List<dynamic>?)
                ?.map((playerData) => Players.fromMap(playerData))
                .toList() ??
                [],
          );
        }).toList();

        roundsList.add(Round(data['day'], matches));
        i++;
      }
      int c=0;
      do{
        await _firestore.collection('rounds').doc('${i + 1}').set({
          'day': i + 1,
          'matches': roundsList[c].matches.map((match) {
            return {
              'team1': match.team1,
              'team2': match.team2,
              'gT1': match.gT1,
              'gT2': match.gT2,
              'sT1': match.sT1,
              'sT2': match.sT2,
              'pT1': match.pT1.map((p) => p.toMap()).toList(),
              'pT2': match.pT2.map((p) => p.toMap()).toList(),
            };
          }).toList(),
          'timestamp': DateTime(2030, 3, 15, 10, 30),
          'boolean': false,
        });
        c++;
        if(c == roundsList.length){
          c=0;
        }
        i++;
      }while(i<selectedNumMatches);
    } catch (e) {
      print("Error nella creazione del calendario$e");
    }
  }

  Future<List<Round>> getAllRounds() async {
    try {
      QuerySnapshot querySnapshot = await _firestore.collection('rounds').get();

      List<Round> roundsList = querySnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        List<Match> matches = (data['matches'] as List<dynamic>).map((matchData) {
          return Match(
            matchData['team1'],
            matchData['team2'],
            gT1: matchData['gT1'] ?? 0,
            gT2: matchData['gT2'] ?? 0,
            sT1: matchData['sT1'] ?? 0,
            sT2: matchData['sT2'] ?? 0,
            pT1: (matchData['pT1'] as List<dynamic>?)
                ?.map((playerData) => Players.fromMap(playerData))
                .toList() ??
                [],
            pT2: (matchData['pT2'] as List<dynamic>?)
                ?.map((playerData) => Players.fromMap(playerData))
                .toList() ??
                [],
          );
        }).toList();
        return Round(
          data['day'],
          matches,
          timestamp: data['timestamp'] != null
              ? (data['timestamp'] as Timestamp).toDate()
              : null,
          boolean: data['boolean'] ?? false,
        );
      }).toList();
      roundsList.sort((a, b) => a.day.compareTo(b.day));
      return roundsList;
    } catch (e) {
      print('Errore durante il recupero dei round: $e');
      return [];
    }
  }

  Future<void> storePlayers(List<String> line) async {
    if (line.isNotEmpty && int.tryParse(line[0]) != null) {
      final playerId = line[3].replaceAll(' ', '_').toLowerCase();
      DocumentReference docRef = _firestore.collection('players').doc(playerId);

      Players player = Players(
        name: line[3],
        position: line[1],
        team: line[4],
        alias: [],
      );

      await docRef.set(player.toMap(), SetOptions(merge: true));
    }
  }


  Future<Map<String, List<Players>>> loadPlayers() async {
    QuerySnapshot snapshot = await _firestore.collection('players').get();

    final allPlayers = snapshot.docs.map((doc) => Players.fromMap(doc.data() as Map<String, dynamic>)).toList();

    final grouped = {
      'A': <Players>[],
      'C': <Players>[],
      'D': <Players>[],
      'P': <Players>[],
    };

    for (final player in allPlayers) {
      if (grouped.containsKey(player.position)) {
        grouped[player.position]!.add(player);
      }
    }

    return grouped;
  }

  Future<void> savePlayersInBatch(List<Players> players) async {
    List<WriteBatch> batches = [];
    WriteBatch currentBatch = _firestore.batch();
    int operationCount = 0;

    for (final player in players) {
      if (operationCount >= 500) {
        batches.add(currentBatch);
        currentBatch = _firestore.batch();
        operationCount = 0;
      }

      final playerId = player.name.replaceAll(' ', '_').toLowerCase();
      final docRef = _firestore.collection('players').doc(playerId);

      currentBatch.set(docRef, player.toMap(), SetOptions(merge: true));
      operationCount++;
    }

    batches.add(currentBatch);

    for (final batch in batches) {
      try {
        await batch.commit();
        print("✅ Batch completato.");
      } catch (e) {
        print("❌ Errore durante la commit di una batch: $e");
      }
    }

    print("✅ Tutti i giocatori salvati su Firestore.");
  }

  Future<void> saveSinglePlayer(Players player) async {
    try {
      final playerId = player.name.replaceAll(' ', '_').toLowerCase();
      final docRef = _firestore.collection('players').doc(playerId);
      await docRef.set(player.toMap(), SetOptions(merge: true));
      print("✅ Giocatore '${player.name}' salvato con successo.");
    } catch (e) {
      print("❌ Errore durante il salvataggio del giocatore '${player.name}': $e");
    }
  }
}
