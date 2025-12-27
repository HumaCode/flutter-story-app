part of 'get_stories_event_bloc.dart';

@freezed
class GetStoriesEvent with _$GetStoriesEvent {
  const factory GetStoriesEvent.started() = _Started;
  const factory GetStoriesEvent.getMyStories({
    @Default(1) int page,
    @Default(false) bool refresh,
  }) = _GetMyStories;

  const factory GetStoriesEvent.loadMore() = _LoadMore;
}
