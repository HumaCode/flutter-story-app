import 'story_model.dart';

class StoriesResponseModel {
  final bool status;
  final String message;
  final List<StoryModel> data;
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;

  const StoriesResponseModel({
    required this.status,
    required this.message,
    required this.data,
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
  });

  factory StoriesResponseModel.fromJson(Map<String, dynamic> json) {
    final paginatedData = json['data'] as Map<String, dynamic>;
    final items = paginatedData['data'] as List<dynamic>;

    return StoriesResponseModel(
      status: json['status'] as bool,
      message: json['message'] as String,
      data: items
          .map((e) => StoryModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      currentPage: paginatedData['current_page'] as int? ?? 1,
      lastPage: paginatedData['last_page'] as int? ?? 1,
      perPage: paginatedData['per_page'] as int? ?? 10,
      total: paginatedData['total'] as int? ?? 0,
    );
  }

  bool get hasMore => currentPage < lastPage;
  bool get isEmpty => data.isEmpty;
}
