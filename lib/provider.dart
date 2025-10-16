import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

Future<Map<String, dynamic>> loadParkingData() async {
  final String response = await rootBundle.loadString('assets/data/data.json');
  final data = json.decode(response);
  return data;
}

class AppProvider extends ChangeNotifier {
  int totalSpots = 0;
  int entries = 0;
  int exits = 0;
  List<dynamic> users = [];

  Map<String, int> get parkingData {
    return {
      'total_spots': totalSpots,
      'occupied_spots': totalSpots - entries,
      'registered_entries': entries,
      'registered_exits': exits,
    };
  }

  AppProvider() {
    fetchParkingData();
  }

  Future<void> fetchParkingData() async {
    final data = await loadParkingData();
    
    final parking = data["parking"];
    totalSpots = parking["total_spots"];
    entries = parking["entries"];
    exits = parking["exits"];
    users = data["users"];

    notifyListeners();
  }
}
