import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:proyecto_flutter/widgets/title.dart';
import '../models/post.dart';
import '../widgets/pending_alert.dart';
import 'publish.dart';
import 'package:provider/provider.dart';
import '../provider.dart';

// Firebase (por si lo usas después)
// import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
              final post = Post.fromJson(
                docs[i].data() as Map<String, dynamic>,
                docs[i].id.toString(),
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

class _PostCard extends StatefulWidget {
  const _PostCard({required this.post, required this.fmt});
  final Post post;
  final DateFormat fmt;

  @override
  State<_PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<_PostCard> {
  int _likes = 0;
  bool _likedByUser = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadLikes();
  }

  Future<void> _loadLikes() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final likes = await countLikes(widget.post.id);
    final hasLiked = await userHasLiked(widget.post.id, uid);

    setState(() {
      _likes = likes;
      _likedByUser = hasLiked;
      _loading = false;
    });
  }

  Future<void> _toggle() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    await toggleLike(widget.post.id, uid);
    await _loadLikes();
  }

  Future<void> deletePost(String postId, BuildContext context) async {
    try {
      await FirebaseFirestore.instance.collection('posts').doc(postId).delete();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Publicación eliminada')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al eliminar: $e')));
    }
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar publicación'),
        content: const Text('¿Seguro que deseas eliminar esta publicación?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              deletePost(widget.post.id, context);
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  bool _isNewPost(Post post) {
    final now = DateTime.now();
    return post.createdAt.year == now.year &&
        post.createdAt.month == now.month &&
        post.createdAt.day == now.day &&
        post.createdAt.hour >= now.hour - 1;
  }

  Future<int> countLikes(String postId) async {
    final snap = await FirebaseFirestore.instance
        .collection('likes')
        .where('post_id', isEqualTo: postId)
        .get();

    return snap.docs.length;
  }

  Future<bool> userHasLiked(String postId, String userId) async {
    final snap = await FirebaseFirestore.instance
        .collection('likes')
        .where('post_id', isEqualTo: postId)
        .where('user_id', isEqualTo: userId)
        .get();

    return snap.docs.isNotEmpty;
  }

  Future<void> toggleLike(String postId, String userId) async {
    final likes = FirebaseFirestore.instance.collection('likes');

    final snap = await likes
        .where('post_id', isEqualTo: postId)
        .where('user_id', isEqualTo: userId)
        .get();

    if (snap.docs.isNotEmpty) {
      // REMOVE like
      await snap.docs.first.reference.delete();
    } else {
      // ADD like
      await likes.add({
        "post_id": postId,
        "user_id": userId,
        "createdAt": FieldValue.serverTimestamp(),
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final isOwner = uid != null && uid == widget.post.authorId;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // === Encabezado con botón de eliminar en la esquina superior derecha ===
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    'Zona: ${widget.post.area}',
                    style: text.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 2, // por si el nombre es MUY largo
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                widget.fmt.format(widget.post.createdAt),
                style: text.bodySmall?.copyWith(
                  color: (text.bodySmall?.color ?? Colors.grey).withOpacity(
                    0.8,
                  ),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            // === Fin encabezado ===
            const SizedBox(height: 8),
            Text(widget.post.content, style: text.bodyMedium),
            const SizedBox(height: 8),
            if (widget.post.image != null && widget.post.image!.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: _PostImage(path: widget.post.image!),
              ),
            const SizedBox(height: 8),
            Row(
              children: [
                // Likes
                _loading
                    ? const CircularProgressIndicator(strokeWidth: 2)
                    : InkWell(
                        onTap: isOwner
                            ? null
                            : _toggle, // DESACTIVADO SI ES AUTOR
                        child: Opacity(
                          opacity: isOwner
                              ? 0.5
                              : 1, // visualmente "deshabilitado"
                          child: Row(
                            children: [
                              Icon(
                                _likedByUser
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: _likedByUser ? Colors.red : null,
                              ),
                              const SizedBox(width: 4),
                              Text('$_likes'),
                            ],
                          ),
                        ),
                      ),
                IconButton(
                  icon: const Icon(Icons.share_outlined),
                  onPressed: () => showPendingAlert(
                    context,
                    'Aquí se compartirá la publicación.',
                  ),
                ),
                if (widget.post.authorId != null &&
                    widget.post.authorId!.isNotEmpty &&
                    Provider.of<AppProvider>(
                          context,
                          listen: false,
                        ).loggedInUser?.id ==
                        widget.post.authorId) ...[
                  IconButton(
                    tooltip: 'Editar',
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PublishScreen(post: widget.post),
                      ),
                    ),
                    icon: const Icon(Icons.edit_outlined),
                  ),
                  IconButton(
                    tooltip: 'Eliminar',
                    icon: const Icon(
                      Icons.delete_outline,
                      color: Colors.redAccent,
                    ),
                    onPressed: () => _confirmDelete(context),
                  ),
                ],
                const Spacer(),
                if (_isNewPost(widget.post)) const Badge(label: Text('Nuevo')),
                const SizedBox(width: 8),
                // Leyenda para mostrar que es el autor
                if (isOwner)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 0,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withOpacity(0.4),
                      ),
                    ),
                    child: Text(
                      'Tu publicación',
                      style: text.labelSmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
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
    final isNetwork = path.startsWith('http://') || path.startsWith('https://');
    final image = isNetwork
        ? Image.network(path, fit: BoxFit.cover)
        : Image.asset(path, fit: BoxFit.cover); // requiere que el asset exista

    return AspectRatio(aspectRatio: 16 / 9, child: image);
  }
}
