import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uputi/src/helpers/flushbar.dart';

import '../../../../core/constants/app_color.dart';
import '../bloc/create_trip_bloc.dart';
import '../bloc/create_trip_event.dart';
import '../bloc/create_trip_state.dart';

Future<bool?> showDriverTripDetailsBottomSheet({
  required BuildContext context,
  required String fromAddress,
  required String toAddress,
  required double fromLat,
  required double fromLng,
  required double toLat,
  required double toLng,
  DriverTripCreateBloc? bloc,
  VoidCallback? onCreated,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withOpacity(0.35),
    builder: (_) {
      final providedBloc = bloc ?? context.read<DriverTripCreateBloc>();
      return BlocProvider.value(
        value: providedBloc,
        child: _DriverTripDetailsSheet(
          onCreated: onCreated ?? () {},
          fromAddress: fromAddress,
          toAddress: toAddress,
          fromLat: fromLat,
          fromLng: fromLng,
          toLat: toLat,
          toLng: toLng,
        ),
      );
    },
  );
}

class _DriverTripDetailsSheet extends StatefulWidget {
  final String fromAddress;
  final String toAddress;
  final double fromLat;
  final double fromLng;
  final VoidCallback onCreated;
  final double toLat;
  final double toLng;

  const _DriverTripDetailsSheet({
    required this.fromAddress,
    required this.toAddress,
    required this.fromLat,
    required this.fromLng,
    required this.onCreated,
    required this.toLat,
    required this.toLng,
  });

  @override
  State<_DriverTripDetailsSheet> createState() =>
      _DriverTripDetailsSheetState();
}

class _DriverTripDetailsSheetState extends State<_DriverTripDetailsSheet> {
  static const int _minSeats = 1;
  static const int _maxSeats = 4;

  final _sumCtrl = TextEditingController();
  final _sumFocus = FocusNode();
  final _commentCtrl = TextEditingController();

  bool _internalTextUpdate = false;

  @override
  void initState() {
    super.initState();
    _sumCtrl.addListener(_onSumTextChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final s = context.read<DriverTripCreateBloc>().state;
      _syncSumTextFromState(s.amount);
    });
  }

  @override
  void dispose() {
    _sumCtrl.removeListener(_onSumTextChanged);
    _sumCtrl.dispose();
    _sumFocus.dispose();
    _commentCtrl.dispose();
    super.dispose();
  }

  String _two(int n) => n.toString().padLeft(2, '0');
  String _fmtDate(DateTime d) => '${_two(d.day)}.${_two(d.month)}.${d.year}';
  String _fmtTime(TimeOfDay t) => '${_two(t.hour)}:${_two(t.minute)}';

  String _formatUzs(String digits) {
    if (digits.isEmpty) return '';
    final s = digits.replaceAll(RegExp(r'\D'), '');
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      final left = s.length - i;
      buf.write(s[i]);
      if (left > 1 && left % 3 == 1) buf.write(' ');
    }
    return buf.toString();
  }

  int _parseUzs(String text) =>
      int.tryParse(text.replaceAll(' ', '').trim()) ?? 0;

  void _syncSumTextFromState(int amount) {
    final digits = amount <= 0 ? '' : amount.toString();
    final formatted = _formatUzs(digits);
    if (_sumCtrl.text == formatted) return;
    _internalTextUpdate = true;
    _sumCtrl.value = TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
    _internalTextUpdate = false;
  }

  void _onSumTextChanged() {
    if (_internalTextUpdate) return;
    final raw = _sumCtrl.text;
    final digits = raw.replaceAll(RegExp(r'\D'), '');
    final formatted = _formatUzs(digits);
    if (raw != formatted) {
      _internalTextUpdate = true;
      _sumCtrl.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
      _internalTextUpdate = false;
    }
    context
        .read<DriverTripCreateBloc>()
        .add(DriverTripCreateAmountChanged(_parseUzs(formatted)));
  }

  Future<DateTime?> _showDatePicker({required DateTime initial}) async {
    DateTime temp = initial;
    return showCupertinoModalPopup<DateTime>(
      context: context,
      builder: (ctx) => _CupertinoPickerShell(
        title: 'sheet_select_date'.tr(),
        onDone: () => Navigator.pop(ctx, temp),
        child: CupertinoDatePicker(
          mode: CupertinoDatePickerMode.date,
          initialDateTime: initial,
          minimumDate: DateTime.now(),
          maximumDate: DateTime.now().add(const Duration(days: 365)),
          onDateTimeChanged: (d) => temp = d,
        ),
      ),
    );
  }

  Future<TimeOfDay?> _showTimePicker({required TimeOfDay initial}) async {
    final base = DateTime(2026, 1, 1, initial.hour, initial.minute);
    DateTime temp = base;
    final res = await showCupertinoModalPopup<DateTime>(
      context: context,
      builder: (ctx) => _CupertinoPickerShell(
        title: 'sheet_select_time'.tr(),
        onDone: () => Navigator.pop(ctx, temp),
        child: CupertinoDatePicker(
          mode: CupertinoDatePickerMode.time,
          use24hFormat: true,
          minuteInterval: 1,
          initialDateTime: base,
          onDateTimeChanged: (d) => temp = d,
        ),
      ),
    );
    if (res == null) return null;
    return TimeOfDay(hour: res.hour, minute: res.minute);
  }

  Future<void> _pickDate(DateTime current) async {
    final picked = await _showDatePicker(initial: current);
    if (picked == null) return;
    context.read<DriverTripCreateBloc>().add(
      DriverTripCreateDateChanged(
        DateTime(picked.year, picked.month, picked.day),
      ),
    );
  }

  Future<void> _pickTime(TimeOfDay current) async {
    final picked = await _showTimePicker(initial: current);
    if (picked == null) return;
    context.read<DriverTripCreateBloc>().add(DriverTripCreateTimeChanged(picked));
  }

  void _submit(DriverTripCreateState s) {
    if (!s.canSubmit) {
      _sumFocus.requestFocus();
      return;
    }

    context.read<DriverTripCreateBloc>().add(
      DriverTripCreateCommentChanged(_commentCtrl.text),
    );

    context.read<DriverTripCreateBloc>().add(
      DriverTripCreateSubmitted(
        fromLat: widget.fromLat,
        fromLng: widget.fromLng,
        fromAddress: widget.fromAddress,
        toLat: widget.toLat,
        toLng: widget.toLng,
        toAddress: widget.toAddress,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final text = Theme.of(context).textTheme;
    final titleStyle = text.titleLarge?.copyWith(fontWeight: FontWeight.w700);
    final labelStyle = text.labelLarge?.copyWith(
      fontWeight: FontWeight.w600,
      color: const Color(0xFF374151),
    );
    final valueStyle = text.bodyMedium?.copyWith(
      fontWeight: FontWeight.w600,
      color: const Color(0xFF111827),
    );

    return BlocConsumer<DriverTripCreateBloc, DriverTripCreateState>(
      listenWhen: (p, c) =>
      p.status != c.status ||
          p.errorMessage != c.errorMessage ||
          p.amount != c.amount,
      listener: (context, s) {
        _syncSumTextFromState(s.amount);

        if (s.status == DriverTripCreateStatus.success) {
          Navigator.of(context).pop(true);
          return;
        }

        if (s.status == DriverTripCreateStatus.failure) {
          _sumFocus.requestFocus();
          if ((s.errorMessage ?? '').isNotEmpty) {
            showErrorFlushBar(s.errorMessage!).show(context);
          }
        }
      },
      builder: (context, s) {
        final loading = s.status == DriverTripCreateStatus.submitting;
        final errorText =
        s.status == DriverTripCreateStatus.failure ? (s.errorMessage ?? '') : '';
        final seats = s.seats.clamp(_minSeats, _maxSeats);
        final canMinus = seats > _minSeats && !loading;
        final canPlus = seats < _maxSeats && !loading;

        return AnimatedPadding(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          padding: EdgeInsets.only(bottom: bottomInset),
          child: DraggableScrollableSheet(
            initialChildSize: 0.78,
            minChildSize: 0.55,
            maxChildSize: 0.95,
            expand: false,
            builder: (context, scrollCtrl) {
              return Align(
                alignment: Alignment.bottomCenter,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 760),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                    child: Container(
                      color: const Color(0xFFF9FAFB),
                      child: Column(
                        children: [
                          // Handle
                          const SizedBox(height: 10),
                          Container(
                            width: 42,
                            height: 5,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE5E7EB),
                              borderRadius: BorderRadius.circular(99),
                            ),
                          ),
                          // Title
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 10, 12, 8),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'sheet_order_details'.tr(),
                                    style: titleStyle,
                                  ),
                                ),
                                IconButton(
                                  onPressed:
                                  loading ? null : () => Navigator.pop(context),
                                  icon: const Icon(Icons.close_rounded),
                                  splashRadius: 20,
                                ),
                              ],
                            ),
                          ),
                          // Scroll content
                          Expanded(
                            child: ScrollConfiguration(
                              behavior: const _NoGlowScrollBehavior(),
                              child: SingleChildScrollView(
                                controller: scrollCtrl,
                                keyboardDismissBehavior:
                                ScrollViewKeyboardDismissBehavior.onDrag,
                                padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _RouteLine(
                                      label: 'A',
                                      labelColor: const Color(0xFF16A34A),
                                      value: widget.fromAddress,
                                    ),
                                    const SizedBox(height: 10),
                                    _RouteLine(
                                      label: 'B',
                                      labelColor: const Color(0xFFDC2626),
                                      value: widget.toAddress,
                                    ),
                                    const SizedBox(height: 16),

                                    // Date / Time / Seats / Sum
                                    LayoutBuilder(
                                      builder: (context, c) {
                                        const gap = 12.0;
                                        final w = c.maxWidth;
                                        final tileW = w < 420
                                            ? w
                                            : (w < 620
                                            ? (w - gap) / 2
                                            : (w - gap * 3) / 4);

                                        return Wrap(
                                          spacing: gap,
                                          runSpacing: gap,
                                          children: [
                                            SizedBox(
                                              width: tileW,
                                              child: _FieldTile(
                                                label: 'sheet_date'.tr(),
                                                labelStyle: labelStyle,
                                                child: _TapInput(
                                                  text: _fmtDate(s.date),
                                                  textStyle: valueStyle,
                                                  icon: Icons.calendar_month_rounded,
                                                  onTap: loading
                                                      ? null
                                                      : () => _pickDate(s.date),
                                                  height: 48,
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              width: tileW,
                                              child: _FieldTile(
                                                label: 'sheet_time'.tr(),
                                                labelStyle: labelStyle,
                                                child: _TapInput(
                                                  text: _fmtTime(s.time),
                                                  textStyle: valueStyle,
                                                  icon: Icons.access_time_rounded,
                                                  onTap: loading
                                                      ? null
                                                      : () => _pickTime(s.time),
                                                  height: 48,
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              width: tileW,
                                              child: _FieldTile(
                                                label: 'sheet_seats'.tr(),
                                                labelStyle: labelStyle,
                                                child: _Stepper(
                                                  value: seats,
                                                  onMinus: canMinus
                                                      ? () => context
                                                      .read<DriverTripCreateBloc>()
                                                      .add(
                                                    DriverTripCreateSeatsChanged(
                                                      seats - 1,
                                                    ),
                                                  )
                                                      : null,
                                                  onPlus: canPlus
                                                      ? () => context
                                                      .read<DriverTripCreateBloc>()
                                                      .add(
                                                    DriverTripCreateSeatsChanged(
                                                      seats + 1,
                                                    ),
                                                  )
                                                      : null,
                                                  height: 48,
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              width: tileW,
                                              child: _FieldTile(
                                                label: 'sheet_price'.tr(),
                                                labelStyle: labelStyle,
                                                child: _SoftTextField(
                                                  controller: _sumCtrl,
                                                  focusNode: _sumFocus,
                                                  hint: 'sheet_price_hint'.tr(),
                                                  errorText: errorText.isEmpty
                                                      ? null
                                                      : 'Narxni kiriting',
                                                  keyboardType: TextInputType.number,
                                                  inputFormatters: [
                                                    FilteringTextInputFormatter
                                                        .digitsOnly,
                                                    LengthLimitingTextInputFormatter(12),
                                                  ],
                                                  enabled: !loading,
                                                  textInputAction: TextInputAction.done,
                                                  onSubmitted: (_) => _submit(s),
                                                ),
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    ),

                                    // Izoh (driver uchun)
                                    const SizedBox(height: 16),
                                    _FieldTile(
                                      label: 'field_comment'.tr(),
                                      labelStyle: labelStyle,
                                      child: _SoftTextField(
                                        controller: _commentCtrl,
                                        hint: 'field_comment_hint'.tr(),
                                        keyboardType: TextInputType.text,
                                        maxLines: 3,
                                        enabled: !loading,
                                        textInputAction: TextInputAction.newline,
                                      ),
                                    ),

                                    if (errorText.isNotEmpty) ...[
                                      const SizedBox(height: 12),
                                      Text(
                                        errorText,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 12.5,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFFB91C1C),
                                        ),
                                      ),
                                    ],

                                    const SizedBox(height: 90),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          // Bottom buttons
                          Container(
                            padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
                            decoration: const BoxDecoration(
                              color: Color(0xFFF9FAFB),
                              border:
                              Border(top: BorderSide(color: Color(0xFFE5E7EB))),
                            ),
                            child: LayoutBuilder(
                              builder: (context, c) {
                                final isNarrow = c.maxWidth < 420;

                                final cancelBtn = _SoftButton(
                                  text: 'sheet_cancel'.tr(),
                                  onTap: loading ? null : () => Navigator.pop(context),
                                );

                                final submitBtn = _PrimaryButton(
                                  text: loading ? 'sheet_creating'.tr() : 'sheet_create'.tr(),
                                  onTap: s.canSubmit && !loading ? () => _submit(s) : null,
                                  loading: loading,
                                );

                                if (isNarrow) {
                                  return Column(
                                    children: [
                                      SizedBox(
                                        width: double.infinity,
                                        height: 50,
                                        child: submitBtn,
                                      ),
                                      const SizedBox(height: 10),
                                      SizedBox(
                                        width: double.infinity,
                                        height: 50,
                                        child: cancelBtn,
                                      ),
                                    ],
                                  );
                                }

                                return Row(
                                  children: [
                                    Expanded(
                                      child: SizedBox(height: 50, child: cancelBtn),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: SizedBox(height: 50, child: submitBtn),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

// ─── Helpers ────────────────────────────────────────────────────────────────

class _NoGlowScrollBehavior extends ScrollBehavior {
  const _NoGlowScrollBehavior();
  @override
  Widget buildOverscrollIndicator(
      BuildContext context,
      Widget child,
      ScrollableDetails details,
      ) =>
      child;
}

class _CupertinoPickerShell extends StatelessWidget {
  final String title;
  final VoidCallback onDone;
  final Widget child;

  const _CupertinoPickerShell({
    required this.title,
    required this.onDone,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom;
    return Material(
      color: Colors.black.withOpacity(0.25),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          padding: EdgeInsets.only(bottom: bottom),
          decoration: const BoxDecoration(
            color: Color(0xFFF9FAFB),
            borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
                  border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: onDone,
                      child:  Text(
                        'btn_done'.tr(),
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1E88E5),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 260, child: child),
            ],
          ),
        ),
      ),
    );
  }
}

class _RouteLine extends StatelessWidget {
  final String label;
  final Color labelColor;
  final String value;

  const _RouteLine({
    required this.label,
    required this.labelColor,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 34,
            decoration: BoxDecoration(
              color: labelColor,
              borderRadius: BorderRadius.circular(99),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            '$label:',
            style: TextStyle(fontWeight: FontWeight.w700, color: labelColor),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF4B5563),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FieldTile extends StatelessWidget {
  final String label;
  final TextStyle? labelStyle;
  final Widget child;

  const _FieldTile({required this.label, required this.child, this.labelStyle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: labelStyle),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}

class _TapInput extends StatelessWidget {
  final String text;
  final TextStyle? textStyle;
  final IconData icon;
  final VoidCallback? onTap;
  final double height;

  const _TapInput({
    required this.text,
    required this.onTap,
    required this.icon,
    this.textStyle,
    this.height = 46,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        height: height,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Row(
          children: [
            Expanded(child: Text(text, style: textStyle)),
            Icon(icon, size: 18, color: const Color(0xFF6B7280)),
          ],
        ),
      ),
    );
  }
}

class _Stepper extends StatelessWidget {
  final int value;
  final VoidCallback? onMinus;
  final VoidCallback? onPlus;
  final double height;

  const _Stepper({
    required this.value,
    required this.onMinus,
    required this.onPlus,
    this.height = 46,
  });

  @override
  Widget build(BuildContext context) {
    final primary = AppColor.blueMain;
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          IconButton(
            splashRadius: 18,
            onPressed: onMinus,
            icon: Icon(
              Icons.remove_rounded,
              size: 20,
              color: onMinus != null
                  ? const Color(0xFF111827)
                  : const Color(0xFF9CA3AF),
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                '$value',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
          IconButton(
            splashRadius: 18,
            onPressed: onPlus,
            icon: Icon(
              Icons.add_rounded,
              size: 20,
              color: onPlus != null ? primary : const Color(0xFF9CA3AF),
            ),
          ),
        ],
      ),
    );
  }
}

class _SoftTextField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode? focusNode;
  final String hint;
  final String? errorText;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final int maxLines;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;
  final bool enabled;

  const _SoftTextField({
    required this.controller,
    required this.hint,
    this.errorText,
    required this.keyboardType,
    this.inputFormatters,
    this.maxLines = 1,
    this.focusNode,
    this.textInputAction,
    this.onSubmitted,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final hasError = (errorText ?? '').isNotEmpty;
    return TextField(
      controller: controller,
      focusNode: focusNode,
      enabled: enabled,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      maxLines: maxLines,
      textInputAction: textInputAction,
      onSubmitted: onSubmitted,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: enabled ? Colors.white : const Color(0xFFF3F4F6),
        isDense: true,
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color:
            hasError ? const Color(0xFFFCA5A5) : const Color(0xFFE5E7EB),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color:
            hasError ? const Color(0xFFEF4444) : const Color(0xFF93C5FD),
            width: 1.6,
          ),
        ),
        errorText: hasError ? errorText : null,
        errorStyle: const TextStyle(height: 0.8),
      ),
    );
  }
}

class _SoftButton extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;

  const _SoftButton({required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        side: const BorderSide(color: Color(0xFFE5E7EB)),
        foregroundColor: const Color(0xFF111827),
        textStyle: const TextStyle(fontWeight: FontWeight.w700),
      ),
      child: Text(text),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;
  final bool loading;

  const _PrimaryButton({
    required this.text,
    required this.onTap,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    final primary = AppColor.blueMain;

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: enabled
            ? LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            primary.withOpacity(0.95),
            primary.withOpacity(0.75),
          ],
        )
            : null,
        color: enabled ? null : const Color(0xFFE5E7EB),
      ),
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: loading
            ? const SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Colors.white,
          ),
        )
            : Text(
          text,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: enabled ? Colors.white : const Color(0xFF9CA3AF),
          ),
        ),
      ),
    );
  }
}