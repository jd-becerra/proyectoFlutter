import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../provider.dart';
import '../models/post.dart';
import '../widgets/pending_alert.dart';

class PublishScreen extends StatefulWidget {
  const PublishScreen({super.key});
  @override
  State<PublishScreen> createState() => _PublishScreenState();
}

class _PublishScreenState extends State<PublishScreen> {
  final _formKey = GlobalKey<FormState>();
  final _contentCtrl = TextEditingController();
  String _area = 'G1';
  XFile? _picked;

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

  void _publish() {
    if (!_formKey.currentState!.validate()) return;

    final post = Post(
      id: DateTime.now().millisecondsSinceEpoch,
      area: _area,
      content: _contentCtrl.text.trim(),
      image: _picked?.path, // si es File local, se muestra con Image.file
      createdAt: DateTime.now(),
    );

    context.read<AppProvider>().addPost(post);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Comentario publicado')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Añade una publicación')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Text('Tu lugar de estacionamiento', style: text.titleMedium),
              const SizedBox(height: 8),
              DropdownMenu<String>(
                initialSelection: _area,
                onSelected: (v) => setState(() => _area = v ?? 'G1'),
                dropdownMenuEntries: const [
                  DropdownMenuEntry(value: 'G1', label: 'G1'),
                  DropdownMenuEntry(value: 'G2', label: 'G2'),
                  DropdownMenuEntry(value: 'G3', label: 'G3'),
                  DropdownMenuEntry(value: 'G4', label: 'G4'),
                ],
              ),
              const SizedBox(height: 16),
              Text('Escribe tu comentario', style: text.titleMedium),
              const SizedBox(height: 8),
              TextFormField(
                controller: _contentCtrl,
                maxLines: 5,
                decoration: const InputDecoration(
                  hintText: 'Hoy está muy lleno en la zona G1…',
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
                    border: Border.all(color: Theme.of(context).colorScheme.outline),
                  ),
                  child: _picked == null
                      ? const Center(child: Icon(Icons.image, size: 40))
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
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
                onPressed: _publish,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
