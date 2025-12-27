import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:my_story/data/datasources/story_remote_datasource.dart';
import 'package:my_story/data/models/story_model.dart';

part 'update_story_event.dart';
part 'update_story_state.dart';
part 'update_story_bloc.freezed.dart';

class UpdateStoryBloc extends Bloc<UpdateStoryEvent, UpdateStoryState> {
  final StoryRemoteDatasource _datasource;

  UpdateStoryBloc(this._datasource) : super(const UpdateStoryState.initial()) {
    on<_Update>(_onUpdate);
  }

  Future<void> _onUpdate(_Update event, Emitter<UpdateStoryState> emit) async {
    emit(const UpdateStoryState.loading());

    final result = await _datasource.updateStory(
      id: event.id,
      title: event.title,
      content: event.content,
      image: event.image,
    );

    result.fold(
      (error) => emit(UpdateStoryState.error(error)),
      (story) => emit(UpdateStoryState.success(story)),
    );
  }
}
