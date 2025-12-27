part of 'update_story_bloc.dart';

@freezed
class UpdateStoryEvent with _$UpdateStoryEvent {
  const factory UpdateStoryEvent.started() = _Started;
  const factory UpdateStoryEvent.update({
    required int id,
    required String title,
    required String content,
    File? image,
  }) = _Update;
}
