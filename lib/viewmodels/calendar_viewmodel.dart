import 'package:flutter/material.dart';
import '../../db/firebase_util_storage.dart';
import '../../models/match.dart';
import '../models/round.dart';

class CalendarViewModel extends ChangeNotifier {
  final FirebaseUtilStorage _storage = FirebaseUtilStorage();

  final List<String> _players = [];
  final List<Round> _schedule = [];
  List<String> _availablePlayers = [];
  int selectedNumMatches = 38;
  bool _showAlternativeView = false;

  bool get showAlternativeView => _showAlternativeView;
  List<String> get players => _players;
  List<Round> get schedule => _schedule;
  List<String> get availablePlayers => _availablePlayers;

  CalendarViewModel() {
    _loadPlayers();
  }

  void toggleView() {
    _showAlternativeView = !_showAlternativeView;
    notifyListeners();
  }

  Future<void> _loadPlayers() async {
    _availablePlayers = await _storage.getSquads();
    notifyListeners();
  }

  void togglePlayerSelection(String player, bool selected) {
    if (selected) {
      if (_players.length < 12) _players.add(player);
    } else {
      _players.remove(player);
    }
    notifyListeners();
  }

  void setSelectedNumMatches(int numMatches) {
    selectedNumMatches = numMatches;
    notifyListeners();
  }

  void generateSchedule() {
    _players.shuffle();
    List<Match> matches = [];
    for (int c = 0; c < _players.length; c++) {
      for (int j = c+1; j < _players.length; j++) {
        matches.add(Match(_players[c],_players[j]));
      }
    }
    generateRounds(matches);
  }

  void generateRounds(List<Match> matches){
    for (int i = 0; i < (_players.length-1); i++){
      List<Match> matchForDay = [];
      matches.removeWhere((c) {
        if (!matchAlreadyChoosen(matchForDay, c)) {
          matchForDay.add(c);
          return true;
        }
        return false;
      });
      saveFirstGirone(i,matchForDay);
    }
    saveCalendar();
  }

  bool matchAlreadyChoosen(List<Match> matches, Match match){
    for (Match c in matches){
      if (c.team1 == match.team1 || c.team2 == match.team2 || c.team2 == match.team1 || c.team1 == match.team2){
        return true;
      }
    }
    return false;
  }

  void saveFirstGirone(int i,List<Match> listOfMatch) {
    _storage.saveRound(i,listOfMatch);
  }
  void saveCalendar(){
    _storage.saveCalendar(selectedNumMatches);
  }
}