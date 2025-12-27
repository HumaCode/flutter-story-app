part of 'delete_story_bloc.dart';

@freezed
class DeleteStoryEvent with _$DeleteStoryEvent {
  const factory DeleteStoryEvent.started() = _Started;
  const factory DeleteStoryEvent.delete(int id) = _Delete;
}
