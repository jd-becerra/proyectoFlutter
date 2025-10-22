import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_flutter/provider.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Registro de Usuario'),
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

              // 🔹 Snackbar de confirmación (opcional pero elegante)
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
            const Icon(
              Icons.app_registration,
              size: 80,
              color: Colors.blueAccent,
            ),
            const SizedBox(height: 25),

            // 🔹 Campos de registro
            TextField(
              decoration: InputDecoration(
                labelText: 'Nombre completo',
                prefixIcon: const Icon(Icons.person),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 20),
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
            const SizedBox(height: 20),
            TextField(
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Confirmar contraseña',
                prefixIcon: const Icon(Icons.lock_outline),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 30),

            // 🔹 Botón de registro
            ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => const AlertDialog(
                    title: Text('Funcionalidad pendiente'),
                    content: Text(
                      'Aquí se registrará al nuevo usuario en la base de datos.',
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: Colors.blueAccent,
              ),
              child: const Text('Crear cuenta'),
            ),

            const SizedBox(height: 40),

            // 🔹 Imagen inferior decorativa
            Image.network(
              'https://image.freepik.com/vector-gratis/zonas-estacionamiento-urbano-dibujos-animados-diseno-vista-superior-coches-color-ilustracion-vectorial_287964-926.jpg',
              height: 130,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
