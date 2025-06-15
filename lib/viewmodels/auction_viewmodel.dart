import 'package:flutter/material.dart';
import '../db/firebase_util_storage.dart';

class AuctionViewModel extends ChangeNotifier {
  final FirebaseUtilStorage _storage = FirebaseUtilStorage();

  List<String> allSquads = [];
  List<String?> selectedSquads = List.generate(8, (_) => null);

  final List<Map<String, List<TextEditingController>>> controllers =
  List.generate(8, (_) => {
    "P": List.generate(3, (_) => TextEditingController()),
    "D": List.generate(8, (_) => TextEditingController()),
    "C": List.generate(8, (_) => TextEditingController()),
    "A": List.generate(6, (_) => TextEditingController()),
  });

  final List<Map<String, List<TextEditingController>>> prices =
  List.generate(8, (_) => {
    "P": List.generate(3, (_) => TextEditingController()),
    "D": List.generate(8, (_) => TextEditingController()),
    "C": List.generate(8, (_) => TextEditingController()),
    "A": List.generate(6, (_) => TextEditingController()),
  });

  AuctionViewModel() {
    loadSquads();
  }

  Future<void> loadSquads() async {
    allSquads = await _storage.getSquads();
    notifyListeners();
  }

  void selectSquad(int index, String? name) {
    selectedSquads[index] = name;
    notifyListeners();
  }

  @override
  void dispose() {
    for (var squadMap in controllers) {
      squadMap.forEach((_, list) {
        for (var controller in list) {
          controller.dispose();
        }
      });
    }
    for (var priceMap in prices) {
      priceMap.forEach((_, list) {
        for (var controller in list) {
          controller.dispose();
        }
      });
    }
    super.dispose();
  }
}
