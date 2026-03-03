// lib/src/features/searchDriver/presentation/screens/driver_city_search_tab.dart

import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mapbox;
import 'package:uputi/src/helpers/flushbar.dart';

import '../../../../core/constants/app_color.dart';
import '../../../searchPassenger/data/models/search_city_trip_response.dart';
import '../bloc/driver_city_search_bloc.dart';
import '../bloc/driver_search_trips_bloc.dart';

class DriverCitySearchTab extends StatefulWidget {
  const DriverCitySearchTab({super.key});

  @override
  State<DriverCitySearchTab> createState() => _DriverCitySearchTabState();
}

class _DriverCitySearchTabState extends State<DriverCitySearchTab> {
  static const double _defaultLat = 41.311081;
  static const double _defaultLng = 69.240562;

  mapbox.MapboxMap? _map;
  mapbox.PointAnnotationManager? _mgr;

  double _lastLat = _defaultLat;
  double _lastLng = _defaultLng;

  bool _booted = false;

  final Map<String, CityTripItem> _annTrip = {};
  Uint8List? _personMarkerBytes;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _load();
      if (mounted) setState(() => _booted = true);
    });
  }

  @override
  void dispose() {
    try {
      _mgr?.deleteAll();
    } catch (_) {}
    super.dispose();
  }

  Future<void> _load() async {
    final pos = await _getLocation();
    _lastLat = pos?.latitude ?? _defaultLat;
    _lastLng = pos?.longitude ?? _defaultLng;

    if (!mounted) return;

    context.read<DriverCitySearchBloc>().add(
      DriverCitySearchRequested(lat: _lastLat, lng: _lastLng),
    );

    await _moveCamera(lat: _lastLat, lng: _lastLng, zoom: 12.8);
  }

  Future<geo.Position?> _getLocation() async {
    try {
      var permission = await geo.Geolocator.checkPermission();
      if (permission == geo.LocationPermission.denied) {
        permission = await geo.Geolocator.requestPermission();
        if (permission == geo.LocationPermission.denied) return null;
      }
      if (permission == geo.LocationPermission.deniedForever) return null;

      return await geo.Geolocator.getCurrentPosition(
        desiredAccuracy: geo.LocationAccuracy.high,
      );
    } catch (_) {
      return null;
    }
  }

  void _onMapCreated(mapbox.MapboxMap map) async {
    _map = map;

    _mgr ??= await map.annotations.createPointAnnotationManager();

    _personMarkerBytes ??= await _buildPersonMarkerBytes(
      size: 120,
      bg: const Color(0xFF16A34A),
    );

    _mgr?.addOnPointAnnotationClickListener(
      _TripAnnClickListener((ann) {
        final trip = _annTrip[ann.id];
        if (trip != null) _openTripSheet(trip);
      }),
    );

    await _moveCamera(lat: _lastLat, lng: _lastLng, zoom: 10.8);
  }

  Future<void> _moveCamera({
    required double lat,
    required double lng,
    double zoom = 10.8,
  }) async {
    final m = _map;
    if (m == null) return;

    await m.setCamera(
      mapbox.CameraOptions(
        center: mapbox.Point(coordinates: mapbox.Position(lng, lat)),
        zoom: zoom,
        pitch: 0,
        bearing: 0,
      ),
    );
  }

  Future<void> _syncMarkers(List<CityTripItem> trips) async {
    final mgr = _mgr;
    if (mgr == null) return;

    try {
      await mgr.deleteAll();
    } catch (_) {}

    _annTrip.clear();

    final bytes = _personMarkerBytes;
    if (bytes == null) return;

    for (final t in trips) {
      final lat = double.tryParse((t.fromLat ?? '').trim());
      final lng = double.tryParse((t.fromLng ?? '').trim());
      if (lat == null || lng == null) continue;

      final ann = await mgr.create(
        mapbox.PointAnnotationOptions(
          geometry: mapbox.Point(coordinates: mapbox.Position(lng, lat)),
          image: bytes,
          iconAnchor: mapbox.IconAnchor.BOTTOM,
          iconSize: 1.32,
        ),
      );

      _annTrip[ann.id] = t;
    }
  }

  Future<void> _openTripSheet(CityTripItem t) async {
    if (!mounted) return;

    final parentContext = context;
    final searchBloc = parentContext.read<DriverSearchTripsBloc>();

    await showModalBottomSheet(
      context: parentContext,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      clipBehavior: Clip.antiAlias,
      builder: (sheetContext) {
        return BlocProvider.value(
          value: searchBloc,
          child: BlocConsumer<DriverSearchTripsBloc, DriverSearchTripsState>(
            listenWhen: (p, c) {
              if (c is! DriverSearchTripsLoaded) return false;
              if (p is! DriverSearchTripsLoaded) return true;
              return p.actionMessage != c.actionMessage ||
                  p.actionError != c.actionError ||
                  p.actionLoading != c.actionLoading;
            },
            listener: (_, state) {
              final s = state as DriverSearchTripsLoaded;
              final msg = (s.actionMessage ?? '').trim();
              final err = (s.actionError ?? '').trim();
              if (msg.isNotEmpty) showSuccessFlushBar(msg).show(context);
              if (err.isNotEmpty) showErrorFlushBar(err).show(context);
            },
            builder: (_, state) {
              final actionLoading =
              state is DriverSearchTripsLoaded ? state.actionLoading : false;

              return _DriverCityTripBottomSheet(
                trip: t,
                actionLoading: actionLoading,
                onAccept: () {
                  if (actionLoading) return;

                  final tripId = int.tryParse('${t.id}');
                  if (tripId == null) {
                    showErrorFlushBar("Trip id noto'g'ri").show(parentContext);
                    return;
                  }

                  Navigator.of(sheetContext).pop();

                  searchBloc.add(
                    DriverSearchCreateBookingRequested(tripId: tripId),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<DriverCitySearchBloc, DriverCitySearchState>(
          listenWhen: (p, c) =>
          c is DriverCitySearchLoaded || c is DriverCitySearchError,
          listener: (context, state) async {
            if (state is DriverCitySearchLoaded) {
              await _syncMarkers(state.response.items);
            } else if (state is DriverCitySearchError) {
              showErrorFlushBar(state.message).show(context);
            }
          },
        ),
        BlocListener<DriverSearchTripsBloc, DriverSearchTripsState>(
          listenWhen: (p, c) {
            if (c is! DriverSearchTripsLoaded) return false;
            if (p is! DriverSearchTripsLoaded) return true;
            return p.actionMessage != c.actionMessage ||
                p.actionError != c.actionError ||
                p.actionLoading != c.actionLoading;
          },
          listener: (context, state) {
            final s = state as DriverSearchTripsLoaded;
            final msg = (s.actionMessage ?? '').trim();
            final err = (s.actionError ?? '').trim();
            if (msg.isNotEmpty) showSuccessFlushBar(msg).show(context);
            if (err.isNotEmpty) showErrorFlushBar(err).show(context);
          },
        ),
      ],
      child: BlocBuilder<DriverCitySearchBloc, DriverCitySearchState>(
        builder: (context, state) {
          final loading = state is DriverCitySearchLoading ||
              (!_booted && state is DriverCitySearchInitial);
          final tripsCount = state is DriverCitySearchLoaded
              ? state.response.items.length
              : null;

          return Stack(
            children: [
              mapbox.MapWidget(
                key: const ValueKey("driver_city_map"),
                styleUri: mapbox.MapboxStyles.MAPBOX_STREETS,
                onMapCreated: _onMapCreated,
                cameraOptions: mapbox.CameraOptions(
                  center: mapbox.Point(
                    coordinates: mapbox.Position(_lastLng, _lastLat),
                  ),
                  zoom: 10.8,
                  pitch: 0,
                  bearing: 0,
                ),
              ),
              Positioned(
                left: 12,
                right: 12,
                top: 12,
                child: _TopCard(
                  title: "Shahar ichida",
                  subtitle: tripsCount == null
                      ? "Joylashuv bo'yicha qidiruv"
                      : "Topildi: $tripsCount",
                  onRefresh: loading ? null : _load,
                ),
              ),
              Positioned(
                right: 16,
                bottom: 18,
                child: SizedBox(
                  height: 50,
                  width: 50,
                  child: FloatingActionButton(
                    elevation: 1,
                    highlightElevation: 1,
                    backgroundColor: Colors.white,
                    shape: const CircleBorder(),
                    onPressed: loading ? null : _load,
                    child: Icon(
                      Icons.location_on_outlined,
                      color: AppColor.blueMain,
                      size: 25,
                    ),
                  ),
                ),
              ),
              if (loading)
                const Positioned(
                  left: 0,
                  right: 0,
                  bottom: 24,
                  child: Center(child: CircularProgressIndicator()),
                ),
            ],
          );
        },
      ),
    );
  }

  // ── Person marker (yashil - yo'lovchi) ────────────────────────────────────
  Future<Uint8List> _buildPersonMarkerBytes({
    required double size,
    required Color bg,
  }) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final w = size;
    final h = size;

    canvas.drawCircle(
      Offset(w / 2, h / 2 + w * 0.07),
      w * 0.30,
      Paint()
        ..isAntiAlias = true
        ..color = const Color(0x22000000),
    );
    canvas.drawCircle(
      Offset(w / 2, h / 2),
      w * 0.30,
      Paint()
        ..isAntiAlias = true
        ..color = Colors.white,
    );
    canvas.drawCircle(
      Offset(w / 2, h / 2),
      w * 0.22,
      Paint()
        ..isAntiAlias = true
        ..color = bg,
    );

    final tp = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(Icons.person.codePoint),
        style: TextStyle(
          fontSize: w * 0.22,
          fontFamily: Icons.person.fontFamily,
          package: Icons.person.fontPackage,
          color: Colors.white,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(w / 2 - tp.width / 2, h / 2 - tp.height / 2));

    final path = Path()
      ..moveTo(w / 2, h * 0.92)
      ..lineTo(w * 0.44, h * 0.70)
      ..lineTo(w * 0.56, h * 0.70)
      ..close();
    canvas.drawPath(
      path,
      Paint()
        ..isAntiAlias = true
        ..color = Colors.white,
    );

    final picture = recorder.endRecording();
    final image = await picture.toImage(w.toInt(), h.toInt());
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    return bytes!.buffer.asUint8List();
  }
}

// ─── Annotation click listener ──────────────────────────────────────────────

class _TripAnnClickListener extends mapbox.OnPointAnnotationClickListener {
  final void Function(mapbox.PointAnnotation) onTap;
  _TripAnnClickListener(this.onTap);

  @override
  void onPointAnnotationClick(mapbox.PointAnnotation annotation) =>
      onTap(annotation);
}

// ─── Top info card ──────────────────────────────────────────────────────────

class _TopCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback? onRefresh;

  const _TopCard({
    required this.title,
    required this.subtitle,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 0,
      borderRadius: BorderRadius.circular(18),
      color: Colors.white,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE5E7EB)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 18,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: const TextStyle(color: Color(0xFF6B7280))),
                ],
              ),
            ),
            IconButton(
              onPressed: onRefresh,
              icon: const Icon(Icons.refresh),
              splashRadius: 18,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Bottom sheet for city trip (ONLY bron qilish, NO taklif) ───────────────

class _DriverCityTripBottomSheet extends StatelessWidget {
  final CityTripItem trip;
  final VoidCallback onAccept;
  final bool actionLoading;

  const _DriverCityTripBottomSheet({
    required this.trip,
    required this.onAccept,
    required this.actionLoading,
  });

  @override
  Widget build(BuildContext context) {
    final from = (trip.fromAddress ?? '-').trim();
    final to = (trip.toAddress ?? '-').trim();
    final date = (trip.date ?? '-').trim();
    final time = _shortTime((trip.time ?? '-').trim());
    final seats = (trip.seats ?? '-').toString();
    final amount = trip.amount;
    final price = _money(amount is int ? amount : int.tryParse('$amount') ?? 0);
    final name = (trip.user?.name ?? "Yo'lovchi").trim();
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'Y';

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          16, 10, 16,
          16 + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle + close
              SizedBox(
                width: double.infinity,
                height: 44,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 44,
                      height: 5,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE5E7EB),
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                    Positioned(
                      right: 0,
                      child: IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                        splashRadius: 18,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              _SheetInfoRow(
                label: "Qayerdan",
                value: from,
                icon: Icons.location_on,
              ),
              const SizedBox(height: 10),
              _SheetInfoRow(label: "Qayerga", value: to, icon: Icons.flag),
              const SizedBox(height: 14),

              Row(
                children: [
                  Expanded(
                    child: _SheetInfoTile(
                      label: "Sana", value: date, icon: Icons.calendar_today,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _SheetInfoTile(
                      label: "Vaqt", value: time, icon: Icons.access_time,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _SheetInfoTile(
                      label: "O'rinlar",
                      value: seats,
                      icon: Icons.people_alt_outlined,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _SheetInfoTile(
                      label: "Narx",
                      value: price,
                      icon: Icons.payments_outlined,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Yo'lovchi info
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FFF4),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFBBF7D0)),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: const Color(0xFF16A34A),
                      child: Text(
                        initial,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        name.isEmpty ? "Yo'lovchi" : name,
                        style: const TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF111827),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Faqat Qabul qilish — taklif yo'q
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: actionLoading ? null : onAccept,
                  icon: actionLoading
                      ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                      : const Icon(Icons.check_circle_outline),
                  label: const Text(
                    "Qabul qilish",
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: const Color(0xFF16A34A),
                    foregroundColor: Colors.white,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  String _shortTime(String t) {
    final s = t.trim();
    if (s.isEmpty) return "-";
    return s.length >= 5 ? s.substring(0, 5) : s;
  }

  String _money(int amount) {
    final str = amount.toString();
    final buf = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      final left = str.length - i;
      buf.write(str[i]);
      if (left > 1 && left % 3 == 1) buf.write(' ');
    }
    return "${buf.toString()} UZS";
  }
}

// ─── Shared sub-widgets ─────────────────────────────────────────────────────

class _SheetInfoRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _SheetInfoRow({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: const Color(0xFF6B7280)),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(
                      color: Color(0xFF6B7280), fontSize: 12)),
              const SizedBox(height: 2),
              Text(value,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF111827),
                  )),
            ],
          ),
        ),
      ],
    );
  }
}

class _SheetInfoTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _SheetInfoTile({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: const Color(0xFF6B7280)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        color: Color(0xFF6B7280), fontSize: 12)),
                const SizedBox(height: 2),
                Text(value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF111827),
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}