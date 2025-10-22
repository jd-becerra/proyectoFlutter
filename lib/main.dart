import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_flutter/provider.dart';
import 'package:proyecto_flutter/screens/login.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
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

      // 🔹 ADD THIS LINE
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

