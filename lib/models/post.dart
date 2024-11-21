import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String id;
  final String authorId;
  final String caption;
  final List<String> mediaUrls;
  final List<String> mediaTypes;
  final List<String> likes;
  final DateTime createdAt;
  final DateTime updatedAt;

  Post({
    required this.id,
    required this.authorId,
    required this.caption,
    required this.mediaUrls,
    required this.mediaTypes,
    required this.likes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Post.fromFirestore(Map<String, dynamic> data, String id) {
    final createdAtTimestamp = data['createdAt'] as Timestamp?;
    final updatedAtTimestamp = data['updatedAt'] as Timestamp?;
    
    return Post(
      id: id,
      authorId: data['authorId'] ?? '',
      caption: data['caption'] ?? '',
      mediaUrls: List<String>.from(data['mediaUrls'] ?? []),
      mediaTypes: List<String>.from(data['mediaTypes'] ?? []),
      likes: List<String>.from(data['likes'] ?? []),
      createdAt: createdAtTimestamp?.toDate() ?? DateTime.now(),
      updatedAt: updatedAtTimestamp?.toDate() ?? DateTime.now(),
    );
  }
} 