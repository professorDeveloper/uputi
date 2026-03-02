import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/start_auth_usecase.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final StartAuthUseCase startAuth;

  AuthBloc(this.startAuth) : super(AuthState.initial()) {
    on<AuthStartPressed>(_onStart);
  }

  Future<void> _onStart(AuthStartPressed event, Emitter<AuthState> emit) async {
    emit(state.copyWith(
      loading: true,
      error: null,
      message: null,
      verificationId: null,
      loggedIn: false,
      user: null,
    ));


    final res = await startAuth(name: event.name, phone: event.phone);
    print(res.toJson());
    if (res.requiresOtp) {
      emit(
        state.copyWith(
          loading: false,
          verificationId: res.verificationId,
          message: res.message,
          error: null,
          loggedIn: false,
        ),
      );
      return;
    }

    if (res.isLoggedIn) {
      emit(
        state.copyWith(
          user: res.user,
          loading: false,
          verificationId: null,
          message: res.message,
          error: null,
          loggedIn: true,
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        loading: false,
        verificationId: null,
        message: null,
        loggedIn: false,
        error: (res.message.isNotEmpty ? res.message : "Xatolik"),
      ),
    );
  }
}
