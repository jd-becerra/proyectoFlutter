import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_flutter/provider.dart';
import 'register.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Iniciar Sesión'),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
        actions: [
          // 🔹 Botón modo oscuro/claro
          IconButton(
            icon: Icon(
              appProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
            ),
            tooltip: appProvider.isDarkMode
                ? 'Cambiar a modo claro'
                : 'Cambiar a modo oscuro',
            onPressed: () {
              appProvider.toggleTheme();

              // 🔹 SnackBar de confirmación visual
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    appProvider.isDarkMode
                        ? '🌙 Modo oscuro activado'
                        : '☀️ Modo claro activado',
                  ),
                  duration: const Duration(seconds: 1),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 🔹 Imagen superior
            Image.network(
              'https://egresados.iteso.mx/documents/1446775/1452320/MAPA-A.jpg/336752d7-4096-0ab5-ac8e-75e5642be35d?t=1692296684440&download=true',
              height: 160,
            ),
            const SizedBox(height: 30),

            const Text(
              'Bienvenido al Estacionamiento ITESO',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),

            // 🔹 Campos de texto
            TextField(
              decoration: InputDecoration(
                labelText: 'Correo electrónico',
                prefixIcon: const Icon(Icons.email),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Contraseña',
                prefixIcon: const Icon(Icons.lock),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 30),

            // 🔹 Botón de inicio de sesión
            ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => const AlertDialog(
                    title: Text('Funcionalidad pendiente'),
                    content: Text(
                      'Aquí se verificará el inicio de sesión del usuario.',
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: Colors.blueAccent,
              ),
              child: const Text('Ingresar'),
            ),
            const SizedBox(height: 15),

            // 🔹 Botón para ir al registro
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const RegisterPage()),
                );
              },
              child: const Text('¿No tienes cuenta? Regístrate aquí'),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
