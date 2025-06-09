import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';
import 'package:excel/excel.dart';
import '../db/firebase_util_storage.dart';
import '../models/players.dart';
import 'dart:io' show File;

class FilePickerViewModel extends ChangeNotifier {
  final FirebaseUtilStorage _storage = FirebaseUtilStorage();

  String? _filePath;
  bool _isLoading = false;
  bool _alreadyLoaded = false;
  bool isLoadingPlayers = false;
  bool isSearching = false;

  final Map<String, List<Players>> _playersByPosition = {};
  Map<String, List<Players>> get playersByPosition => _playersByPosition;

  String? get filePath => _filePath;
  bool get isLoading => _isLoading;
  bool get alreadyLoaded => _alreadyLoaded;

  List<Players> get searchResults => matchingPlayers;
  List<Players> matchingPlayers = [];
  Players? searchedPlayer;

  List<Players> get allPlayers {
    return playersByPosition.values.expand((list) => list).toList();
  }

  FilePickerViewModel() {
    checker();
  }

  Future<void> pickAndProcessFile() async {
    _isLoading = true;
    notifyListeners();

    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xls', 'xlsx'],
      withData: true,
    );

    if (result != null) {
      await _readExcelFile(result);
      _alreadyLoaded = true;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _readExcelFile(FilePickerResult result) async {
    try {
      Uint8List? bytes;

      if (kIsWeb) {
        bytes = result.files.single.bytes;
        if (bytes == null) return;
      } else {
        final path = result.files.single.path;
        if (path == null) return;
        final file = File(path);
        bytes = await file.readAsBytes();
      }

      final excel = Excel.decodeBytes(bytes!);

      const allowedSheets = {'Attaccanti', 'Centrocampisti', 'Difensori', 'Portieri'};

      for (var table in excel.tables.keys) {
        if (!allowedSheets.contains(table)) continue;

        for (var row in excel.tables[table]!.rows) {
          final isEmptyRow = row.every((cell) {
            final value = cell?.value?.toString().trim();
            return value == null || value.isEmpty;
          });

          if (isEmptyRow) continue;

          List<String> rowData = row.map((cell) {
            String value = cell?.value?.toString() ?? "";
            if (value.contains(":")) value = value.split(":").last.trim();
            return value;
          }).toList();

          await _storage.storePlayers(rowData);
        }
      }
    } catch (e) {
      print("Errore durante la lettura del file Excel: $e");
    }
  }

  Future<void> checker() async {
    if (_alreadyLoaded) return;

    isLoadingPlayers = true;
    notifyListeners();

    try {
      final groupedPlayers = await _storage.loadPlayers();

      // Verifica se c'è almeno un giocatore in almeno una delle liste
      final hasPlayers = groupedPlayers.values.any((list) => list.isNotEmpty);

      if (!hasPlayers) {
        _alreadyLoaded = false;
        return;
      }

      _playersByPosition.clear();

      // Corretto uso di Map<String, List<Players>>
      for (final entry in groupedPlayers.entries) {
        final pos = entry.key;
        final players = entry.value;

        _playersByPosition[pos] = List.from(players);
      }

      _alreadyLoaded = true;
    } catch (e, stack) {
      print('❌ Errore nel checker: $e');
      print(stack);
      _alreadyLoaded = false;
    } finally {
      isLoadingPlayers = false;
      notifyListeners();
    }
  }

  Future<void> searchPlayersByFragment(String fragment) async {
    matchingPlayers.clear();
    searchedPlayer = null;
    isSearching = true;
    notifyListeners();

    if (fragment.trim().isEmpty) {
      isSearching = false;
      notifyListeners();
      return;
    }

    final list = searchPlayersByNameFragment(fragment.trim());
    matchingPlayers = list;
    isSearching = false;
    notifyListeners();
  }

  Players? findPlayerInAnyRole(String name) {
    final lowerName = name.toLowerCase();

    for (final players in _playersByPosition.values) {
      for (final player in players) {
        if (player.name.toLowerCase() == lowerName) {
          return player;
        }
        if (player.alias.any((alias) => alias.toLowerCase() == lowerName)) {
          return player;
        }
      }
    }

    return null;
  }

  List<Players> searchPlayersByNameFragment(String nameFragment) {
    final lowerFragment = nameFragment.toLowerCase();
    final Set<String> seenNames = {};
    final List<Players> results = [];

    for (final players in _playersByPosition.values) {
      for (final player in players) {
        final nameMatch = player.name.toLowerCase().contains(lowerFragment);
        final aliasMatch = player.alias.any((alias) => alias.toLowerCase().contains(lowerFragment));

        if ((nameMatch || aliasMatch) && !seenNames.contains(player.name)) {
          results.add(player);
          seenNames.add(player.name);
        }
      }
    }

    return results;
  }
}
