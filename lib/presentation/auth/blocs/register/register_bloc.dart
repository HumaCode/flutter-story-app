import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:my_story/data/datasources/auth_remote_datasource.dart';
import 'package:my_story/data/models/auth_response_model.dart';

part 'register_bloc.freezed.dart';
part 'register_event.dart';
part 'register_state.dart';

class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  final AuthRemoteDatasource _datasource;

  RegisterBloc(this._datasource) : super(const RegisterState.initial()) {
    on<_Register>(_onRegister);
  }

  Future<void> _onRegister(_Register event, Emitter<RegisterState> emit) async {
    emit(const RegisterState.loading());

    final result = await _datasource.register(
      name: event.name,
      email: event.email,
      password: event.password,
    );

    result.fold(
      (error) => emit(RegisterState.error(error)),
      (data) => emit(RegisterState.success(data)),
    );
  }
}
