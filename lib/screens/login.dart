import 'package:flutter/material.dart';
import 'package:proyecto_flutter/screens/navigation.dart';

class Login extends StatelessWidget {
  const Login({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Center(
        child: TextButton(
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const Navigation()),
            );
          },
          child: const Text('Login'),
        ),
      ),
    );
  }
}
