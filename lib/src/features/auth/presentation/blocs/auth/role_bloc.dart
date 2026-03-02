import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/storage/shared_storage.dart';
import '../../../domain/usecases/update_role_usecase.dart';
import 'role_event.dart';
import 'role_state.dart';

class RoleBloc extends Bloc<RoleEvent, RoleState> {
  final UpdateRoleUseCase updateRole;

  RoleBloc(this.updateRole) : super(RoleState.initial()) {
    on<RoleSelected>((event, emit) async {
      emit(state.copyWith(loading: true, error: null, success: false));

      try {
        final res = await updateRole(role: event.role);

        if (res.isSuccess) {
          await Prefs.setRole(res.role.toString());

          emit(
            state.copyWith(
              loading: false,
              success: true,
              role: res.role,
              message: res.message,
            ),
          );
        } else {
          emit(
            state.copyWith(loading: false, success: false, error: res.message),
          );
        }
      } catch (e) {
        emit(
          state.copyWith(loading: false, success: false, error: e.toString()),
        );
      }
    });
  }
}
