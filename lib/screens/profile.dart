import 'package:flutter/material.dart';
import 'package:proyecto_flutter/provider.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_flutter/widgets/title.dart';
import 'package:proyecto_flutter/screens/login.dart';

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
    final user = Provider.of<AppProvider>(context, listen: false).loggedInUser;
    _nameController = TextEditingController(text: user?.name ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
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
    final user = appProvider.loggedInUser;

    // Actualizar usuario cuando ya no sea nulo
    if (user != null &&
        _nameController.text.isEmpty &&
        _emailController.text.isEmpty) {
      _nameController.text = user.name;
      _emailController.text = user.email;
    }

    void _logout() {
      appProvider.logout();
      Navigator.of(context).popUntil((route) => route.isFirst);
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
                _logout();
                Navigator.of(
                  ctx,
                ).pushReplacement(MaterialPageRoute(builder: (_) => Login()));
              },
              child: const Text('Cerrar Sesión'),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppTitle(text: 'Perfil de Usuario'),
      body: user != null
          ? Column(
              children: [
                // Image covers full width
                SizedBox(
                  width: double.infinity,
                  height: 200,
                  child: Image.asset(
                    "assets/images/entrada.jpeg",
                    fit: BoxFit.cover, // fills width
                  ),
                ),

                // The rest of your content
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 0, bottom: 0, left: 16.0, right: 16.0),
                    child: Column(
                      children: [

                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () {
                                _showLogoutMsg();
                              },
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
                        const SizedBox(height: 64),
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
            )
          : const Center(
              child: Text('No user logged in', style: TextStyle(fontSize: 20)),
            ),
    );
  }
}
