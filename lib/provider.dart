import 'models/post.dart';
import 'dart:convert';
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:proyecto_flutter/models/user.dart' as AppUser;
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/foundation.dart';

// Firebase
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AppProvider extends ChangeNotifier {
  int totalSpots = 0;

  int entries = 0;
  int exits = 0;
  int occupiedSpots = 0;
  int availableSpots = 0;

  AppUser.User? loggedInUser;

  /// Zona de estacionamiento preferida (se sincroniza con loggedInUser.preferredZone)
  String? _preferredZone;
  String? get preferredZone => _preferredZone;

  /// Setter de zona preferida: recibe SIEMPRE un String no nulo
  set preferredZone(String zone) {
    _preferredZone = zone;

    // Actualizamos también el modelo de usuario en memoria
    if (loggedInUser != null) {
      loggedInUser = AppUser.User(
        id: loggedInUser!.id,
        name: loggedInUser!.name,
        email: loggedInUser!.email,
        photoUrl: loggedInUser!.photoUrl,
        preferredZone: zone, // <- aquí ya no hay error de null
        preferredTheme: loggedInUser!.preferredTheme,
      );

      // Guardamos en Firestore por USUARIO (campo preferred_zone)
      FirebaseFirestore.instance
          .collection('users')
          .doc(loggedInUser!.id)
          .update({'preferred_zone': zone});
    }

    notifyListeners();
  }

  static const double inMin = 0;
  static const double inMax = 4;
  static const double outMin = 5;
  static const double outMax = 10;

  AppProvider() {
    initialize();
  }

  Future<void> initialize() async {
    await _loadTotalSpotsFromFirestore();
    await _loadCountersFromFirebase();

    // En lugar de loadUserFromFirestore, usamos siempre syncUserFromFirebase,
    // que parte de FirebaseAuth.currentUser y aplica defaults.
    await syncUserFromFirebase();

    // Sincronizamos tema y zona una vez que se cargó (si hay) el usuario
    _isDarkMode = loggedInUser?.preferredTheme == 'dark';
    _preferredZone = loggedInUser?.preferredZone;

    _initParkingRealtimeListener();
    await fetchPosts();

    updateParkingData();
  }

  final Random random = Random();
  Timer? _simulationTimer;

  bool _isDarkMode = false;
  bool get isDarkMode => _isDarkMode;
  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  // ====== Usuario desde Firestore (método utilitario, lo dejamos por si lo usas en otro lado) ======
  Future<void> loadUserFromFirestore() async {
    final fbUser = FirebaseAuth.instance.currentUser;
    if (fbUser == null) return;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(fbUser.uid)
        .get();

    if (!doc.exists) return;

    final data = doc.data()!;

    loggedInUser = AppUser.User(
      id: fbUser.uid,
      name: data['name'],
      email: data['email'],
      photoUrl: data['photo_url'],
      preferredZone: data['preferred_zone'],
      preferredTheme: data['preferred_theme'],
    );

    // Sincronizamos _preferredZone con el usuario
    _preferredZone = loggedInUser?.preferredZone;

    notifyListeners();
  }

  void updateUser(AppUser.User user) {
    loggedInUser = user;
    _preferredZone = user.preferredZone;
    notifyListeners();
  }

  void setUserAvatar(String url) {
    if (loggedInUser == null) return;

    loggedInUser = AppUser.User(
      id: loggedInUser!.id,
      name: loggedInUser!.name,
      email: loggedInUser!.email,
      photoUrl: url,
      preferredZone: loggedInUser!.preferredZone,
      preferredTheme: loggedInUser!.preferredTheme,
    );

    FirebaseFirestore.instance
        .collection('users')
        .doc(loggedInUser!.id)
        .update({'photo_url': url});

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

  // ====== Load total spots from Firestore ======
  Future<void> _loadTotalSpotsFromFirestore() async {
    final doc = await FirebaseFirestore.instance
        .collection('spots')
        .doc('1')
        .get();

    if (doc.exists) {
      totalSpots = doc.data()?['total_spots'] ?? 0;
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
    final ref = FirebaseDatabase.instance.ref('parking');

    final snapshot = await ref.get();
    final data = snapshot.value as Map<dynamic, dynamic>?;

    if (data != null) {
      entries = data['entries'] ?? 0;
      exits = data['exits'] ?? 0;
      occupiedSpots = data['current_occupancy'] ?? 0;
      // totalSpots se sigue cargando desde Firestore
    }

    updateParkingData();
  }

  // ====== Save counters back to RTDB ======
  Future<void> _saveState() async {
    final ref = FirebaseDatabase.instance.ref('parking');
    await ref.update({
      'entries': entries,
      'exits': exits,
      'occupied': occupiedSpots,
    });
  }

  void logout() {
    loggedInUser = null;
    // NO tocamos _preferredZone en Firestore, solo limpiamos en memoria
    notifyListeners();
  }

  @override
  void dispose() {
    _simulationTimer?.cancel();
    super.dispose();
  }

  // ====== Distance sensor integration =====
  void _initParkingRealtimeListener() {
    final ref = FirebaseDatabase.instance.ref('parking');

    ref.onValue.listen((event) {
      final data = event.snapshot.value as Map?;

      if (data == null) return;

      entries = data['entries'] ?? entries;
      exits = data['exits'] ?? exits;
      occupiedSpots = data['current_occupancy'] ?? occupiedSpots;
      totalSpots = data['total_spots'] ?? totalSpots;

      updateParkingData();
    });
  }

  // ====== Sincronizar usuario (por si cambió en Firestore) ======
  Future<void> syncUserFromFirebase() async {
    final fbUser = FirebaseAuth.instance.currentUser;

    if (fbUser == null) {
      loggedInUser = null;
      notifyListeners();
      return;
    }

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(fbUser.uid)
        .get();

    if (!doc.exists) return;

    final data = doc.data()!;

    loggedInUser = AppUser.User(
      id: fbUser.uid,
      name: data['name'] ?? fbUser.displayName ?? '',
      email: data['email'] ?? fbUser.email ?? '',
      photoUrl: data['photo_url'],
      preferredZone: data['preferred_zone'] ??
          'Estacionamiento externo y profesores Norte',
      preferredTheme: data['preferred_theme'] ?? 'light',
    );

    // Volvemos a sincronizar la zona preferida interna
    _preferredZone = loggedInUser?.preferredZone;

    notifyListeners();
  }
}
