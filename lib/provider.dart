import 'dart:convert';
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:proyecto_flutter/models/user.dart';

/// Carga los datos desde el archivo JSON en assets/data/data.json
Future<Map<String, dynamic>> loadParkingData() async {
  final String response = await rootBundle.loadString('assets/data/data.json');
  final data = json.decode(response);
  return data;
}

class AppProvider extends ChangeNotifier {
  // 🔹 Variables del sistema de estacionamiento
  int totalSpots = 0;
  int entries = 0; // lifetime entry counter
  int exits = 0; // lifetime exit counter
  int availableSpots = 0;
  int occupiedSpots = 0;

  // 🔹 Manejo de usuarios
  List<User> users = [];
  User? currentUser;

  // 🔹 Variables del simulador
  final Random random = Random();
  final int maxChange =
      20; // max cars entering or leaving at once in simulation
  Timer? _simulationTimer;

  // 🔹 Tema (modo claro/oscuro)
  bool _isDarkMode = false;
  bool get isDarkMode => _isDarkMode;

  // 🔹 Getters de datos del estacionamiento
  Map<String, int> get parkingData => {
    'total_spots': totalSpots,
    'occupied_spots': occupiedSpots,
    'available_spots': availableSpots,
    'registered_entries': entries,
    'registered_exits': exits,
  };

  User? get loggedInUser => currentUser;

  // 🔹 Constructor
  AppProvider() {
    initialize();
  }

  // --------------------- INICIALIZACIÓN ---------------------

  Future<void> initialize() async {
    // Simulamos un login inicial y empezamos la simulación
    login("johndoe@example.com", "password123");
    await fetchParkingData();
    updateParkingData();
    simulateParkingActivity();
  }

  // --------------------- USUARIOS ---------------------

  Future<void> login(String email, String password) async {
    await fetchUsers();

    try {
      final user = users.firstWhere(
        (user) => user.email == email && user.password == password,
      );
      currentUser = user;
      notifyListeners();
    } catch (e) {
      currentUser = null;
      notifyListeners();
    }
  }

  Future<void> fetchUsers() async {
    final data = await loadParkingData();
    users = (data["users"] as List).map((user) => User.fromJson(user)).toList();
    notifyListeners();
  }

  // --------------------- ESTACIONAMIENTO ---------------------

  Future<void> fetchParkingData() async {
    final data = await loadParkingData();

    final parking = data["parking"];
    totalSpots = parking["total_spots"];
    entries = parking["entries"];
    exits = parking["exits"];
    occupiedSpots = 0; // start empty
    availableSpots = totalSpots;

    notifyListeners();
  }

  void updateParkingData() {
    availableSpots = totalSpots - occupiedSpots;
    notifyListeners();
  }

  void addEntry() {
    if (occupiedSpots >= totalSpots) return; // already full

    final newCars = random.nextInt(maxChange) + 1;
    final actualCars = min(newCars, totalSpots - occupiedSpots);

    occupiedSpots += actualCars;
    entries += actualCars;

    updateParkingData();
  }

  void addExit() {
    if (occupiedSpots <= 0) return; // already empty

    final leavingCars = random.nextInt(maxChange) + 1;
    final actualCars = min(leavingCars, occupiedSpots);

    occupiedSpots -= actualCars;
    exits += actualCars;

    updateParkingData();
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

  // --------------------- TEMA CLARO/OSCURO ---------------------

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  // --------------------- LIMPIEZA ---------------------

  @override
  void dispose() {
    _simulationTimer?.cancel();
    super.dispose();
  }
}
