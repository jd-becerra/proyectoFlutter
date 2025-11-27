import 'models/post.dart';
import 'dart:convert';
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:proyecto_flutter/models/user.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/foundation.dart';

// Firebase
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';

Future<Map<String, dynamic>> loadParkingData() async {
  final String response = await rootBundle.loadString('assets/data/data.json');
  return json.decode(response);
}

class AppProvider extends ChangeNotifier {
  int totalSpots = 0;

  int entries = 0;
  int exits = 0;
  int occupiedSpots = 0;
  int availableSpots = 0;

  List<User> users = [];
  User? currentUser;

  String? _preferredZone;

  static const double inMin = 0;
  static const double inMax = 4;
  static const double outMin = 5;
  static const double outMax = 10;

  AppProvider() {
    initialize();
  }

  Future<void> initialize() async {
    login("johndoe@example.com", "password123");

    await _loadTotalSpotsFromFirestore();
    await _loadCountersFromFirebase();

    final data = await loadParkingData();
    _isDarkMode =
        (data['settings']?['theme']?.toString().toLowerCase() == 'dark');

    _initParkingRealtimeListener();
    await fetchPosts();

    updateParkingData();
  }

  String? get preferredZone => _preferredZone;
  set preferredZone(String? zone) {
    _preferredZone = zone;
    notifyListeners();
  }

  final Random random = Random();
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

  // ====== Forum ======
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
        ..addAll(snapshot.docs.map((doc) {
          final data = doc.data();
          return Post(
            id: data['id'],
            area: data['zone'],
            content: data['content'],
            image: data['image_url'],
            createdAt: (data['createdAt'] as Timestamp).toDate(),
          );
        }));

      notifyListeners();
    } catch (e) {
      debugPrint('Error loading posts: $e');
    }
  }

  void addPost(Post p) {
    _posts.insert(0, p);
    notifyListeners();
  }

  // ====== Parking Data ======
  Map<String, int> get parkingData => {
        'total_spots': totalSpots,
        'occupied_spots': occupiedSpots,
        'available_spots': availableSpots,
        'registered_entries': entries,
        'registered_exits': exits,
      };

  User? get loggedInUser => currentUser;

  Future<void> login(String email, String password) async {
    await fetchUsers();

    try {
      final user =
          users.firstWhere((u) => u.email == email && u.password == password);
      currentUser = user;
      notifyListeners();
    } catch (_) {
      currentUser = null;
      notifyListeners();
    }
  }

  Future<void> fetchUsers() async {
    final data = await loadParkingData();
    users = (data["users"] as List).map((u) => User.fromJson(u)).toList();
    notifyListeners();
  }

  // ====== Load total spots from Firestore ======
  Future<void> _loadTotalSpotsFromFirestore() async {
    final doc = await FirebaseFirestore.instance
        .collection("spots")
        .doc("1")
        .get();

    if (doc.exists) {
      totalSpots = doc.data()?["total_spots"] ?? 0;
    } else {
      totalSpots = 0;
    }

    updateParkingData();
  }

  void updateParkingData() {
    availableSpots = totalSpots - occupiedSpots;
    notifyListeners();
  }

  // ====== Load persistent counters from RTDB ======
  Future<void> _loadCountersFromFirebase() async {
    final ref = FirebaseDatabase.instance.ref("parking");

    final snapshot = await ref.get();
    final data = snapshot.value as Map<dynamic, dynamic>?;

    if (data != null) {
      entries = data["entries"] ?? 0;
      exits = data["exits"] ?? 0;
      occupiedSpots = data["current_occupancy"] ?? 0;
      // totalSpots is still loaded from Firestore and stays that way
    }

    updateParkingData();
  }

  // ====== Save counters back to RTDB ======
  Future<void> _saveState() async {
    final ref = FirebaseDatabase.instance.ref("parking");
    await ref.update({
      "entries": entries,
      "exits": exits,
      "occupied": occupiedSpots,
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

  // ====== Distance sensor integration =====
  void _initParkingRealtimeListener() {
    final ref = FirebaseDatabase.instance.ref("parking");

    ref.onValue.listen((event) {
      final data = event.snapshot.value as Map?;

      if (data == null) return;

      entries = data["entries"] ?? entries;
      exits = data["exits"] ?? exits;
      occupiedSpots = data["current_occupancy"] ?? occupiedSpots;
      totalSpots = data["total_spots"] ?? totalSpots;

      updateParkingData();   // recalculates availableSpots
    });
  }
}
