class Post {
  final int id;
  final String area;       // tu JSON no trae "area"; default "G1"
  final String content;    // toma "content" o "title"
  final String? image;     // ruta asset/URL opcional
  final DateTime createdAt;

  Post({
    required this.id,
    required this.area,
    required this.content,
    this.image,
    required this.createdAt,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: (json['id'] as num?)?.toInt() ?? DateTime.now().millisecondsSinceEpoch,
      area: (json['area'] ?? 'G1').toString(),
      content: (json['content'] ?? json['title'] ?? '').toString(),
      image: json['image']?.toString(),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'area': area,
    'content': content,
    'image': image,
    'created_at': createdAt.toIso8601String(),
  };
}
