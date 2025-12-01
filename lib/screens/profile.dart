import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';

import 'package:proyecto_flutter/provider.dart';
import 'package:proyecto_flutter/widgets/title.dart';
import 'package:proyecto_flutter/screens/login.dart';
import 'package:proyecto_flutter/constants/zones.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  bool _readOnly = true;
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;

  String? _selectedZone;
  XFile? _pickedPhoto;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();

    // Cargar datos una vez que el Provider esté disponible
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final appProvider = context.read<AppProvider>();
      final user = appProvider.loggedInUser;

      if (user != null) {
        _nameController.text = user.name;
        _emailController.text = user.email;
      }

      _selectedZone = appProvider.preferredZone;
      setState(() {});
    });
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
          onPressed: () => messenger.hideCurrentSnackBar(),
        ),
      ),
    );
    setState(() => _readOnly = true);
  }

  Future<void> _pickProfilePhoto() async {
    final picker = ImagePicker();
    try {
      final img = await picker.pickImage(source: ImageSource.gallery);
      if (img != null) {
        setState(() {
          _pickedPhoto = img;
        });
      }
    } catch (_) {
    }
  }

  Future<void> _logout(BuildContext context) async {
    final appProvider = Provider.of<AppProvider>(context, listen: false);

    // Firebase sign out
    await FirebaseAuth.instance.signOut();

    // Limpiar usuario del provider
    appProvider.logout();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const Login()),
      (route) => false,
    );
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

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);
    final user = appProvider.loggedInUser;

    if (user != null) {
      if (_nameController.text.isEmpty) {
        _nameController.text = user.name;
      }
      if (_emailController.text.isEmpty) {
        _emailController.text = user.email;
      }
      _selectedZone ??= appProvider.preferredZone;
    }

    return Scaffold(
      appBar: AppTitle(text: 'Perfil de Usuario'),
      body: user == null
          ? const Center(
              child: Text('No hay usuario autenticado',
                  style: TextStyle(fontSize: 18)),
            )
          : SingleChildScrollView(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
              child: Column(
                children: [
                  // Avatar circular
                  GestureDetector(
                    onTap: _pickProfilePhoto,
                    child: CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.grey.shade300,
                      backgroundImage: _pickedPhoto != null
                          ? FileImage(File(_pickedPhoto!.path))
                          : null,
                      child: _pickedPhoto == null
                          ? const Icon(Icons.person,
                              size: 60, color: Colors.grey)
                          : null,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: _showLogoutMsg,
                    child: const Text(
                      'Cerrar Sesión',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Name
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

                  // Email
                  TextField(
                    controller: _emailController,
                    readOnly: true, // normalmente no se edita el correo
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(8.0),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Zona de estacionamiento preferida
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Zona de estacionamiento preferida',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _selectedZone,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(8.0),
                        ),
                      ),
                      labelText: 'Selecciona tu zona',
                    ),
                    items: kZones
                        .map(
                          (z) =>
                              DropdownMenuItem(value: z, child: Text(z)),
                        )
                        .toList(),
                    // el dropdown SIEMPRE debe poder abrirse
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() {
                        _selectedZone = value;
                      });
                      appProvider.preferredZone = value;

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              'Zona preferida guardada: $value'),
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
                  const SizedBox(height: 8),
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
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade100,
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

