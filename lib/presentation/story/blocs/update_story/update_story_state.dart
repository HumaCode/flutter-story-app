part of 'update_story_bloc.dart';

@freezed
class UpdateStoryState with _$UpdateStoryState {
  const factory UpdateStoryState.initial() = _Initial;
  const factory UpdateStoryState.loading() = _Loading;
  const factory UpdateStoryState.success(StoryModel story) = _Success;
  const factory UpdateStoryState.error(String message) = _Error;
}
