import 'models/post.dart';
import 'dart:convert';
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:proyecto_flutter/models/user.dart';
import 'package:flutter/services.dart' show rootBundle;

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
  List<User> users = [];
  User? currentUser;

  final Random random = Random();
  final int maxChange = 20; // max cars entering or leaving at once in simulation
  Timer? _simulationTimer;

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
      final data = await loadParkingData();
      final rawPosts = (data['posts'] as List?) ?? [];
      _posts
        ..clear()
        ..addAll(rawPosts.map((e) => Post.fromJson(e as Map<String, dynamic>)));
      notifyListeners();
    } catch (e) {
      debugPrint('Error al cargar posts: $e');
    }
  }

  void addPost(Post p) {
    _posts.insert(0, p);
    notifyListeners();
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
      final user =
          users.firstWhere((user) => user.email == email && user.password == password);
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

  // ====== Estacionamiento ======
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
