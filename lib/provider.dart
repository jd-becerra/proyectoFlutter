import 'dart:convert';
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Future<Map<String, dynamic>> loadParkingData() async {
  final String response = await rootBundle.loadString('assets/data/data.json');
  final data = json.decode(response);
  return data;
}

class AppProvider extends ChangeNotifier {
  int totalSpots = 0;
  int entries = 0; // lifetime entry counter
  int exits = 0;   // lifetime exit counter
  int availableSpots = 0;
  int occupiedSpots = 0;
  List<dynamic> users = [];

  final Random random = Random();
  final int maxChange = 20; // max cars entering or leaving at once in simulation
  Timer? _simulationTimer;

  Map<String, int> get parkingData => {
        'total_spots': totalSpots,
        'occupied_spots': occupiedSpots,
        'available_spots': availableSpots,
        'registered_entries': entries,
        'registered_exits': exits,
      };

  AppProvider() {
    initialize();
  }

  Future<void> initialize() async {
    await fetchParkingData();
    updateParkingData();
    simulateParkingActivity();
  }

  Future<void> fetchParkingData() async {
    final data = await loadParkingData();

    final parking = data["parking"];
    totalSpots = parking["total_spots"];
    entries = parking["entries"];
    exits = parking["exits"];
    occupiedSpots = 0; // start empty
    availableSpots = totalSpots;
    users = data["users"];

    notifyListeners();
  }

  void updateParkingData() {
    availableSpots = totalSpots - occupiedSpots;
    notifyListeners();
  }

  void addEntry() {
    if (occupiedSpots < totalSpots) {
      final newCars = random.nextInt(maxChange) + 1;
      occupiedSpots += newCars;
      entries += newCars;

      if (occupiedSpots > totalSpots) {
        addEntry();
      }

      updateParkingData();
    }
  }

  void addExit() {
    if (occupiedSpots > 0) {
      final leavingCars = random.nextInt(maxChange) + 1;
      occupiedSpots -= leavingCars;
      exits += leavingCars;

      if (occupiedSpots < 0) {
        addExit();
      }

      updateParkingData();
    }
  }

  void simulateParkingActivity() {
    _simulationTimer?.cancel(); // avoid multiple timers on hot reload

    _simulationTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      final action = random.nextInt(2);
      if (action == 0) {
        addEntry();
      } else {
        addExit();
      }
    });
  }

  @override
  void dispose() {
    _simulationTimer?.cancel();
    super.dispose();
  }
}