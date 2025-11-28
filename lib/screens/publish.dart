import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_flutter/widgets/title.dart';
import '../provider.dart';
import '../models/post.dart';
import '../widgets/pending_alert.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

// Firebase
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Supabase
import 'package:supabase_flutter/supabase_flutter.dart';

class PublishScreen extends StatefulWidget {
  final Post? post;

  const PublishScreen({super.key, this.post});
  @override
  State<PublishScreen> createState() => _PublishScreenState();
}

class _PublishScreenState extends State<PublishScreen> {
  final _formKey = GlobalKey<FormState>();
  final _contentCtrl = TextEditingController();
  String _area = 'Estacionamiento externo y profesores Norte';
  XFile? _picked;

  @override
  void initState() {
    super.initState();

    // Si se edita una publicación, cargar datos
    if (widget.post != null) {
      _contentCtrl.text = widget.post!.content;
      _area = widget.post!.area;
    }
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

    final isEditing = widget.post != null;
    final postId = isEditing
        ? widget.post!.id.toString()
        : DateTime.now().millisecondsSinceEpoch.toString();

    String? imageUrl = widget.post?.image; // keep existing image if no change

    // Upload new image if user picked one
    final supabase = Supabase.instance.client;
    if (_picked != null) {
      final fileName = '$postId-${_picked!.name}';
      final filePath = 'posts/$fileName';

      final bytes = await _picked!.readAsBytes();

      await supabase.storage
          .from('Images')
          .uploadBinary(
            filePath,
            bytes,
            fileOptions: const FileOptions(upsert: true),
          );

      imageUrl = supabase.storage.from('Images').getPublicUrl(filePath);
    }

    // Solo se pueden editar el contenido y la imagen
    final Map<String, dynamic> data = {
      'content': _contentCtrl.text.trim(),
      'image_url': imageUrl,
    };

    final doc = FirebaseFirestore.instance.collection('posts').doc(postId);

    if (isEditing) {
      // Editar
      await doc.update(data);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Publicación actualizada')));
    } else {
      // Crear nuevo post
      data['id'] = postId;
      data['zone'] = _area;
      data['createdAt'] = DateTime.now();
      data['author_id'] = FirebaseAuth.instance.currentUser?.uid;

      await doc.set(data);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Se publicó el comentario')));
    }

    if (mounted) Navigator.pop(context);
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
              Text(
                'Tu zona de estacionamiento actual',
                style: text.titleMedium,
              ),
              const SizedBox(height: 8),
              DropdownMenu<String>(
                initialSelection: _area,
                onSelected: (v) => setState(() => _area = v ?? 'Estacionamiento externo y profesores Norte'),
                dropdownMenuEntries: const [
                  DropdownMenuEntry(value: 'Estacionamiento externo y profesores Norte', label: 'Estacionamiento externo y profesores Norte'),
                  DropdownMenuEntry(value: 'Estacionamiento controlado Norte', label: 'Estacionamiento controlado Norte'),
                  DropdownMenuEntry(value: 'Estacionamiento controlado Poniente', label: 'Estacionamiento controlado Poniente'),
                  DropdownMenuEntry(value: 'Estacionamiento profesores Sur', label: 'Estacionamiento profesores Sur'),
                  DropdownMenuEntry(value: 'Acceso peatonal puerta Sur', label: 'Acceso peatonal puerta Sur'),
                ],
              ),
              const SizedBox(height: 16),
              Text('Escribe tu comentario', style: text.titleMedium),
              const SizedBox(height: 8),
              TextFormField(
                controller: _contentCtrl,
                maxLines: 5,
                decoration: const InputDecoration(
                  hintText: 'Hoy está muy lleno en la zona Estacionamiento externo y profesores Norte…',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Escribe un comentario'
                    : null,
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
                                  _picked!.path, // web gives you a blob URL
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
                label: Text(widget.post != null ? 'Actualizar' : 'Publicar'),
                onPressed: () async => await _publish(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
