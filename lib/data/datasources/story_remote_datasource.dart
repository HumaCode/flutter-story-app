import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../core/constants/variables.dart';
import '../../core/utils/api_handler.dart';
import '../models/stories_response_model.dart';
import '../models/story_model.dart';

class StoryRemoteDatasource {
  /// Get my stories (paginated)
  Future<Either<String, StoriesResponseModel>> getMyStories({
    int page = 1,
  }) async {
    final result = await ApiHandler.get('${Variables.myStories}?page=$page');

    return result.fold(
      (error) => Left(error),
      (data) => Right(StoriesResponseModel.fromJson(data)),
    );
  }

  /// Create new story
  Future<Either<String, StoryModel>> createStory({
    required String title,
    required String content,
    File? image,
  }) async {
    final result = await ApiHandler.postMultipart(
      Variables.stories,
      fields: {'title': title, 'content': content},
      file: image,
      fileField: 'image',
    );

    return result.fold((error) => Left(error), (data) {
      final storyData = data['data'] as Map<String, dynamic>;
      return Right(StoryModel.fromJson(storyData));
    });
  }

  /// Update story
  Future<Either<String, StoryModel>> updateStory({
    required int id,
    required String title,
    required String content,
    File? image,
  }) async {
    final result = await ApiHandler.postMultipart(
      Variables.storyById(id),
      fields: {'_method': 'PUT', 'title': title, 'content': content},
      file: image,
      fileField: 'image',
    );

    return result.fold((error) => Left(error), (data) {
      final storyData = data['data'] as Map<String, dynamic>;
      return Right(StoryModel.fromJson(storyData));
    });
  }

  /// Delete story
  Future<Either<String, String>> deleteStory(int id) async {
    final result = await ApiHandler.delete(Variables.storyById(id));

    return result.fold(
      (error) => Left(error),
      (data) => Right(data['message'] ?? 'Cerita berhasil dihapus'),
    );
  }
}
