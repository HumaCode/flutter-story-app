import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:my_story/data/datasources/story_remote_datasource.dart';
import 'package:my_story/data/models/story_model.dart';

part 'create_story_event_event.dart';
part 'create_story_event_state.dart';
part 'create_story_event_bloc.freezed.dart';

class CreateStoryBloc extends Bloc<CreateStoryEvent, CreateStoryState> {
  final StoryRemoteDatasource _datasource;

  CreateStoryBloc(this._datasource) : super(const CreateStoryState.initial()) {
    on<_Create>(_onCreate);
  }

  Future<void> _onCreate(_Create event, Emitter<CreateStoryState> emit) async {
    emit(const CreateStoryState.loading());

    final result = await _datasource.createStory(
      title: event.title,
      content: event.content,
      image: event.image,
    );

    result.fold(
      (error) => emit(CreateStoryState.error(error)),
      (story) => emit(CreateStoryState.success(story)),
    );
  }
}
