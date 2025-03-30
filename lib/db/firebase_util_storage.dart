import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/players.dart';
import '../models/squad.dart';
import '../models/calendar.dart';

class FirebaseUtilStorage {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// **Controlla se l'utente ha una squadra**
  Future<bool> hasTeam() async {
    final String? email = _auth.currentUser?.email;
    if (email == null) return false;

    QuerySnapshot query = await _firestore
        .collection('squad')
        .where('owner', isEqualTo: email)
        .get();

    return query.docs.isNotEmpty;
  }
  /// Controlla se l'utente ha una squadra
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

  /// Crea una nuova squadra nel database
  Future<void> createTeam(String teamName) async {
    final String? email = _auth.currentUser?.email;
    if (email == null) return;

    DocumentReference newDocRef = _firestore.collection('squad').doc();
    Squad squad = Squad(
      id: newDocRef.id,
      teamName: teamName,
      owner: email,
      createdAt: DateTime.now(),
      reference: [], // 🔥 Inizialmente la lista è vuota
    );

    await newDocRef.set(squad.toMap());
  }

  /// Modifica il nome della squadra
  Future<void> updateTeamName(String teamId, String newName) async {
    await _firestore.collection('squad').doc(teamId).update({
      'teamName': newName,
    });
  }

  /// Reset della password
  Future<void> resetPassword() async {
    final String? email = _auth.currentUser?.email;
    if (email != null) {
      await _auth.sendPasswordResetEmail(email: email);
    }
  }

  /// Recupera tutti i nomi delle squadre
  Future<List<String>> getSquads() async {
    try {
      // Esegui una query per recuperare tutte le squadre
      QuerySnapshot querySnapshot = await _firestore.collection('squad').get();

      // Mappa i risultati per ottenere solo i nomi delle squadre
      List<String> squadNames = querySnapshot.docs
          .map((doc) => doc['teamName'] as String)
          .toList();

      return squadNames;
    } catch (e) {
      // Gestisci eventuali errori
      print('Errore durante il recupero delle squadre: $e');
      return [];
    }
  }

  Future<void> saveRound(int i, List<Match> listOfMatch) async {
    await _firestore.collection('rounds').doc().set({
      'day': i+1,
      'matches': listOfMatch.map((match) {
        return {
          'team1': match.team1,
          'team2': match.team2,
        };
      }).toList(),
    });
  }
  // crea tutto il calendario
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
        await _firestore.collection('rounds').doc().set({
          'day': i+1,
          'matches': roundsList[c].matches.map((match) {
            return {
              'team1': match.team1,
              'team2': match.team2,
            };
          }).toList(),
        });
        c++;
        if(c== roundsList.length){
          c=0;
        }
        i++;
      }while(i<selectedNumMatches);
    } catch (e) {
      print("Error nella creazione del calendario$e");
    }
  }
  /// Recupera tutto il rounds(calendario)
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
        return Round(data['day'], matches);
      }).toList();
      roundsList.sort((a, b) => a.day.compareTo(b.day));
      return roundsList;
    } catch (e) {
      print('Errore durante il recupero dei round: $e');
      return [];
    }
  }
  Future<void> storePlayers(List<String> line)async {
    if(line.isNotEmpty && int.tryParse(line[0]) != null){
      DocumentReference newDocRef = _firestore.collection('players').doc(line[1]).collection('players').doc();
      Players players = Players(name: line[3], position: line[1], team: line[4], alias: []
      );
      await newDocRef.set(players.toMap());
    }
  }
  Future<bool> checkPlayers( ) async {
    final querySnapshot = await _firestore
        .collection('players')
        .doc("A")
        .collection('players')
        .limit(1)
        .get();

    return querySnapshot.docs.isNotEmpty;
  }
  Future<List<QuerySnapshot<Object?>>> loadPlayers() async{
    QuerySnapshot attackers = await _firestore.collection('players')
        .doc("A")
        .collection('players').get();

    QuerySnapshot midfielders = await _firestore.collection('players')
        .doc("C")
        .collection('players').get();

    QuerySnapshot defenders = await _firestore.collection('players')
        .doc("D")
        .collection('players').get();

    QuerySnapshot goalkeepers = await _firestore.collection('players')
        .doc("P")
        .collection('players').get();

    return [attackers, midfielders, defenders, goalkeepers];
  }
}
