import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_flutter/provider.dart';
import 'package:proyecto_flutter/screens/login.dart';
import 'package:google_fonts/google_fonts.dart';

// Firebase
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// Supabase
import 'package:supabase_flutter/supabase_flutter.dart';
  
void main() async {
  // Inicializar Firebase
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Inicializar Supabase (para imagenes)
  await Supabase.initialize(
    url: 'https://udytaezgcttyfslhahui.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InVkeXRhZXpnY3R0eWZzbGhhaHVpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjQxOTc2NzEsImV4cCI6MjA3OTc3MzY3MX0.QrmauHy6-Z2irmHxTpGITeBMlt2KxuPQhohMH8V_VPQ',
  );

  runApp(
    ChangeNotifierProvider(
      create: (_) => AppProvider(),
      child: const MyApp(),
    ),
  );
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Parking App',

      themeMode: appProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,

      theme: ThemeData(
        brightness: Brightness.light,
        colorSchemeSeed: Colors.cyan,
        scaffoldBackgroundColor: Colors.grey[100],
        textTheme: TextTheme(
          bodyLarge: GoogleFonts.quicksand(fontSize: 20.0),
          bodyMedium: GoogleFonts.quicksand(fontSize: 16.0),
          bodySmall: GoogleFonts.quicksand(fontSize: 14.0),
        ),
      ),

      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.cyan,
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: Colors.black,
        textTheme: TextTheme(
          bodyMedium: GoogleFonts.bitter(fontSize: 14.0),
        ),
      ),

      home: const Login(),
    );
  }
}

