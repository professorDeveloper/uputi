import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/verify_auth_usecase.dart';
import 'otp_event.dart';
import 'otp_state.dart';

class OtpBloc extends Bloc<OtpEvent, OtpState> {
  final VerifyAuthUseCase verifyAuth;

  OtpBloc(this.verifyAuth) : super(OtpState.initial()) {
    on<OtpVerifyPressed>((event, emit) async {
      emit(state.copyWith(loading: true, error: null));

      final res = await verifyAuth(
        verificationId: event.verificationId,
        code: event.code,
      );

      if (res.isSuccess) {
        emit(
          state.copyWith(
            loading: false,
            user: res.user,
            message: res.message,
            accessToken: res.accessToken,

            tokenType: res.tokenType,
          ),
        );
      } else {
        emit(
          state.copyWith(
            loading: false,
            error: res.message.isNotEmpty ? res.message : "Invalid code",
          ),
        );
      }
    });
  }
}
