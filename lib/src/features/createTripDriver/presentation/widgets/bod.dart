import 'package:easy_localization/easy_localization.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mapbox;

import '../../../../core/constants/app_color.dart';
import '../../../../di/di.dart';
import '../bloc/create_trip_bloc.dart';
import '../bloc/create_trip_event.dart';
import '../bloc/create_trip_state.dart';

class DriverIntercityTripForm extends StatelessWidget {
  const DriverIntercityTripForm({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<DriverTripCreateBloc>(),
      child: const _DriverBody(),
    );
  }
}

class _DriverBody extends StatefulWidget {
  const _DriverBody();

  @override
  State<_DriverBody> createState() => _DriverBodyState();
}

class _DriverBodyState extends State<_DriverBody> {
  String? fromRegion;
  String? toRegion;
  final _commentCtrl = TextEditingController();

  final Map<String, mapbox.Position> regionCenters = {
    "Toshkent": mapbox.Position(69.2401, 41.2995),
    "Samarqand": mapbox.Position(66.9597, 39.6542),
    "Buxoro": mapbox.Position(64.4200, 39.7747),
    "Farg'ona": mapbox.Position(71.7864, 40.3894),
    "Andijon": mapbox.Position(72.3442, 40.7821),
    "Namangan": mapbox.Position(71.6726, 41.0011),
    "Qashqadaryo": mapbox.Position(65.7833, 38.8667),
    "Surxondaryo": mapbox.Position(67.2783, 37.2242),
    "Jizzax": mapbox.Position(67.8422, 40.1158),
    "Sirdaryo": mapbox.Position(68.6617, 40.5014),
    "Xorazm": mapbox.Position(60.6167, 41.5500),
    "Navoiy": mapbox.Position(65.3750, 40.0844),
    "Qoraqalpog'iston": mapbox.Position(59.6100, 42.4600),
  };

  bool get hasRoute => fromRegion != null && toRegion != null;

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final regions = regionCenters.keys.toList()..sort();

    return BlocConsumer<DriverTripCreateBloc, DriverTripCreateState>(
      listenWhen: (p, c) => p.status != c.status,
      listener: (context, s) async {
        if (s.status == DriverTripCreateStatus.success) {
          await _showSuccessFlushbar(context, "Sayohat yaratildi");
          if (!context.mounted) return;
          Navigator.of(context).pop(true);
        }
        if (s.status == DriverTripCreateStatus.failure) {
          await _showErrorFlushbar(
            context,
            s.errorMessage ?? "Xatolik yuz berdi",
          );
        }
      },
      builder: (context, s) {
        final loading = s.status == DriverTripCreateStatus.submitting;
        final canSubmit = hasRoute && s.canSubmit && !loading;

        final fromPos = hasRoute
            ? regionCenters[fromRegion!]!
            : regionCenters["Toshkent"]!;
        final toPos = hasRoute
            ? regionCenters[toRegion!]!
            : regionCenters["Samarqand"]!;

        return Stack(
          children: [
            ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 104),
              children: [

                 _SectionTitle('section_direction'.tr()),
                const SizedBox(height: 10),
                _SoftSelectField(
                  label: 'field_from'.tr(),
                  value: fromRegion,
                  placeholder: 'placeholder_select'.tr(),
                  enabled: !loading,
                  onTap: () async {
                    final picked = await _pickFromListBottomSheet(
                      context,
                      title: 'label_from_region'.tr(),
                      items: regions,
                    );
                    if (picked != null) setState(() => fromRegion = picked);
                  },
                ),
                const SizedBox(height: 12),
                _SoftSelectField(
                  label: 'field_to'.tr(),
                  value: toRegion,
                  placeholder: 'placeholder_select'.tr(),
                  enabled: !loading,
                  onTap: () async {
                    final picked = await _pickFromListBottomSheet(
                      context,
                      title: 'label_to_region'.tr(),
                      items: regions,
                    );
                    if (picked != null) setState(() => toRegion = picked);
                  },
                ),

                const SizedBox(height: 18),

                // ── Tafsilotlar ───────────────────────────────────────────
                 _SectionTitle('section_details'.tr()),
                const SizedBox(height: 10),
                _SoftSelectField(
                  label: 'field_date'.tr(),
                  value: _fmtDateUz(s.date),
                  placeholder: 'placeholder_select'.tr(),
                  enabled: !loading,
                  onTap: () async {
                    final picked = await _pickCupertinoDateSheet(
                      context,
                      title: 'label_select_date'.tr(),
                      initial: s.date,
                    );
                    if (picked == null) return;
                    if (!context.mounted) return;
                    context.read<DriverTripCreateBloc>().add(
                      DriverTripCreateDateChanged(
                        DateTime(picked.year, picked.month, picked.day),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),
                _SoftSelectField(
                  label: 'field_time'.tr(),
                  value: _fmtTime(s.time),
                  placeholder: 'placeholder_select'.tr(),
                  enabled: !loading,
                  onTap: () async {
                    final picked = await _pickCupertinoTimeSheet(
                      context,
                      title: 'label_select_time'.tr(),
                      initial: s.time,
                    );
                    if (picked == null) return;
                    if (!context.mounted) return;
                    context.read<DriverTripCreateBloc>().add(
                      DriverTripCreateTimeChanged(picked),
                    );
                  },
                ),
                const SizedBox(height: 12),
                _SoftSelectField(
                  label: "Bo'sh o'rinlar",
                  value: "${s.seats}",
                  placeholder: 'placeholder_select'.tr(),
                  enabled: !loading,
                  onTap: () async {
                    final picked = await _pickSeatsBottomSheet(
                      context,
                      initial: s.seats,
                      min: 1,
                      max: 4,
                    );
                    if (picked == null) return;
                    if (!context.mounted) return;
                    context.read<DriverTripCreateBloc>().add(
                      DriverTripCreateSeatsChanged(picked),
                    );
                  },
                ),
                const SizedBox(height: 12),
                _SoftMoneyField(
                  label: 'field_price'.tr(),
                  enabled: !loading,
                  value: s.amount,
                  onChanged: (v) => context.read<DriverTripCreateBloc>().add(
                    DriverTripCreateAmountChanged(v),
                  ),
                ),

                const SizedBox(height: 18),

                const _SectionTitle("Izoh"),
                const SizedBox(height: 10),
                _SoftTextAreaField(
                  label: 'field_comment'.tr(),
                  controller: _commentCtrl,
                  enabled: !loading,
                  hint: 'field_comment_hint'.tr(),
                  onChanged: (v) => context.read<DriverTripCreateBloc>().add(
                    DriverTripCreateCommentChanged(v),
                  ),
                ),
              ],
            ),

            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _StickyFooter(
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: canSubmit
                        ? () {
                      context.read<DriverTripCreateBloc>().add(
                        DriverTripCreateSubmitted(
                          fromLat: fromPos.lat.toDouble(),
                          fromLng: fromPos.lng.toDouble(),
                          fromAddress: fromRegion!,
                          toLat: toPos.lat.toDouble(),
                          toLng: toPos.lng.toDouble(),
                          toAddress: toRegion!,
                        ),
                      );
                    }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColor.blueMain,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      textStyle: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        letterSpacing: -0.1,
                      ),
                    ),
                    child: Text(
                      loading ? "Yaratilmoqda..." : "Sayohat yaratish",
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ─── Section title ───────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 14.5,
        fontWeight: FontWeight.w700,
        color: Color(0xFF111827),
        letterSpacing: -0.1,
      ),
    );
  }
}

// ─── Soft select field ────────────────────────────────────────────────────────

class _SoftSelectField extends StatelessWidget {
  final String label;
  final String? value;
  final String placeholder;
  final bool enabled;
  final VoidCallback onTap;

  const _SoftSelectField({
    required this.label,
    required this.value,
    required this.placeholder,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bg = enabled ? const Color(0xFFF5F7FF) : const Color(0xFFF3F4F6);
    final border = enabled ? const Color(0xFFE6ECFF) : const Color(0xFFE5E7EB);
    final v = (value == null || value!.trim().isEmpty) ? placeholder : value!;
    final isPlaceholder = v == placeholder;

    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(minHeight: 64),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: border),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF8B95A7),
                      height: 1.1,
                      letterSpacing: -0.1,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    v,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 16.5,
                      fontWeight: FontWeight.w600,
                      color: isPlaceholder
                          ? const Color(0xFFB0B7C3)
                          : const Color(0xFF111827),
                      height: 1.05,
                      letterSpacing: -0.2,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 24,
              color: enabled
                  ? const Color(0xFF8B95A7)
                  : const Color(0xFFBDBDBD),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Soft money field ─────────────────────────────────────────────────────────

class _SoftMoneyField extends StatefulWidget {
  final String label;
  final bool enabled;
  final int value;
  final ValueChanged<int> onChanged;

  const _SoftMoneyField({
    required this.label,
    required this.enabled,
    required this.value,
    required this.onChanged,
  });

  @override
  State<_SoftMoneyField> createState() => _SoftMoneyFieldState();
}

class _SoftMoneyFieldState extends State<_SoftMoneyField> {
  late final TextEditingController _c;
  bool _internal = false;

  @override
  void initState() {
    super.initState();
    _c = TextEditingController(text: _fmtMoney(widget.value));
    _c.addListener(_onText);
  }

  @override
  void didUpdateWidget(covariant _SoftMoneyField oldWidget) {
    super.didUpdateWidget(oldWidget);
    final next = _fmtMoney(widget.value);
    if (_c.text != next && !_internal) {
      _internal = true;
      _c.text = next;
      _c.selection = TextSelection.collapsed(offset: _c.text.length);
      _internal = false;
    }
  }

  @override
  void dispose() {
    _c.removeListener(_onText);
    _c.dispose();
    super.dispose();
  }

  void _onText() {
    if (_internal) return;
    final digits = _c.text.replaceAll(RegExp(r'\D'), '');
    final formatted = digits.isEmpty ? "" : _fmtMoney(int.parse(digits));
    if (_c.text != formatted) {
      _internal = true;
      _c.text = formatted;
      _c.selection = TextSelection.collapsed(offset: formatted.length);
      _internal = false;
    }
    widget.onChanged(int.tryParse(digits) ?? 0);
  }

  @override
  Widget build(BuildContext context) {
    final bg = widget.enabled
        ? const Color(0xFFF5F7FF)
        : const Color(0xFFF3F4F6);
    final border = widget.enabled
        ? const Color(0xFFE6ECFF)
        : const Color(0xFFE5E7EB);

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 64),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: Color(0xFF8B95A7),
              height: 1.1,
              letterSpacing: -0.1,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _c,
            enabled: widget.enabled,
            keyboardType: TextInputType.number,
            style: const TextStyle(
              fontSize: 16.5,
              fontWeight: FontWeight.w600,
              color: Color(0xFF111827),
              height: 1.05,
              letterSpacing: -0.2,
            ),
            decoration:  InputDecoration(
              isCollapsed: true,
              contentPadding: EdgeInsets.zero,
              border: InputBorder.none,
              hintText: 'placeholder_enter'.tr(),
              hintStyle: TextStyle(
                fontSize: 16.5,
                fontWeight: FontWeight.w600,
                color: Color(0xFFB0B7C3),
                height: 1.05,
                letterSpacing: -0.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Soft text area field (izoh uchun) ───────────────────────────────────────

class _SoftTextAreaField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final bool enabled;
  final ValueChanged<String>? onChanged;

  const _SoftTextAreaField({
    required this.label,
    required this.hint,
    required this.controller,
    required this.enabled,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final bg = enabled ? const Color(0xFFF5F7FF) : const Color(0xFFF3F4F6);
    final border = enabled ? const Color(0xFFE6ECFF) : const Color(0xFFE5E7EB);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: Color(0xFF8B95A7),
              height: 1.1,
              letterSpacing: -0.1,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: controller,
            enabled: enabled,
            maxLines: 3,
            minLines: 1,
            keyboardType: TextInputType.multiline,
            textInputAction: TextInputAction.newline,
            onChanged: onChanged,
            style: const TextStyle(
              fontSize: 15.5,
              fontWeight: FontWeight.w500,
              color: Color(0xFF111827),
              height: 1.4,
              letterSpacing: -0.1,
            ),
            decoration: InputDecoration(
              isCollapsed: true,
              contentPadding: EdgeInsets.zero,
              border: InputBorder.none,
              hintText: hint,
              hintStyle: const TextStyle(
                fontSize: 15.5,
                fontWeight: FontWeight.w500,
                color: Color(0xFFB0B7C3),
                height: 1.4,
                letterSpacing: -0.1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Sticky footer ────────────────────────────────────────────────────────────

class _StickyFooter extends StatelessWidget {
  final Widget child;

  const _StickyFooter({required this.child});

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(16, 10, 16, 10 + bottom),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
      ),
      child: child,
    );
  }
}

// ─── Bottom sheets ────────────────────────────────────────────────────────────

const _sheetShape = RoundedRectangleBorder(
  borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
);

Future<String?> _pickFromListBottomSheet(
    BuildContext context, {
      required String title,
      required List<String> items,
    }) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    elevation: 0,
    shape: _sheetShape,
    clipBehavior: Clip.antiAlias,
    builder: (_) {
      final h = MediaQuery.of(context).size.height;
      return SizedBox(
        height: h * 0.86,
        child: _SearchListSheet(title: title, items: items),
      );
    },
  );
}

class _SearchListSheet extends StatefulWidget {
  final String title;
  final List<String> items;

  const _SearchListSheet({required this.title, required this.items});

  @override
  State<_SearchListSheet> createState() => _SearchListSheetState();
}

class _SearchListSheetState extends State<_SearchListSheet> {
  final _q = TextEditingController();
  String query = "";

  @override
  void dispose() {
    _q.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final bottom = mq.padding.bottom;
    final filtered = widget.items
        .where((e) => e.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return MediaQuery(
      data: mq.copyWith(textScaler: const TextScaler.linear(1.0)),
      child: Column(
        children: [
          const SizedBox(height: 8),
          Container(
            width: 44,
            height: 5,
            decoration: BoxDecoration(
              color: const Color(0xFFE5E7EB),
              borderRadius: BorderRadius.circular(99),
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 8, 10),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                      color: Color(0xFF111827),
                      letterSpacing: -0.2,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded),
                  splashRadius: 18,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFFF5F7FF),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE6ECFF)),
              ),
              child: TextField(
                controller: _q,
                onChanged: (v) => setState(() => query = v),
                style: const TextStyle(
                  fontSize: 15.5,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF111827),
                ),
                decoration:  InputDecoration(
                  border: InputBorder.none,
                  hintText: 'placeholder_search'.tr(),
                  hintStyle: TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFB0B7C3),
                  ),
                  prefixIcon: Icon(Icons.search_rounded),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: EdgeInsets.fromLTRB(12, 0, 12, 12 + bottom),
              itemCount: filtered.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, i) {
                final item = filtered[i];
                return InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => Navigator.pop(context, item),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 14,
                    ),
                    child: Text(
                      item,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF111827),
                        letterSpacing: -0.1,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

Future<DateTime?> _pickCupertinoDateSheet(
    BuildContext context, {
      required String title,
      required DateTime initial,
    }) {
  DateTime temp = initial;
  final now = DateTime.now();
  final min = DateTime(now.year, now.month, now.day);
  final max = min.add(const Duration(days: 365));

  return showModalBottomSheet<DateTime>(
    context: context,
    backgroundColor: Colors.white,
    elevation: 0,
    shape: _sheetShape,
    clipBehavior: Clip.antiAlias,
    builder: (ctx) {
      return _WhiteSheetShell(
        title: title,
        onDone: () => Navigator.pop(ctx, temp),
        child: SizedBox(
          height: 260,
          child: CupertinoDatePicker(
            mode: CupertinoDatePickerMode.date,
            initialDateTime: initial,
            minimumDate: min,
            maximumDate: max,
            onDateTimeChanged: (d) => temp = d,
          ),
        ),
      );
    },
  );
}

Future<TimeOfDay?> _pickCupertinoTimeSheet(
    BuildContext context, {
      required String title,
      required TimeOfDay initial,
    }) async {
  final base = DateTime(2026, 1, 1, initial.hour, initial.minute);
  DateTime temp = base;

  final res = await showModalBottomSheet<DateTime>(
    context: context,
    backgroundColor: Colors.white,
    elevation: 0,
    shape: _sheetShape,
    clipBehavior: Clip.antiAlias,
    builder: (ctx) {
      return _WhiteSheetShell(
        title: title,
        onDone: () => Navigator.pop(ctx, temp),
        child: SizedBox(
          height: 260,
          child: CupertinoDatePicker(
            mode: CupertinoDatePickerMode.time,
            use24hFormat: true,
            minuteInterval: 1,
            initialDateTime: base,
            onDateTimeChanged: (d) => temp = d,
          ),
        ),
      );
    },
  );

  if (res == null) return null;
  return TimeOfDay(hour: res.hour, minute: res.minute);
}

Future<int?> _pickSeatsBottomSheet(
    BuildContext context, {
      required int initial,
      required int min,
      required int max,
    }) {
  int temp = initial.clamp(min, max);

  return showModalBottomSheet<int>(
    context: context,
    backgroundColor: Colors.white,
    elevation: 0,
    shape: _sheetShape,
    clipBehavior: Clip.antiAlias,
    builder: (ctx) {
      return _WhiteSheetShell(
        title: "Bo'sh o'rinlar",
        onDone: () => Navigator.pop(ctx, temp),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
          child: Container(
            height: 56,
            decoration: BoxDecoration(
              color: const Color(0xFFF5F7FF),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE6ECFF)),
            ),
            child: StatefulBuilder(
              builder: (context, setLocal) {
                return Row(
                  children: [
                    IconButton(
                      onPressed: temp > min
                          ? () => setLocal(() => temp--)
                          : null,
                      icon: const Icon(Icons.remove_rounded),
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          "$temp",
                          style: const TextStyle(
                            fontSize: 16.5,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF111827),
                            letterSpacing: -0.1,
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: temp < max
                          ? () => setLocal(() => temp++)
                          : null,
                      icon: const Icon(Icons.add_rounded),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      );
    },
  );
}

// ─── White sheet shell ────────────────────────────────────────────────────────

class _WhiteSheetShell extends StatelessWidget {
  final String title;
  final VoidCallback onDone;
  final Widget child;

  const _WhiteSheetShell({
    required this.title,
    required this.onDone,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final bottom = mq.padding.bottom;

    return MediaQuery(
      data: mq.copyWith(textScaler: const TextScaler.linear(1.0)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          Container(
            width: 44,
            height: 5,
            decoration: BoxDecoration(
              color: const Color(0xFFE5E7EB),
              borderRadius: BorderRadius.circular(99),
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 12, 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                      color: Color(0xFF111827),
                      letterSpacing: -0.2,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: onDone,
                  child:  Text(
                    'btn_done'.tr(),
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15.5,
                      letterSpacing: -0.1,
                    ),
                  ),
                ),
              ],
            ),
          ),
          child,
          SizedBox(height: 10 + bottom),
        ],
      ),
    );
  }
}

// ─── Flushbar helpers ─────────────────────────────────────────────────────────

Future<void> _showSuccessFlushbar(BuildContext context, String message) async {
  await Flushbar(
    message: message,
    duration: const Duration(seconds: 2),
    margin: const EdgeInsets.all(16),
    borderRadius: BorderRadius.circular(14),
    backgroundColor: const Color(0xFF111827),
    flushbarPosition: FlushbarPosition.TOP,
    icon: const Icon(Icons.check_circle, color: Colors.white),
  ).show(context);
}

Future<void> _showErrorFlushbar(BuildContext context, String message) async {
  await Flushbar(
    message: message,
    duration: const Duration(seconds: 2),
    margin: const EdgeInsets.all(16),
    borderRadius: BorderRadius.circular(14),
    backgroundColor: const Color(0xFFB91C1C),
    flushbarPosition: FlushbarPosition.TOP,
    icon: const Icon(Icons.error_rounded, color: Colors.white),
  ).show(context);
}

// ─── Format helpers ───────────────────────────────────────────────────────────

String _fmtTime(TimeOfDay t) => '${_two(t.hour)}:${_two(t.minute)}';

String _two(int n) => n.toString().padLeft(2, '0');

String _fmtMoney(int v) {
  if (v <= 0) return "";
  final s = v.toString();
  final b = StringBuffer();
  for (int i = 0; i < s.length; i++) {
    final left = s.length - i;
    b.write(s[i]);
    if (left > 1 && left % 3 == 1) b.write(' ');
  }
  return b.toString();
}

String _fmtDateUz(DateTime d) {
  const months = [
    "yanvar",
    "fevral",
    "mart",
    "aprel",
    "may",
    "iyun",
    "iyul",
    "avgust",
    "sentabr",
    "oktabr",
    "noyabr",
    "dekabr",
  ];
  return "${_two(d.day)} ${months[(d.month - 1).clamp(0, 11)]}";
}