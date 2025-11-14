import 'package:flutter/material.dart';
import 'package:proyecto_flutter/provider.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_flutter/widgets/title.dart';
import 'package:proyecto_flutter/screens/login.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../constants/zones.dart'; // para el dropdown de zona

class Profile extends StatefulWidget {
  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  bool _readOnly = true;
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    final fbUser = FirebaseAuth.instance.currentUser;
    _nameController = TextEditingController(text: fbUser?.displayName ?? '');
    _emailController = TextEditingController(text: fbUser?.email ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _toggleEditable() {
    setState(() => _readOnly = !_readOnly);
    if (_readOnly) FocusScope.of(context).unfocus();
  }

  void _save() {
    FocusScope.of(context).unfocus();
    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(
      SnackBar(
        content: const Text('Se han cambiado los datos del perfil'),
        action: SnackBarAction(
          label: 'X',
          onPressed: () {
            messenger.hideCurrentSnackBar();
          },
        ),
      ),
    );
    setState(() => _readOnly = true);
  }

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);

    // Usuario del provider (JSON) y usuario de Firebase
    final localUser = appProvider.loggedInUser;
    final fbUser = FirebaseAuth.instance.currentUser;

    // Consideramos que hay usuario si alguno de los dos no es null
    final hasUser = localUser != null || fbUser != null;

    // Si el provider tiene usuario y los TextField están vacíos, los llenamos
    if (localUser != null &&
        _nameController.text.isEmpty &&
        _emailController.text.isEmpty) {
      _nameController.text = localUser.name;
      _emailController.text = localUser.email;
    }

    void _logout(BuildContext context) async {
      final appProvider = Provider.of<AppProvider>(context, listen: false);

      // Cerrar sesión en Firebase
      await FirebaseAuth.instance.signOut();

      // Limpiar usuario local
      appProvider.logout();

      // Navegar al login
      if (context.mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const Login()),
          (route) => false,
        );
      }
    }

    void _showLogoutMsg() {
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
              onPressed: () {
                Navigator.of(ctx).pop();
                _logout(context);
              },
              child: const Text('Cerrar Sesión'),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppTitle(text: 'Perfil de Usuario'),
      body: !hasUser
          ? const Center(
              child: Text(
                'No user logged in',
                style: TextStyle(fontSize: 20),
              ),
            )
          : Column(
              children: [
                // Imagen superior
                SizedBox(
                  width: double.infinity,
                  height: 200,
                  child: Image.asset(
                    "assets/images/entrada.jpeg",
                    fit: BoxFit.cover,
                  ),
                ),

                // Contenido
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(
                      top: 0,
                      bottom: 0,
                      left: 16.0,
                      right: 16.0,
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: _showLogoutMsg,
                              child: const Text(
                                'Cerrar Sesión',
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _nameController,
                          readOnly: _readOnly,
                          decoration: const InputDecoration(
                            labelText: 'Name',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(8.0),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _emailController,
                          readOnly: _readOnly,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(8.0),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // --- Zona preferida ---
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Zona de estacionamiento preferida',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          value: appProvider.preferredZone,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(8.0),
                              ),
                            ),
                            labelText: 'Selecciona tu zona',
                          ),
                          items: [
                            for (final z in kZones)
                              DropdownMenuItem(
                                value: z,
                                child: Text(z),
                              ),
                          ],
                          onChanged: (v) async {
                            if (v == null) return;
                            await context
                                .read<AppProvider>()
                                .setPreferredZone(v);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Zona preferida guardada: $v',
                                ),
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 32),

                        if (!_readOnly)
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _save,
                              icon: const Icon(Icons.save),
                              label: const Text('Guardar Cambios'),
                            ),
                          ),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _toggleEditable,
                            icon: Icon(
                              _readOnly ? Icons.edit : Icons.cancel,
                              color: _readOnly
                                  ? Theme.of(context).primaryColor
                                  : Colors.red,
                            ),
                            label: Text(
                              _readOnly ? 'Editar Perfil' : 'Cancelar',
                              style: TextStyle(
                                color: _readOnly
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
              ],
            ),
    );
  }
}
