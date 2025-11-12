import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_flutter/provider.dart';
import 'package:proyecto_flutter/widgets/title.dart';
import 'package:proyecto_flutter/screens/login.dart';

class Profile extends StatelessWidget {
  const Profile({super.key});

  Future<void> _logout(BuildContext context) async {
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    await FirebaseAuth.instance.signOut();
    appProvider.logout();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        final user = snapshot.data;

        // Si usuario es nulo, redirigir a Login
        if (user == null) {
          Future.microtask(() {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const Login()),
              (route) => false,
            );
          });
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final nameController = TextEditingController(text: user.displayName ?? '');
        final emailController = TextEditingController(text: user.email ?? '');

        bool readOnly = true;

        void toggleEditable(StateSetter setState) {
          setState(() => readOnly = !readOnly);
        }

        Future<void> save(StateSetter setState) async {
          await user.updateDisplayName(nameController.text.trim());
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Se han guardado los cambios.')),
          );
          setState(() => readOnly = true);
        }

        void showLogoutDialog() {
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Cerrar Sesión'),
              content: const Text('¿Estás seguro de que deseas cerrar sesión?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    Navigator.of(ctx).pop();
                    await _logout(context);
                  },
                  child: const Text('Cerrar Sesión'),
                ),
              ],
            ),
          );
        }

        return Scaffold(
          appBar: const AppTitle(text: 'Perfil de Usuario'),
          body: Column(
            children: [
              SizedBox(
                width: double.infinity,
                height: 200,
                child: Image.asset(
                  "assets/images/entrada.jpeg",
                  fit: BoxFit.cover,
                ),
              ),
              Expanded(
                child: StatefulBuilder(
                  builder: (context, setState) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: showLogoutDialog,
                              child: const Text(
                                'Cerrar Sesión',
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: nameController,
                          readOnly: readOnly,
                          decoration: const InputDecoration(
                            labelText: 'Nombre',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(8.0)),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: emailController,
                          readOnly: true,
                          decoration: const InputDecoration(
                            labelText: 'Correo electrónico',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(8.0)),
                            ),
                          ),
                        ),
                        const SizedBox(height: 64),
                        if (!readOnly)
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () => save(setState),
                              icon: const Icon(Icons.save),
                              label: const Text('Guardar Cambios'),
                            ),
                          ),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () => toggleEditable(setState),
                            icon: Icon(
                              readOnly ? Icons.edit : Icons.cancel,
                              color: readOnly
                                  ? Theme.of(context).primaryColor
                                  : Colors.red,
                            ),
                            label: Text(
                              readOnly ? 'Editar Perfil' : 'Cancelar',
                              style: TextStyle(
                                color: readOnly
                                    ? Theme.of(context).primaryColor
                                    : Colors.red,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
