import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_flutter/provider.dart';
import 'package:proyecto_flutter/screens/login.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(
    ChangeNotifierProvider(create: (_) => AppProvider(), child: const MyApp()),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, appProvider, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Parking App',

          // 🔹 Control dinámico de modo claro/oscuro
          themeMode: appProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,

          // ------------------- 🌞 Tema Claro -------------------
          theme: ThemeData(
            brightness: Brightness.light,
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.cyan),
            scaffoldBackgroundColor: Colors.grey[100],
            textTheme: TextTheme(
              headlineMedium: GoogleFonts.quicksand(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
              bodyLarge: GoogleFonts.quicksand(fontSize: 18.0),
              bodyMedium: GoogleFonts.quicksand(fontSize: 16.0),
              bodySmall: GoogleFonts.quicksand(fontSize: 14.0),
            ),
          ),

          // ------------------- 🌙 Tema Oscuro -------------------
          darkTheme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.cyan,
              brightness: Brightness.dark,
            ),
            scaffoldBackgroundColor: Colors.black,
            textTheme: TextTheme(
              headlineMedium: GoogleFonts.bitter(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
              bodyLarge: GoogleFonts.bitter(fontSize: 18.0),
              bodyMedium: GoogleFonts.bitter(fontSize: 16.0),
            ),
          ),

          home: const LoginPage(),
        );
      },
    );
  }
}
