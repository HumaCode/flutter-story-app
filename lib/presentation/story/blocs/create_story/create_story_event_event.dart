part of 'create_story_event_bloc.dart';

@freezed
class CreateStoryEvent with _$CreateStoryEvent {
  const factory CreateStoryEvent.started() = _Started;
  const factory CreateStoryEvent.create({
    required String title,
    required String content,
    File? image,
  }) = _Create;
}
