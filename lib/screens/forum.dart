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

class Forum extends StatelessWidget {
  const Forum({super.key});

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('dd/MM/yyyy HH:mm');

    return Scaffold(
      appBar: AppTitle(text: 'Foro de Publicaciones'),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('posts')
            .orderBy('createdAt', descending: true)
            .snapshots(),

        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Aún no hay publicaciones'));
          }

          final docs = snapshot.data!.docs;

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),

            itemBuilder: (_, i) {
              final data = docs[i].data() as Map<String, dynamic>;

              final post = Post(
                id: data['id'],
                area: data['zone'],
                content: data['content'],
                image: data['image_url'],
                createdAt: (data['createdAt'] as Timestamp).toDate(),
              );

              return _PostCard(post: post, fmt: fmt);
            },
          );
        },
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
