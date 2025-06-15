import 'dart:async';
import 'package:flutter/material.dart';
import '../db/firebase_util_storage.dart';
import '../models/players.dart';
import '../services/auction_realtime_service.dart';
import 'package:firebase_database/firebase_database.dart';

class AuctionViewModel extends ChangeNotifier {
  final FirebaseUtilStorage _storage = FirebaseUtilStorage();
  final AuctionRealtimeService _realtimeService = AuctionRealtimeService();

  List<String> allSquads = [];
  List<String?> selectedSquads = List.generate(8, (_) => null);

  final List<Map<String, List<TextEditingController>>> controllers =
  List.generate(8, (_) => {
    "P": List.generate(3, (_) => TextEditingController()),
    "D": List.generate(8, (_) => TextEditingController()),
    "C": List.generate(8, (_) => TextEditingController()),
    "A": List.generate(6, (_) => TextEditingController()),
  });

  final List<Map<String, List<FocusNode>>> focusNodes =
  List.generate(8, (_) => {
    "P": List.generate(3, (_) => FocusNode()),
    "D": List.generate(8, (_) => FocusNode()),
    "C": List.generate(8, (_) => FocusNode()),
    "A": List.generate(6, (_) => FocusNode()),
  });

  final List<Map<String, List<TextEditingController>>> prices =
  List.generate(8, (_) => {
    "P": List.generate(3, (_) => TextEditingController()),
    "D": List.generate(8, (_) => TextEditingController()),
    "C": List.generate(8, (_) => TextEditingController()),
    "A": List.generate(6, (_) => TextEditingController()),
  });

  final List<Map<String, List<FocusNode>>> priceFocusNodes =
  List.generate(8, (_) => {
    "P": List.generate(3, (_) => FocusNode()),
    "D": List.generate(8, (_) => FocusNode()),
    "C": List.generate(8, (_) => FocusNode()),
    "A": List.generate(6, (_) => FocusNode()),
  });

  final List<StreamSubscription<DatabaseEvent>> _slotSubscriptions = [];

  bool isLoading = true;

  AuctionViewModel() {
    loadData();
  }

  Future<void> loadData() async {
    await loadSquads();
    await loadAuctionData();
    _setupListeners();
    _startRealtimeListeners();
    isLoading = false;
    notifyListeners();
  }

  Future<void> loadSquads() async {
    allSquads = await _storage.getSquads();
  }

  Future<void> loadAuctionData() async {
    final data = await _realtimeService.fetchAllAuctionData();

    for (int col = 0; col < 8; col++) {
      final slotKey = 'slot_$col';
      if (data.containsKey(slotKey)) {
        final slotData = Map<String, dynamic>.from(data[slotKey]);

        if (slotData.containsKey('squad')) {
          selectedSquads[col] = slotData['squad'];
        }

        if (slotData.containsKey('role')) {
          final roleMap = Map<String, dynamic>.from(slotData['role']);
          for (final role in roleMap.keys) {
            final rawPlayers = roleMap[role];

            if (rawPlayers is List) {
              for (int i = 0; i < rawPlayers.length; i++) {
                final player = rawPlayers[i];
                if (player is Map) {
                  controllers[col][role]?[i].text = player['name']?.toString() ?? '';
                  prices[col][role]?[i].text = player['price']?.toString() ?? '0';
                }
              }
            }
          }
        }
      }
    }
  }

  void _startRealtimeListeners() {
    for (int col = 0; col < 8; col++) {
      final sub = _realtimeService.watchSlot('slot_$col').listen((event) {
        if (!event.snapshot.exists) return;

        final data = Map<String, dynamic>.from(event.snapshot.value as Map);

        if (data.containsKey('squad')) {
          selectedSquads[col] = data['squad'];
        }

        if (data.containsKey('role')) {
          final roleMap = Map<String, dynamic>.from(data['role']);
          for (final role in roleMap.keys) {
            final rawPlayers = roleMap[role];
            if (rawPlayers is List) {
              for (int i = 0; i < rawPlayers.length; i++) {
                final player = rawPlayers[i];
                if (player is Map) {
                  controllers[col][role]?[i].text = player['name']?.toString() ?? '';
                  prices[col][role]?[i].text = player['price']?.toString() ?? '0';
                }
              }
            }
          }
        }

        notifyListeners();
      });

      _slotSubscriptions.add(sub);
    }
  }

  void _setupListeners() {
    for (int colIndex = 0; colIndex < 8; colIndex++) {
      final roleMap = controllers[colIndex];
      final priceMap = prices[colIndex];

      final nodeMap = focusNodes[colIndex];
      final priceNodeMap = priceFocusNodes[colIndex];

      roleMap.forEach((role, controllerList) {
        for (int i = 0; i < controllerList.length; i++) {
          nodeMap[role]![i].addListener(() {
            if (!nodeMap[role]![i].hasFocus) {
              _savePlayer(colIndex, role, i);
            }
          });

          priceNodeMap[role]![i].addListener(() {
            if (!priceNodeMap[role]![i].hasFocus) {
              _savePlayer(colIndex, role, i);
            }
          });
        }
      });
    }
  }

  void _savePlayer(int colIndex, String role, int i) {
    final name = controllers[colIndex][role]?[i].text.trim() ?? '';
    final priceText = prices[colIndex][role]?[i].text.trim();
    final price = int.tryParse(priceText ?? '') ?? 0;

    if (name.isNotEmpty || price > 0) {
      _realtimeService.setPlayer(
        slotId: 'slot_$colIndex',
        role: role,
        index: i,
        name: name,
        price: price,
      );
    }
  }

  void selectSquad(int index, String? name) {
    selectedSquads[index] = name;
    notifyListeners();
    if (name != null) {
      _realtimeService.setSquad('slot_$index', name);
    }
  }

  int getTotalSpent(int colIndex) {
    int sum = 0;
    prices[colIndex].forEach((role, list) {
      for (final controller in list) {
        sum += int.tryParse(controller.text) ?? 0;
      }
    });
    return sum;
  }

  int getEmptySlots(int colIndex) {
    int count = 0;
    controllers[colIndex].forEach((role, list) {
      for (final c in list) {
        if (c.text.trim().isEmpty) count++;
      }
    });
    return count;
  }

  Future<void> linkPlayersToSquads(List<Players> allPlayers) async {
    await _storage.linkPlayersToSquadsWithPrices(
      selectedSquads: selectedSquads,
      controllers: controllers,
      prices: prices,
      allPlayers: allPlayers,
    );
  }

  @override
  void dispose() {
    for (var squadMap in controllers) {
      squadMap.forEach((_, list) => list.forEach((c) => c.dispose()));
    }
    for (var priceMap in prices) {
      priceMap.forEach((_, list) => list.forEach((c) => c.dispose()));
    }
    for (var focusMap in focusNodes) {
      focusMap.forEach((_, list) => list.forEach((n) => n.dispose()));
    }
    for (var focusMap in priceFocusNodes) {
      focusMap.forEach((_, list) => list.forEach((n) => n.dispose()));
    }
    for (final sub in _slotSubscriptions) {
      sub.cancel();
    }
    super.dispose();
  }
}
