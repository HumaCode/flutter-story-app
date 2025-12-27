import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:my_story/data/datasources/story_remote_datasource.dart';
import 'package:my_story/data/models/story_model.dart';

part 'get_stories_event_event.dart';
part 'get_stories_event_state.dart';
part 'get_stories_event_bloc.freezed.dart';

class GetStoriesBloc extends Bloc<GetStoriesEvent, GetStoriesState> {
  final StoryRemoteDatasource _datasource;

  GetStoriesBloc(this._datasource) : super(const GetStoriesState.initial()) {
    on<_GetMyStories>(_onGetMyStories);
    on<_LoadMore>(_onLoadMore);
  }

  Future<void> _onGetMyStories(
    _GetMyStories event,
    Emitter<GetStoriesState> emit,
  ) async {
    if (event.refresh || state is _Initial || state is _Error) {
      emit(const GetStoriesState.loading());
    }

    final result = await _datasource.getMyStories(page: event.page);

    result.fold((error) => emit(GetStoriesState.error(error)), (response) {
      List<StoryModel> stories = response.data;

      // Jika load more, append ke list yang ada
      if (!event.refresh && state is _Success && event.page > 1) {
        final currentState = state as _Success;
        stories = [...currentState.stories, ...response.data];
      }

      emit(
        GetStoriesState.success(
          stories: stories,
          currentPage: response.currentPage,
          lastPage: response.lastPage,
          hasMore: response.hasMore,
        ),
      );
    });
  }

  Future<void> _onLoadMore(
    _LoadMore event,
    Emitter<GetStoriesState> emit,
  ) async {
    final currentState = state;
    if (currentState is! _Success ||
        !currentState.hasMore ||
        currentState.isLoadingMore) {
      return;
    }

    emit(currentState.copyWith(isLoadingMore: true));

    final nextPage = currentState.currentPage + 1;
    final result = await _datasource.getMyStories(page: nextPage);

    result.fold((error) => emit(currentState.copyWith(isLoadingMore: false)), (
      response,
    ) {
      final updatedStories = [...currentState.stories, ...response.data];
      emit(
        GetStoriesState.success(
          stories: updatedStories,
          currentPage: response.currentPage,
          lastPage: response.lastPage,
          hasMore: response.hasMore,
          isLoadingMore: false,
        ),
      );
    });
  }
}
