import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String id;
  final String area;
  final String content;
  final String? image;
  final DateTime createdAt;
  final String? authorId;

  Post({
    required this.id,
    required this.area,
    required this.content,
    this.image,
    required this.createdAt,
    this.authorId,
  });

  factory Post.fromJson(Map<String, dynamic> json, String docId) {
    return Post(
      id: json['id']?.toString() ?? docId,

      area: json['zone']?.toString() 
          ?? json['area']?.toString() 
          ?? 'Sin zona',

      content: json['content']?.toString() 
          ?? json['title']?.toString() 
          ?? '',

      image: json['image_url']?.toString() 
          ?? json['image']?.toString(),

      createdAt: json['createdAt'] is Timestamp
          ? (json['createdAt'] as Timestamp).toDate()
          : DateTime.now(),

      authorId: json['author_id']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'zone': area,
    'content': content,
    'image_url': image,
    'createdAt': Timestamp.fromDate(createdAt),
    'author_id': authorId,
  };
}