import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:meta/meta.dart';
import 'package:uputi/src/features/profilePassenger/data/model/profile_response.dart';

import '../../domain/usecase/get_profile_usecase.dart';
import '../../../../core/storage/shared_storage.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc({
    required GetProfileUseCase getProfile,
    required Dio dio,
  })  : _getProfile = getProfile,
        _dio = dio,
        super(const ProfileInitial()) {
    on<ProfileFetch>(_onFetch);
    on<ProfileRefresh>(_onRefresh);
    on<ProfileCarUpdateRequested>(_onCarUpdateRequested);
  }

  final GetProfileUseCase _getProfile;
  final Dio _dio;

  Options get _authOptions => Options(
    headers: {'Authorization': 'Bearer ${Prefs.getAccessToken()}'},
  );

  // ── Fetch ────────────────────────────────────────────────────────────────
  Future<void> _onFetch(
      ProfileFetch event, Emitter<ProfileState> emit) async {
    emit(const ProfileLoading());
    try {
      final res = await _getProfile();
      emit(ProfileLoaded(data: ProfileViewData.fromResponse(res)));
    } catch (e) {
      emit(ProfileFailure(message: e.toString()));
    }
  }

  Future<void> _onRefresh(
      ProfileRefresh event, Emitter<ProfileState> emit) async {
    emit(const ProfileLoading());
    try {
      final res = await _getProfile();
      emit(ProfileLoaded(data: ProfileViewData.fromResponse(res)));
    } catch (e) {
      emit(ProfileFailure(message: e.toString()));
    }
  }

  // ── Car update via API ───────────────────────────────────────────────────
  Future<void> _onCarUpdateRequested(
      ProfileCarUpdateRequested event, Emitter<ProfileState> emit) async {
    final s = state;
    if (s is! ProfileLoaded) return;

    emit(ProfileLoaded(data: s.data, isCarUpdating: true));

    try {
      final res = await _dio.post(
        '/api/car/driver',
        data: {
          'model': event.model,
          'color': event.color,
          'number': event.number,
        },
        options: _authOptions,
      );

      final carData = res.data;
      CarViewData? updatedCar;

      if (carData is Map<String, dynamic>) {
        updatedCar = CarViewData.fromJson(carData);
      } else if (carData is Map) {
        updatedCar = CarViewData.fromJson(Map<String, dynamic>.from(carData));
      }

      emit(ProfileLoaded(
        data: s.data.copyWith(car: updatedCar),
        isCarUpdating: false,
      ));
    } catch (e) {
      emit(ProfileLoaded(data: s.data, isCarUpdating: false));
      emit(ProfileFailure(message: "Avtomobil ma'lumotlarini saqlab bo'lmadi"));
      emit(ProfileLoaded(data: s.data));
    }
  }
}