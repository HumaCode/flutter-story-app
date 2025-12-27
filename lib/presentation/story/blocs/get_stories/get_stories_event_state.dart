part of 'get_stories_event_bloc.dart';

@freezed
class GetStoriesState with _$GetStoriesState {
  const factory GetStoriesState.initial() = _Initial;
  const factory GetStoriesState.loading() = _Loading;
  const factory GetStoriesState.success({
    required List<StoryModel> stories,
    required int currentPage,
    required int lastPage,
    required bool hasMore,
    @Default(false) bool isLoadingMore,
  }) = _Success;
  const factory GetStoriesState.error(String message) = _Error;
}
