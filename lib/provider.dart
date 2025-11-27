import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:shared_preferences/shared_preferences.dart';

import 'constants/zones.dart';
import 'models/post.dart';
import 'models/user.dart';

Future<Map<String, dynamic>> loadParkingData() async {
  final String response =
      await rootBundle.loadString('assets/data/data.json');
  final data = json.decode(response);
  return data as Map<String, dynamic>;
}

class AppProvider extends ChangeNotifier {
  // ====== Estacionamiento (simulación) ======
  int totalSpots = 0;
  int entries = 0; // lifetime entry counter
  int exits = 0; // lifetime exit counter
  int availableSpots = 0;
  int occupiedSpots = 0;

  // ====== Usuarios ======
  List<User> users = [];
  User? currentUser;

  // ====== Simulación ======
  final Random random = Random();
  final int maxChange = 20; // max cars entering or leaving at once in simulation
  Timer? _simulationTimer;

  // ====== Tema (modo oscuro) ======
  bool _isDarkMode = false;
  bool get isDarkMode => _isDarkMode;
  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  void updateUser(User user) {
    currentUser = user;
    notifyListeners();
  }

  // ====== Foro (posts) ======
  final List<Post> _posts = [];
  List<Post> get posts => List.unmodifiable(_posts);

  Future<void> fetchPosts() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('posts')
          .orderBy('createdAt', descending: true)
          .get();

      _posts
        ..clear()
        ..addAll(rawPosts.map((e) => Post.fromJson(e as Map<String, dynamic>)));
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading Firestore posts: $e');
    }
  }

  void addPost(Post p) {
    _posts.insert(0, p);
    notifyListeners();
  }

  // ====== Zona preferida (persistente, por USUARIO) ======
  String _preferredZone = kZones.first;
  String get preferredZone => _preferredZone;

  String _zoneKeyForUser(User user) => 'preferred_zone_${user.id}';
  // si quieres por email: 'preferred_zone_${user.email}'

  Future<void> _loadPreferredZoneForUser(User user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = _zoneKeyForUser(user);

      String? saved = prefs.getString(key);

      // Si no hay nada en SharedPreferences, intentamos ver si hay algo en data.json
      if (saved == null) {
        final data = await loadParkingData();

        // Buscar al usuario en el JSON para ver si tiene preferred_zone
        final usersJson = (data['users'] as List?) ?? [];
        Map<String, dynamic>? match;
        try {
          match = usersJson
              .cast<Map<String, dynamic>>()
              .firstWhere((u) => u['email'] == user.email);
        } catch (_) {
          match = null;
        }

        final fromJson =
            match?['preferred_zone'] ?? data['settings']?['preferred_zone'];

        if (fromJson is String) {
          saved = fromJson;
        }
      }

      if (saved != null && kZones.contains(saved)) {
        _preferredZone = saved;
      } else {
        _preferredZone = kZones.first;
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Error al cargar zona preferida del usuario: $e');
    }
  }

  Future<void> setPreferredZone(String zone) async {
    if (!kZones.contains(zone)) return;
    _preferredZone = zone;
    notifyListeners();

    final user = currentUser;
    if (user == null) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final key = _zoneKeyForUser(user);
      await prefs.setString(key, zone);
    } catch (e) {
      debugPrint('Error al guardar zona preferida del usuario: $e');
    }
  }

  // ====== Datos de estacionamiento ======
  Map<String, int> get parkingData => {
        'total_spots': totalSpots,
        'occupied_spots': occupiedSpots,
        'available_spots': availableSpots,
        'registered_entries': entries,
        'registered_exits': exits,
      };

  User? get loggedInUser => currentUser;

  AppProvider() {
    initialize();
  }

  Future<void> initialize() async {
    // Mock login inicial (puedes quitarlo si solo usas FirebaseAuth)
    login("johndoe@example.com", "password123");

    await fetchParkingData();

    // Carga configuración inicial (modo oscuro + posts)
    final data = await loadParkingData();
    _isDarkMode =
        (data['settings']?['theme']?.toString().toLowerCase() == 'dark');
    await fetchPosts();
    updateParkingData();
    simulateParkingActivity();
  }

  // ====== Usuarios ======
  Future<void> login(String email, String password) async {
    await fetchUsers();

    try {
      final user = users.firstWhere(
        (user) => user.email == email && user.password == password,
      );
      currentUser = user;
      notifyListeners();

      // cargar zona preferida de ESTE usuario
      await _loadPreferredZoneForUser(user);
    } catch (e) {
      currentUser = null;
      notifyListeners();
    }
  }

  Future<void> fetchUsers() async {
    final data = await loadParkingData();
    users =
        (data["users"] as List).map((user) => User.fromJson(user)).toList();
    notifyListeners();
  }

  // ====== Estacionamiento ======
  Future<void> fetchParkingData() async {
    final data = await loadParkingData();

    final parking = data["parking"] as Map<String, dynamic>;
    totalSpots = parking["total_spots"] as int;
    entries = parking["entries"] as int;
    exits = parking["exits"] as int;
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

    _simulationTimer =
        Timer.periodic(const Duration(seconds: 5), (timer) {
      final action = random.nextInt(2);
      if (action == 0) {
        addEntry();
      } else {
        addExit();
      }
    });
  }

  void logout() {
  currentUser = null;
  notifyListeners();
  }


  @override
  void dispose() {
    _simulationTimer?.cancel();
    super.dispose();
  }
}
