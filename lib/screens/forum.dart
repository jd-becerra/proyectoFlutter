import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_flutter/widgets/title.dart';
import '../provider.dart';
import '../models/post.dart';
import '../widgets/pending_alert.dart';
import 'publish.dart';

// Firebase (por si lo usas después)
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Forum extends StatefulWidget {
  const Forum({super.key});
  @override
  State<Forum> createState() => _ForumState();
}

class _ForumState extends State<Forum> {
  @override
  void initState() {
    super.initState();
    // Si por alguna razón no llamas fetchPosts() en initialize(), descomenta:
    // Future.microtask(() => context.read<AppProvider>().fetchPosts());
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final posts = provider.posts;
    final fmt = DateFormat('dd/MM/yyyy HH:mm');

    return Scaffold(
      appBar: AppTitle(text: 'Foro de Publicaciones'),
      body: posts.isEmpty
          ? const Center(child: Text('Aún no hay publicaciones'))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: posts.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, i) => _PostCard(post: posts[i], fmt: fmt),
            ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.edit),
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const PublishScreen()),
        ),
      ),
    );
  }
}

class _PostCard extends StatelessWidget {
  const _PostCard({required this.post, required this.fmt});
  final Post post;
  final DateFormat fmt;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // === Encabezado SIN Row: lugar arriba, fecha abajo ===
            Text(
              'Lugar: ${post.area}',
              style: text.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
              maxLines: 2,                 // por si el nombre es MUY largo
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                fmt.format(post.createdAt),
                style: text.bodySmall?.copyWith(
                  color: (text.bodySmall?.color ?? Colors.grey)
                      .withOpacity(0.8),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // === Fin encabezado ===

            const SizedBox(height: 8),
            Text(
              post.content,
              style: text.bodyMedium,
            ),
            const SizedBox(height: 8),
            if (post.image != null && post.image!.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: _PostImage(path: post.image!),
              ),
            const SizedBox(height: 8),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.favorite_border),
                  onPressed: () => showPendingAlert(
                    context,
                    'Aquí se registrará tu “like”.',
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.share_outlined),
                  onPressed: () => showPendingAlert(
                    context,
                    'Aquí se compartirá la publicación.',
                  ),
                ),
                const Spacer(),
                const Badge(label: Text('NEW')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PostImage extends StatelessWidget {
  const _PostImage({required this.path});
  final String path;

  @override
  Widget build(BuildContext context) {
    final isNetwork =
        path.startsWith('http://') || path.startsWith('https://');
    final image = isNetwork
        ? Image.network(path, fit: BoxFit.cover)
        : Image.asset(
            path,
            fit: BoxFit.cover,
          ); // requiere que el asset exista

    return AspectRatio(
      aspectRatio: 16 / 9,
      child: image,
    );
  }
}
