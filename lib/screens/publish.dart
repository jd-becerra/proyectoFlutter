import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_flutter/widgets/title.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import '../provider.dart';
import '../models/post.dart';
import '../widgets/pending_alert.dart';
import '../constants/zones.dart'; // <- zonas oficiales ITESO

// Firebase
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PublishScreen extends StatefulWidget {
  const PublishScreen({super.key});
  @override
  State<PublishScreen> createState() => _PublishScreenState();
}

class _PublishScreenState extends State<PublishScreen> {
  final _formKey = GlobalKey<FormState>();
  final _contentCtrl = TextEditingController();

  // se inicializa con la primera zona, pero se sincroniza con la preferida en initState
  String _area = kZones.first;
  XFile? _picked;

  @override
  void initState() {
    super.initState();
    // después del primer frame tomamos la zona preferida del usuario
    Future.microtask(() {
      final preferred = context.read<AppProvider>().preferredZone;
      if (mounted && kZones.contains(preferred)) {
        setState(() => _area = preferred);
      }
    });
  }

  @override
  void dispose() {
    _contentCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final img = await picker.pickImage(source: ImageSource.gallery);
      if (img != null) setState(() => _picked = img);
    } catch (_) {
      if (!mounted) return;
      await showPendingAlert(
        context,
        'Aquí se activará la galería/cámara (permisos/implementación pendiente).',
      );
    }
  }

  Future<void> _publish() async {
    if (!_formKey.currentState!.validate()) return;

    final post = Post(
      id: DateTime.now().millisecondsSinceEpoch,
      area: _area, // ahora guarda el nombre completo de la zona
      content: _contentCtrl.text.trim(),
      image: _picked?.path, // si es File local, se muestra con Image.file
      createdAt: DateTime.now(),
    );

    // Añade al provider (lista local)
    context.read<AppProvider>().addPost(post);

    // Feedback en UI
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Comentario publicado')),
    );

    // Guarda también en Firestore
    await FirebaseFirestore.instance.collection('posts').add({
      'id': post.id,
      'zone': post.area,
      'content': post.content,
      'image': post.image,
      'createdAt': post.createdAt,
    }).then(
      (value) => debugPrint('Comentario publicado en Firestore: ${value.id}'),
    ).catchError(
      (error) =>
          debugPrint('Error al publicar comentario en Firestore: $error'),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppTitle(text: 'Publicar Comentario'),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Texto actualizado
              Text('Tu zona de estacionamiento', style: text.titleMedium),
              const SizedBox(height: 8),
              DropdownMenu<String>(
                initialSelection: _area,
                onSelected: (v) {
                  if (v == null) return;
                  setState(() => _area = v);
                },
                dropdownMenuEntries: [
                  for (final z in kZones)
                    DropdownMenuEntry<String>(value: z, label: z),
                ],
              ),
              const SizedBox(height: 16),
              Text('Escribe tu comentario', style: text.titleMedium),
              const SizedBox(height: 8),
              TextFormField(
                controller: _contentCtrl,
                maxLines: 5,
                decoration: const InputDecoration(
                  hintText:
                      'Ejemplo: Hoy está muy lleno en estacionamiento controlado Norte…',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Escribe un comentario' : null,
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 140,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                  child: _picked == null
                      ? const Center(child: Icon(Icons.image, size: 40))
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: kIsWeb
                              ? Image.network(
                                  _picked!.path, // en web es un blob URL
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                )
                              : Image.file(
                                  File(_picked!.path),
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                ),
                        ),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                icon: const Icon(Icons.send),
                label: const Text('Publicar comentario'),
                onPressed: () async => _publish(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
