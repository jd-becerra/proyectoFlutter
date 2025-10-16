import 'package:flutter/material.dart';
import 'package:proyecto_flutter/screens/home.dart';
import 'package:proyecto_flutter/provider.dart';
import 'package:provider/provider.dart';

void main() => runApp(
  ChangeNotifierProvider(
    create: (context) => AppProvider()..fetchParkingData(),
    child: const MyApp(),
  ),
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Material App',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Material App Bar'),
        ),
        body: const Home(),
      ),
    );
  }
}