import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';

import '../../domain/usecase/driver_create_trip_usecase.dart';
import 'create_trip_event.dart';
import 'create_trip_state.dart';

class DriverTripCreateBloc
    extends Bloc<DriverTripCreateEvent, DriverTripCreateState> {
  final DriverCreateTripUseCase createTrip;

  DriverTripCreateBloc({required this.createTrip})
    : super(DriverTripCreateState.initial()) {
    on<DriverTripCreateReset>(
      (e, emit) => emit(DriverTripCreateState.initial()),
    );

    on<DriverTripCreateDateChanged>((e, emit) {
      final d = DateTime(e.date.year, e.date.month, e.date.day);
      emit(
        state.copyWith(
          date: d,
          status: DriverTripCreateStatus.idle,
          errorMessage: null,
        ),
      );
    });

    on<DriverTripCreateTimeChanged>((e, emit) {
      emit(
        state.copyWith(
          time: e.time,
          status: DriverTripCreateStatus.idle,
          errorMessage: null,
        ),
      );
    });

    on<DriverTripCreateSeatsChanged>((e, emit) {
      final v = e.seats.clamp(1, 4);
      emit(
        state.copyWith(
          seats: v,
          status: DriverTripCreateStatus.idle,
          errorMessage: null,
        ),
      );
    });

    on<DriverTripCreateAmountChanged>((e, emit) {
      final v = e.amount < 0 ? 0 : e.amount;
      emit(
        state.copyWith(
          amount: v,
          status: DriverTripCreateStatus.idle,
          errorMessage: null,
        ),
      );
    });

    on<DriverTripCreateCommentChanged>((e, emit) {
      emit(
        state.copyWith(
          comment: e.comment,
          status: DriverTripCreateStatus.idle,
          errorMessage: null,
        ),
      );
    });

    on<DriverTripCreateSubmitted>(_onSubmit);
  }

  String _two(int n) => n.toString().padLeft(2, '0');

  String _fmtDate(DateTime d) => '${d.year}-${_two(d.month)}-${_two(d.day)}';

  String _fmtTime(TimeOfDay t) => '${_two(t.hour)}:${_two(t.minute)}';

  Future<void> _onSubmit(
    DriverTripCreateSubmitted e,
    Emitter<DriverTripCreateState> emit,
  ) async {
    if (!state.canSubmit) return;

    emit(
      state.copyWith(
        status: DriverTripCreateStatus.submitting,
        errorMessage: null,
      ),
    );

    try {
      final res = await createTrip(
        fromLat: e.fromLat,
        fromLng: e.fromLng,
        fromAddress: e.fromAddress,
        toLat: e.toLat,
        toLng: e.toLng,
        toAddress: e.toAddress,
        date: _fmtDate(state.date),
        time: _fmtTime(state.time),
        seats: state.seats,
        amount: state.amount,
        comment: state.comment.trim().isEmpty ? null : state.comment.trim(),
      );

      emit(
        state.copyWith(
          status: DriverTripCreateStatus.success,
          createdTrip: res,
          errorMessage: null,
        ),
      );
    } catch (err) {
      emit(
        state.copyWith(
          status: DriverTripCreateStatus.failure,
          errorMessage: err.toString(),
        ),
      );
    }
  }
}
