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
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Parking App',
      theme: ThemeData(
          brightness: Brightness.light,
          primarySwatch: Colors.cyan,
          primaryColor: Colors.cyan,
          textTheme: TextTheme(
            bodyLarge: GoogleFonts.quicksand(fontSize: 20.0), 
            bodyMedium: GoogleFonts.quicksand(fontSize: 16.0),
            bodySmall: GoogleFonts.quicksand(fontSize: 14.0)
          )),
      darkTheme: ThemeData(
          brightness: Brightness.dark,
          primarySwatch: Colors.cyan,
          textTheme: TextTheme(bodyMedium: GoogleFonts.bitter(fontSize: 14.0))),
      home: Login(),
    );
  }
}
