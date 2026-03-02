enum PickMode { start, finish }

class ChooseDirectionsState {
  final PickMode mode;

  final double centerLat;
  final double centerLng;
  final String centerAddress;
  final bool loadingCenter;

  final double? startLat;
  final double? startLng;
  final String startAddress;
  final bool loadingStart;

  final double? finishLat;
  final double? finishLng;
  final String finishAddress;
  final bool loadingFinish;

  final String? error;

  const ChooseDirectionsState({
    required this.mode,
    required this.centerLat,
    required this.centerLng,
    required this.centerAddress,
    required this.loadingCenter,
    required this.startLat,
    required this.startLng,
    required this.startAddress,
    required this.loadingStart,
    required this.finishLat,
    required this.finishLng,
    required this.finishAddress,
    required this.loadingFinish,
    required this.error,
  });

  factory ChooseDirectionsState.initial(double lat, double lng) {
    return ChooseDirectionsState(
      mode: PickMode.start,
      centerLat: lat,
      centerLng: lng,
      centerAddress: 'Joy tanlanmadi',
      loadingCenter: false,
      startLat: null,
      startLng: null,
      startAddress: 'Joy tanlanmadi',
      loadingStart: false,
      finishLat: null,
      finishLng: null,
      finishAddress: 'Joy tanlanmadi',
      loadingFinish: false,
      error: null,
    );
  }

  static const _unset = Object();

  ChooseDirectionsState copyWith({
    PickMode? mode,
    double? centerLat,
    double? centerLng,
    String? centerAddress,
    bool? loadingCenter,

    Object? startLat = _unset,
    Object? startLng = _unset,
    String? startAddress,
    bool? loadingStart,

    Object? finishLat = _unset,
    Object? finishLng = _unset,
    String? finishAddress,
    bool? loadingFinish,

    String? error,
  }) {
    return ChooseDirectionsState(
      mode: mode ?? this.mode,
      centerLat: centerLat ?? this.centerLat,
      centerLng: centerLng ?? this.centerLng,
      centerAddress: centerAddress ?? this.centerAddress,
      loadingCenter: loadingCenter ?? this.loadingCenter,

      startLat: identical(startLat, _unset) ? this.startLat : startLat as double?,
      startLng: identical(startLng, _unset) ? this.startLng : startLng as double?,
      startAddress: startAddress ?? this.startAddress,
      loadingStart: loadingStart ?? this.loadingStart,

      finishLat: identical(finishLat, _unset) ? this.finishLat : finishLat as double?,
      finishLng: identical(finishLng, _unset) ? this.finishLng : finishLng as double?,
      finishAddress: finishAddress ?? this.finishAddress,
      loadingFinish: loadingFinish ?? this.loadingFinish,

      error: error,
    );
  }
}
