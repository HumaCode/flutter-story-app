import 'user_model.dart';

class StoryModel {
  final int id;
  final int userId;
  final String title;
  final String content;
  final String? image;
  final String? imageUrl;
  final UserModel? user;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const StoryModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.content,
    this.image,
    this.imageUrl,
    this.user,
    this.createdAt,
    this.updatedAt,
  });

  factory StoryModel.fromJson(Map<String, dynamic> json) {
    return StoryModel(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      title: json['title'] as String,
      content: json['content'] as String,
      image: json['image'] as String?,
      imageUrl: json['image_url'] as String?,
      user: json['user'] != null
          ? UserModel.fromJson(json['user'] as Map<String, dynamic>)
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'content': content,
      'image': image,
      'image_url': imageUrl,
      'user': user?.toJson(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  StoryModel copyWith({
    int? id,
    int? userId,
    String? title,
    String? content,
    String? image,
    String? imageUrl,
    UserModel? user,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return StoryModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      content: content ?? this.content,
      image: image ?? this.image,
      imageUrl: imageUrl ?? this.imageUrl,
      user: user ?? this.user,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Format waktu untuk ditampilkan
  String get formattedDate {
    if (createdAt == null) return '';
    final now = DateTime.now();
    final difference = now.difference(createdAt!);

    if (difference.inDays > 7) {
      return '${createdAt!.day}/${createdAt!.month}/${createdAt!.year}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} hari lalu';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} jam lalu';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} menit lalu';
    } else {
      return 'Baru saja';
    }
  }
}
