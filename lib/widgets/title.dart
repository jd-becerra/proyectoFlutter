import 'package:flutter/material.dart';
import 'package:proyecto_flutter/provider.dart';
import 'package:provider/provider.dart';

class AppTitle extends StatelessWidget implements PreferredSizeWidget {
  final String text;
  const AppTitle({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);
    return AppBar(
      toolbarHeight: 40,
      flexibleSpace: SizedBox(
        width: double.infinity,
        child: Container(
          width: double.infinity,
          color: Colors.cyan,
          padding: const EdgeInsets.only(top: 24.0, right: 8.0, left: 8.0, bottom: 8.0),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
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
                        : '☀ Modo claro activado',
                  ),
                  duration: const Duration(seconds: 1),
                ),
              );
            },
          ),
        ],
    );
  }
  
  @override
  Size get preferredSize => const Size.fromHeight(40);
}