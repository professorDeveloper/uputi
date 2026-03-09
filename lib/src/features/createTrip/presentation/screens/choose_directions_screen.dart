import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart' as geolocator;
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mapbox;
import 'package:uputi/src/features/createTrip/presentation/blocs/trip_create_bloc.dart';
import 'package:uputi/src/helpers/flushbar.dart';
import 'package:easy_localization/easy_localization.dart' as localization;
import '../../../../core/constants/app_color.dart';
import '../../../../di/di.dart';
import '../blocs/choose_direction_bloc.dart';
import '../blocs/choose_direction_event.dart';
import '../blocs/choose_direction_state.dart';
import '../widgets/orderDetailsBottomsheet.dart';

class ChooseDirectionsResult {
  final mapbox.Position start;
  final mapbox.Position finish;
  final String startAddress;
  final String finishAddress;

  ChooseDirectionsResult({
    required this.start,
    required this.finish,
    required this.startAddress,
    required this.finishAddress,
  });
}

class ChooseDirectionsScreen extends StatefulWidget {
  const ChooseDirectionsScreen({super.key});

  @override
  State<ChooseDirectionsScreen> createState() => _ChooseDirectionsScreenState();
}

class _ChooseDirectionsScreenState extends State<ChooseDirectionsScreen> {
  mapbox.Position currentPosition = mapbox.Position(69.2157, 41.2342);

  mapbox.MapboxMap? _mapboxMap;
  mapbox.PointAnnotationManager? _annManager;

  mapbox.PointAnnotation? _startAnn;
  mapbox.PointAnnotation? _finishAnn;

  Uint8List? _aBytes;
  Uint8List? _bBytes;

  int _pointers = 0;
  Offset? _downPos;
  DateTime? _downAt;
  bool _cancelTap = false;

  @override
  void initState() {
    super.initState();
    _fetchLocation();
  }

  @override
  void dispose() {
    try {
      _annManager?.deleteAll();
    } catch (_) {}
    super.dispose();
  }

  Future<geolocator.Position?> _getCurrentLocation() async {
    try {
      var permission = await geolocator.Geolocator.checkPermission();
      if (permission == geolocator.LocationPermission.denied) {
        permission = await geolocator.Geolocator.requestPermission();
        if (permission == geolocator.LocationPermission.denied) return null;
      }
      if (permission == geolocator.LocationPermission.deniedForever)
        return null;

      return await geolocator.Geolocator.getCurrentPosition(
        desiredAccuracy: geolocator.LocationAccuracy.high,
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> _fetchLocation() async {
    final pos = await _getCurrentLocation();
    if (pos == null) return;

    final lat = pos.latitude;
    final lng = pos.longitude;

    setState(() {
      currentPosition = mapbox.Position(lng, lat);
    });

    final m = _mapboxMap;
    if (m != null) {
      await _moveCamera(currentPosition, zoom: 15.8);
    }

    if (!mounted) return;
    context.read<ChooseDirectionsBloc>().add(
      ChooseDirectionsCenterChanged(lat: lat, lng: lng),
    );
  }

  void _onMapCreated(mapbox.MapboxMap mapboxMap) async {
    _mapboxMap = mapboxMap;

    await _moveCamera(currentPosition, zoom: 15.8);

    _annManager ??= await mapboxMap.annotations.createPointAnnotationManager();

    _aBytes ??= await _buildLetterPinBytes(
      letter: 'A',
      badgeColor: AppColor.blueMain,
    );
    _bBytes ??= await _buildLetterPinBytes(
      letter: 'B',
      badgeColor: AppColor.blueMain,
    );

    await _lockToUzbekistan();

    if (!mounted) return;
    final s = context.read<ChooseDirectionsBloc>().state;
    await _syncMarkersFromState(s);

    context.read<ChooseDirectionsBloc>().add(
      ChooseDirectionsCenterChanged(
        lat: currentPosition.lat.toDouble(),
        lng: currentPosition.lng.toDouble(),
      ),
    );
  }

  Future<void> _lockToUzbekistan() async {
    final m = _mapboxMap;
    if (m == null) return;

    final sw = mapbox.Point(coordinates: mapbox.Position(55.99, 37.17));
    final ne = mapbox.Point(coordinates: mapbox.Position(73.20, 45.60));

    await m.setBounds(
      mapbox.CameraBoundsOptions(
        bounds: mapbox.CoordinateBounds(
          southwest: sw,
          northeast: ne,
          infiniteBounds: false,
        ),
        minZoom: 5.2,
        maxZoom: 19.0,
      ),
    );
  }

  Future<void> _moveCamera(mapbox.Position pos, {double zoom = 16.6}) async {
    final m = _mapboxMap;
    if (m == null) return;

    await m.setCamera(
      mapbox.CameraOptions(
        center: mapbox.Point(coordinates: pos),
        zoom: zoom,
        pitch: 0,
        bearing: 0,
      ),
    );
  }

  void _onPointerDown(PointerDownEvent e) {
    _pointers += 1;
    if (_pointers == 1) {
      _downPos = e.localPosition;
      _downAt = DateTime.now();
      _cancelTap = false;
      return;
    }
    _cancelTap = true;
  }

  void _onPointerMove(PointerMoveEvent e) {
    final p = _downPos;
    if (p == null) return;
    if ((e.localPosition - p).distance > 12) _cancelTap = true;
  }

  void _resetTap() {
    _pointers = 0;
    _downPos = null;
    _downAt = null;
    _cancelTap = false;
  }

  Future<void> _onPointerUp(PointerUpEvent e) async {
    _pointers = (_pointers - 1).clamp(0, 10);
    if (_pointers != 0) return;

    final downPos = _downPos;
    final downAt = _downAt;
    final cancel = _cancelTap;

    _resetTap();

    if (downPos == null || downAt == null) return;
    if (cancel) return;

    final dt = DateTime.now().difference(downAt).inMilliseconds;
    if (dt > 300) return;

    await _pickFromPixel(downPos);
  }

  void _onPointerCancel(PointerCancelEvent e) {
    _resetTap();
  }

  Future<void> _pickFromPixel(Offset px) async {
    final m = _mapboxMap;
    if (m == null) return;

    final point = await m.coordinateForPixel(
      mapbox.ScreenCoordinate(x: px.dx, y: px.dy),
    );

    final lat = point.coordinates.lat;
    final lng = point.coordinates.lng;

    if (!mounted) return;

    context.read<ChooseDirectionsBloc>().add(
      ChooseDirectionsPickAt(lat: lat.toDouble(), lng: lng.toDouble()),
    );
  }

  void _removeStartMarker() {
    final ann = _startAnn;
    if (ann == null) return;
    _startAnn = null;
    _annManager?.delete(ann).catchError((_) {});
  }

  void _removeFinishMarker() {
    final ann = _finishAnn;
    if (ann == null) return;
    _finishAnn = null;
    _annManager?.delete(ann).catchError((_) {});
  }

  Future<void> _setMarker({
    required bool isStart,
    required mapbox.Position pos,
  }) async {
    final mgr = _annManager;
    if (mgr == null) return;

    final bytes = isStart ? _aBytes : _bBytes;
    if (bytes == null) return;

    if (isStart && _startAnn != null) {
      _startAnn = _startAnn!..geometry = mapbox.Point(coordinates: pos);
      await mgr.update(_startAnn!);
      return;
    }

    if (!isStart && _finishAnn != null) {
      _finishAnn = _finishAnn!..geometry = mapbox.Point(coordinates: pos);
      await mgr.update(_finishAnn!);
      return;
    }

    final created = await mgr.create(
      mapbox.PointAnnotationOptions(
        geometry: mapbox.Point(coordinates: pos),
        image: bytes,
        iconAnchor: mapbox.IconAnchor.BOTTOM,
        iconSize: 0.85,
      ),
    );

    if (isStart) {
      _startAnn = created;
    } else {
      _finishAnn = created;
    }
  }

  Future<void> _syncMarkersFromState(ChooseDirectionsState s) async {
    if (!mounted) return;

    if (s.startLat != null && s.startLng != null) {
      await _setMarker(
        isStart: true,
        pos: mapbox.Position(s.startLng!, s.startLat!),
      );
    } else {
      _removeStartMarker();
    }

    if (s.finishLat != null && s.finishLng != null) {
      await _setMarker(
        isStart: false,
        pos: mapbox.Position(s.finishLng!, s.finishLat!),
      );
    } else {
      _removeFinishMarker();
    }
  }

  Future<void> _continue(ChooseDirectionsState s) async {
    final ready =
        (s.error ?? '').isEmpty &&
        s.startLat != null &&
        s.startLng != null &&
        s.finishLat != null &&
        s.finishLng != null &&
        !s.loadingStart &&
        !s.loadingFinish;

    if (!ready) return;

    final ok = await showTripDetailsBottomSheet(
      context: context,
      bloc: sl<TripCreateBloc>(),
      fromAddress: s.startAddress,
      toAddress: s.finishAddress,
      fromLat: s.startLat!,
      fromLng: s.startLng!,
      toLat: s.finishLat!,
      toLng: s.finishLng!,
      primaryBlue: AppColor.blueMain,
    );

    if (!mounted) return;

    if (ok == true) {
      Navigator.of(context).pop(true);
    }
  }

  Future<Uint8List> _buildLetterPinBytes({
    required String letter,
    required Color badgeColor,
    double size = 200,
  }) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    final w = size;
    final h = size;

    final circleR = w * 0.20;
    final circleC = Offset(w / 2, h * 0.26);

    final stickTop = Offset(w / 2, circleC.dy + circleR - w * 0.01);
    final stickBottom = Offset(w / 2, h * 0.82);

    final circleShadowPaint = Paint()
      ..isAntiAlias = true
      ..color = const Color(0x33000000);

    canvas.drawCircle(
      circleC.translate(0, w * 0.03),
      circleR,
      circleShadowPaint,
    );

    final stickShadowPaint = Paint()
      ..isAntiAlias = true
      ..strokeWidth = w * 0.030
      ..strokeCap = StrokeCap.round
      ..color = const Color(0x22000000);

    canvas.drawLine(
      stickTop.translate(0, w * 0.03),
      stickBottom.translate(0, w * 0.03),
      stickShadowPaint,
    );

    final circlePaint = Paint()
      ..isAntiAlias = true
      ..color = badgeColor;

    canvas.drawCircle(circleC, circleR, circlePaint);

    final stickPaint = Paint()
      ..isAntiAlias = true
      ..strokeWidth = w * 0.028
      ..strokeCap = StrokeCap.round
      ..color = const Color(0xFF111827);

    canvas.drawLine(stickTop, stickBottom, stickPaint);

    final groundShadowPaint = Paint()
      ..isAntiAlias = true
      ..color = const Color(0x26000000);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: stickBottom.translate(0, w * 0.045),
          width: w * 0.14,
          height: w * 0.050,
        ),
        Radius.circular(w),
      ),
      groundShadowPaint,
    );

    final tp = TextPainter(
      text: TextSpan(
        text: letter,
        style: TextStyle(
          fontSize: w * 0.18,
          fontWeight: FontWeight.w800,
          color: Colors.white,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    tp.paint(
      canvas,
      Offset(circleC.dx - tp.width / 2, circleC.dy - tp.height / 2),
    );

    final picture = recorder.endRecording();
    final image = await picture.toImage(w.toInt(), h.toInt());
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    return bytes!.buffer.asUint8List();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ChooseDirectionsBloc, ChooseDirectionsState>(
      listenWhen: (p, c) =>
          p.startLat != c.startLat ||
          p.startLng != c.startLng ||
          p.finishLat != c.finishLat ||
          p.finishLng != c.finishLng ||
          p.error != c.error ||
          p.loadingStart != c.loadingStart ||
          p.loadingFinish != c.loadingFinish,
      listener: (context, state) async {
        await _syncMarkersFromState(state);
      },
      builder: (context, state) {
        final hasStart = state.startLat != null && state.startLng != null;
        final hasFinish = state.finishLat != null && state.finishLng != null;

        final ready =
            (state.error ?? '').isEmpty &&
            hasStart &&
            hasFinish &&
            !state.loadingStart &&
            !state.loadingFinish;

        final startTitle = hasStart
            ? state.startAddress
            : localization.tr("map_select_a");
        final finishTitle = hasFinish
            ? state.finishAddress
            : localization.tr("map_select_b");

        return Scaffold(
          body: Column(
            children: [
              Expanded(
                child: Stack(
                  children: [
                    mapbox.MapWidget(
                      key: const ValueKey('mapWidget'),
                      styleUri: mapbox.MapboxStyles.MAPBOX_STREETS,
                      onMapCreated: _onMapCreated,
                      cameraOptions: mapbox.CameraOptions(
                        center: mapbox.Point(coordinates: currentPosition),
                        zoom: 15.8,
                        pitch: 0,
                        bearing: 0,
                      ),
                    ),
                    Positioned.fill(
                      child: Listener(
                        behavior: HitTestBehavior.translucent,
                        onPointerDown: _onPointerDown,
                        onPointerMove: _onPointerMove,
                        onPointerUp: _onPointerUp,
                        onPointerCancel: _onPointerCancel,
                        child: const SizedBox.expand(),
                      ),
                    ),
                    Positioned(
                      bottom: 16,
                      left: 16,
                      child: SizedBox(
                        height: 50,
                        width: 50,
                        child: FloatingActionButton(
                          elevation: 1,
                          highlightElevation: 1,
                          backgroundColor: Colors.white,
                          shape: const CircleBorder(),
                          onPressed: () => Navigator.of(context).maybePop(),
                          child: const Icon(
                            Icons.arrow_back,
                            color: Colors.black,
                            size: 25,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 16,
                      right: 16,
                      child: SizedBox(
                        height: 50,
                        width: 50,
                        child: FloatingActionButton(
                          elevation: 1,
                          highlightElevation: 1,
                          backgroundColor: Colors.white,
                          shape: const CircleBorder(),
                          onPressed: _fetchLocation,
                          child: Icon(
                            Icons.location_on_outlined,
                            color: AppColor.blueMain,
                            size: 25,
                          ),
                        ),
                      ),
                    ),
                    if ((state.error ?? '').isNotEmpty)
                      Positioned(
                        left: 16,
                        right: 16,
                        top: 56,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: const [
                              BoxShadow(
                                blurRadius: 16,
                                offset: Offset(0, 8),
                                color: Color(0x18000000),
                              ),
                            ],
                          ),
                          child: Text(
                            state.error!,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFFB91C1C),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.white,
                child: Column(
                  children: [
                    _SelectCard(
                      leading: _Badge(
                        letter: 'A',
                        active: state.mode == PickMode.start,
                      ),
                      title: startTitle,
                      loading: state.loadingStart,
                      active: state.mode == PickMode.start,
                      showClear: hasStart,
                      onClear: () {
                        _removeStartMarker();
                        context.read<ChooseDirectionsBloc>().add(
                          ChooseDirectionsClearA(),
                        );
                      },
                      onTap: () async {
                        context.read<ChooseDirectionsBloc>().add(
                          ChooseDirectionsSwitchToA(),
                        );
                        if (hasStart) {
                          await _moveCamera(
                            mapbox.Position(state.startLng!, state.startLat!),
                            zoom: 15.8,
                          );
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    _SelectCard(
                      leading: _Badge(
                        letter: 'B',
                        active: state.mode == PickMode.finish,
                      ),
                      title: finishTitle,
                      loading: state.loadingFinish,
                      active: state.mode == PickMode.finish,
                      showClear: hasFinish,
                      onClear: () {
                        _removeFinishMarker();
                        context.read<ChooseDirectionsBloc>().add(
                          ChooseDirectionsClearB(),
                        );
                      },
                      onTap: () async {
                        context.read<ChooseDirectionsBloc>().add(
                          ChooseDirectionsSwitchToB(),
                        );
                        if (hasFinish) {
                          await _moveCamera(
                            mapbox.Position(state.finishLng!, state.finishLat!),
                            zoom: 15.8,
                          );
                        }
                      },
                    ),
                    const SizedBox(height: 14),

                    if (ready)
                      SizedBox(
                        width: double.infinity,
                        child: MaterialButton(
                          onPressed: () => _continue(state),
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          elevation: 0,
                          highlightElevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          color: AppColor.blueMain,
                          textColor: Colors.white,
                          child: Text(localization.tr("map_continue")),
                        ),
                      )
                    else
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF2F5),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: const Color(0xFFE5E7EB)),
                        ),
                        alignment: Alignment.center,
                        child: const Text(
                          'Joy tanlanmadi',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SelectCard extends StatelessWidget {
  final Widget leading;
  final String title;
  final bool active;
  final bool loading;

  final VoidCallback onTap;

  final bool showClear;
  final VoidCallback? onClear;

  const _SelectCard({
    required this.leading,
    required this.title,
    required this.active,
    required this.loading,
    required this.onTap,
    this.showClear = false,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFEFF2F5),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: active ? AppColor.blueMain : Colors.transparent,
            width: 1.2,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: onTap,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      leading,
                      const SizedBox(width: 14),
                      Expanded(
                        child: loading
                            ? const _ShimmerLine(height: 14)
                            : Text(
                                title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: -0.30,
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (showClear && !loading)
              Padding(
                padding: const EdgeInsets.only(right: 6),
                child: IconButton(
                  splashRadius: 18,
                  onPressed: onClear,
                  icon: const Icon(
                    Icons.close_rounded,
                    size: 20,
                    color: Color(0xFF6B7280),
                  ),
                  tooltip: 'Tozalash',
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String letter;
  final bool active;

  const _Badge({required this.letter, required this.active});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 26,
      height: 26,
      decoration: BoxDecoration(
        color: active ? AppColor.blueMain : const Color(0xFF90A4AE),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        letter,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _ShimmerLine extends StatefulWidget {
  final double height;

  const _ShimmerLine({required this.height});

  @override
  State<_ShimmerLine> createState() => _ShimmerLineState();
}

class _ShimmerLineState extends State<_ShimmerLine>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, _) {
          final t = _c.value;
          return ShaderMask(
            shaderCallback: (rect) {
              return LinearGradient(
                begin: Alignment(-1 + 2 * t, 0),
                end: Alignment(1 + 2 * t, 0),
                colors: const [
                  Color(0xFFCBD5E1),
                  Color(0xFFF1F5F9),
                  Color(0xFFCBD5E1),
                ],
                stops: const [0.0, 0.5, 1.0],
              ).createShader(rect);
            },
            blendMode: BlendMode.srcIn,
            child: Container(
              height: widget.height,
              width: double.infinity,
              color: const Color(0xFFCBD5E1),
            ),
          );
        },
      ),
    );
  }
}
