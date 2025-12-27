import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:my_story/data/datasources/story_remote_datasource.dart';

part 'delete_story_event.dart';
part 'delete_story_state.dart';
part 'delete_story_bloc.freezed.dart';

class DeleteStoryBloc extends Bloc<DeleteStoryEvent, DeleteStoryState> {
  final StoryRemoteDatasource _datasource;

  DeleteStoryBloc(this._datasource) : super(const DeleteStoryState.initial()) {
    on<_Delete>(_onDelete);
  }

  Future<void> _onDelete(_Delete event, Emitter<DeleteStoryState> emit) async {
    emit(const DeleteStoryState.loading());

    final result = await _datasource.deleteStory(event.id);

    result.fold(
      (error) => emit(DeleteStoryState.error(error)),
      (message) => emit(DeleteStoryState.success(message)),
    );
  }
}
