import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:my_story/data/datasources/auth_remote_datasource.dart';

part 'logout_bloc.freezed.dart';
part 'logout_event.dart';
part 'logout_state.dart';

class LogoutBloc extends Bloc<LogoutEvent, LogoutState> {
  final AuthRemoteDatasource _datasource;

  LogoutBloc(this._datasource) : super(const LogoutState.initial()) {
    on<_Logout>(_onLogout);
  }

  Future<void> _onLogout(_Logout event, Emitter<LogoutState> emit) async {
    emit(const LogoutState.loading());

    final result = await _datasource.logout();

    result.fold(
      (error) => emit(LogoutState.error(error)),
      (_) => emit(const LogoutState.success()),
    );
  }
}
