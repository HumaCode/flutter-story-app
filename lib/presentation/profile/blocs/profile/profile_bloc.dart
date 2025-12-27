import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:my_story/data/datasources/auth_remote_datasource.dart';
import 'package:my_story/data/models/user_model.dart';

part 'profile_event.dart';
part 'profile_state.dart';
part 'profile_bloc.freezed.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final AuthRemoteDatasource _datasource;

  ProfileBloc(this._datasource) : super(const ProfileState.initial()) {
    on<_GetProfile>(_onGetProfile);
  }

  Future<void> _onGetProfile(
    _GetProfile event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const ProfileState.loading());

    final result = await _datasource.getProfile();

    result.fold(
      (error) => emit(ProfileState.error(error)),
      (user) => emit(ProfileState.success(user)),
    );
  }
}
