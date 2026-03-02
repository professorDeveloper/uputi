import 'package:bloc/bloc.dart';
import '../../domain/usecases/reverse_geocode_usecase.dart';
import 'choose_direction_event.dart';
import 'choose_direction_state.dart';

class ChooseDirectionsBloc extends Bloc<ChooseDirectionsEvent, ChooseDirectionsState> {
  final ReverseGeocodeUseCase reverse;

  int _startReq = 0;
  int _finishReq = 0;
  int _centerReq = 0;

  ChooseDirectionsBloc({
    required this.reverse,
    required double initialLat,
    required double initialLng,
  }) : super(ChooseDirectionsState.initial(initialLat, initialLng)) {
    on<ChooseDirectionsCenterChanged>(_onCenterChanged);
    on<ChooseDirectionsPickAt>(_onPickAt);

    on<ChooseDirectionsClearA>((event, emit) {
      emit(state.copyWith(
        mode: PickMode.start,
        startLat: null,
        startLng: null,
        startAddress: 'A manzilni tanlang',
        loadingStart: false,
        error: null,
      ));
    });

    on<ChooseDirectionsClearB>((event, emit) {
      emit(state.copyWith(
        mode: PickMode.finish,
        finishLat: null,
        finishLng: null,
        finishAddress: 'B manzilni tanlang',
        loadingFinish: false,
        error: null,
      ));
    });

    on<ChooseDirectionsSwitchToA>((e, emit) =>
        emit(state.copyWith(mode: PickMode.start, error: null)));

    on<ChooseDirectionsSwitchToB>((e, emit) =>
        emit(state.copyWith(mode: PickMode.finish, error: null)));
  }

  Future<void> _onCenterChanged(
      ChooseDirectionsCenterChanged event,
      Emitter<ChooseDirectionsState> emit,
      ) async {
    emit(state.copyWith(
      centerLat: event.lat,
      centerLng: event.lng,
      loadingCenter: true,
      error: null,
    ));

    final myId = ++_centerReq;

    try {
      final place = await reverse(lat: event.lat, lng: event.lng, language: 'ru');
      if (myId != _centerReq) return;

      if ((place.countryCode ?? '').toLowerCase() != 'uz') {
        emit(state.copyWith(
          loadingCenter: false,
          error: 'Faqat O‘zbekiston ichidan tanlang',
        ));
        return;
      }

      emit(state.copyWith(
        loadingCenter: false,
        centerAddress: place.address,
        error: null,
      ));
    } catch (e) {
      if (myId != _centerReq) return;
      emit(state.copyWith(
        loadingCenter: false,
        error: e.toString(),
      ));
    }
  }

  Future<void> _onPickAt(
      ChooseDirectionsPickAt event,
      Emitter<ChooseDirectionsState> emit,
      ) async {
    final picking = state.mode;

    // ✅ B faqat 1 marta: allaqachon tanlangan bo‘lsa blok
    if (picking == PickMode.finish &&
        state.finishLat != null &&
        state.finishLng != null &&
        !state.loadingFinish) {
      emit(state.copyWith(
        error: 'B manzil allaqachon tanlangan. O‘zgartirish uchun B ni tozalang (x).',
      ));
      return;
    }

    emit(state.copyWith(
      centerLat: event.lat,
      centerLng: event.lng,
      error: null,
    ));

    if (picking == PickMode.start) {
      final myId = ++_startReq;

      emit(state.copyWith(
        startLat: event.lat,
        startLng: event.lng,
        startAddress: state.startLat == null ? 'Aniqlanmoqda...' : 'Yangilanmoqda...',
        loadingStart: true,
        mode: PickMode.finish,
        error: null,
      ));

      try {
        final place = await reverse(lat: event.lat, lng: event.lng, language: 'ru');
        if (myId != _startReq) return;

        if ((place.countryCode ?? '').toLowerCase() != 'uz') {
          emit(state.copyWith(
            loadingStart: false,
            error: 'Faqat O‘zbekiston ichidan tanlang',
          ));
          return;
        }

        emit(state.copyWith(
          startAddress: place.address,
          loadingStart: false,
          error: null,
        ));
      } catch (e) {
        if (myId != _startReq) return;
        emit(state.copyWith(
          loadingStart: false,
          error: e.toString(),
        ));
      }

      return;
    }

    // finish
    final myId = ++_finishReq;

    emit(state.copyWith(
      finishLat: event.lat,
      finishLng: event.lng,
      finishAddress: state.finishLat == null ? 'Aniqlanmoqda...' : 'Yangilanmoqda...',
      loadingFinish: true,
      error: null,
    ));

    try {
      final place = await reverse(lat: event.lat, lng: event.lng, language: 'ru');
      if (myId != _finishReq) return;

      if ((place.countryCode ?? '').toLowerCase() != 'uz') {
        emit(state.copyWith(
          loadingFinish: false,
          error: 'Faqat O‘zbekiston ichidan tanlang',
        ));
        return;
      }

      emit(state.copyWith(
        finishAddress: place.address,
        loadingFinish: false,
        error: null,
      ));
    } catch (e) {
      if (myId != _finishReq) return;
      emit(state.copyWith(
        loadingFinish: false,
        error: e.toString(),
      ));
    }
  }
}
