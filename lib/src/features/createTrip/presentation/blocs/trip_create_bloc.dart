import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import '../../domain/usecases/create_trip_usecase.dart';
import 'trip_create_event.dart';
import 'trip_create_state.dart';

class TripCreateBloc extends Bloc<TripCreateEvent, TripCreateState> {
  final CreateTripUseCase createTrip;

  TripCreateBloc({required this.createTrip}) : super(TripCreateState.initial()) {
    on<TripCreateReset>((e, emit) => emit(TripCreateState.initial()));

    on<TripCreateDateChanged>((e, emit) {
      final d = DateTime(e.date.year, e.date.month, e.date.day);
      emit(state.copyWith(
        date: d,
        status: TripCreateStatus.idle,
        errorMessage: null,
      ));
    });

    on<TripCreateTimeChanged>((e, emit) {
      emit(state.copyWith(
        time: e.time,
        status: TripCreateStatus.idle,
        errorMessage: null,
      ));
    });

    on<TripCreateSeatsChanged>((e, emit) {
      final v = e.seats.clamp(1, 4);
      emit(state.copyWith(
        seats: v,
        status: TripCreateStatus.idle,
        errorMessage: null,
      ));
    });

    on<TripCreateAmountChanged>((e, emit) {
      final v = e.amount < 0 ? 0 : e.amount;
      emit(state.copyWith(
        amount: v,
        status: TripCreateStatus.idle,
        errorMessage: null,
      ));
    });

    on<TripCreateSubmitted>(_onSubmit);
  }

  String _two(int n) => n.toString().padLeft(2, '0');
  String _fmtDate(DateTime d) => '${d.year}-${_two(d.month)}-${_two(d.day)}';
  String _fmtTime(TimeOfDay t) => '${_two(t.hour)}:${_two(t.minute)}';

  Future<void> _onSubmit(
      TripCreateSubmitted e,
      Emitter<TripCreateState> emit,
      ) async {
    if (!state.canSubmit) return;

    emit(state.copyWith(
      status: TripCreateStatus.submitting,
      errorMessage: null,
    ));

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
        role: 'passenger',
      );

      emit(state.copyWith(
        status: TripCreateStatus.success,
        createdTrip: res,
        errorMessage: null,
      ));
    } catch (err) {
      emit(state.copyWith(
        status: TripCreateStatus.failure,
        errorMessage: err.toString(),
      ));
    }
  }
}
