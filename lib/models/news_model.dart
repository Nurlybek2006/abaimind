import 'package:cloud_firestore/cloud_firestore.dart';

class NewsModel {
  final String id;
  final String title;
  final String content;
  final String? imageUrl;
  final String authorId;
  final String authorName;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const NewsModel({
    required this.id,
    required this.title,
    required this.content,
    this.imageUrl,
    required this.authorId,
    required this.authorName,
    required this.createdAt,
    this.updatedAt,
  });

  factory NewsModel.fromMap(Map<String, dynamic> map, {String? id}) {
    return NewsModel(
      id: id ?? map['id'] ?? '',
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      imageUrl: map['imageUrl'],
      authorId: map['authorId'] ?? '',
      authorName: map['authorName'] ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'imageUrl': imageUrl,
      'authorId': authorId,
      'authorName': authorName,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  NewsModel copyWith({
    String? id,
    String? title,
    String? content,
    String? imageUrl,
    String? authorId,
    String? authorName,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return NewsModel(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      imageUrl: imageUrl ?? this.imageUrl,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
