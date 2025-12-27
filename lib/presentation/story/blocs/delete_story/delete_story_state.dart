part of 'delete_story_bloc.dart';

@freezed
class DeleteStoryState with _$DeleteStoryState {
  const factory DeleteStoryState.initial() = _Initial;
  const factory DeleteStoryState.loading() = _Loading;
  const factory DeleteStoryState.success(String message) = _Success;
  const factory DeleteStoryState.error(String message) = _Error;
}
