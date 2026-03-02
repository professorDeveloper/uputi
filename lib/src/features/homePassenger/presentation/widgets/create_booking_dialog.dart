import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/constants/app_color.dart';

Future<int?> showSeatsBottomSheet(
    BuildContext context, {
      int min = 1,
      int max = 4,
    }) {
  if (max > 4) max = 4;
  if (min < 1) min = 1;
  if (min > max) min = max;

  return showModalBottomSheet<int>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) {
      int seats = min;
      bool submitting = false;

      return StatefulBuilder(
        builder: (_, setState) {
          void setSeats(int v) {
            if (submitting) return;
            if (v < min || v > max) return;
            HapticFeedback.lightImpact();
            setState(() => seats = v);
          }

          Future<void> submit() async {
            if (submitting) return;
            setState(() => submitting = true);
            await Future.delayed(const Duration(milliseconds: 120));
            if (ctx.mounted) Navigator.pop(ctx, seats);
          }

          final radius = BorderRadius.circular(24);

          return Padding(
            padding: EdgeInsets.only(
              left: 14,
              right: 14,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 14,
            ),
            child: Material(
              color: Colors.transparent,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: radius,
                  boxShadow: const [
                    BoxShadow(
                      blurRadius: 28,
                      offset: Offset(0, 14),
                      color: Color(0x1F000000),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 12, 18, 18),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 44,
                        height: 5,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE6E8EE),
                          borderRadius: BorderRadius.circular(99),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              "Nechta o‘rin kerak?",
                              style: TextStyle(
                                fontSize: 20,
                                height: 1.15,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF111827),
                              ),
                            ),
                          ),
                          InkWell(
                            borderRadius: BorderRadius.circular(999),
                            onTap: submitting ? null : () => Navigator.pop(ctx),
                            child: const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Icon(
                                Icons.close,
                                size: 22,
                                color: Color(0xFF111827),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: List.generate(max, (i) {
                            final v = i + 1;
                            final selected = seats == v;
                            return InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: submitting ? null : () => setSeats(v),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 160),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: selected
                                      ? AppColor.blueMain
                                      : const Color(0xFFF2F4F7),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.person,
                                      size: 18,
                                      color: selected
                                          ? Colors.white
                                          : const Color(0xFF111827),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      "$v",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: selected
                                            ? Colors.white
                                            : const Color(0xFF111827),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF6F7FB),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _CounterBtn(
                              icon: Icons.remove,
                              enabled: !submitting && seats > min,
                              onTap: () => setSeats(seats - 1),
                            ),
                            const SizedBox(width: 18),
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 150),
                              transitionBuilder: (child, anim) =>
                                  ScaleTransition(scale: anim, child: child),
                              child: Text(
                                "$seats",
                                key: ValueKey(seats),
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF111827),
                                ),
                              ),
                            ),
                            const SizedBox(width: 18),
                            _CounterBtn(
                              icon: Icons.add,
                              enabled: !submitting && seats < max,
                              onTap: () => setSeats(seats + 1),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 50,
                              child: _PrimaryBtn(
                                text: 'btn_cancel'.tr(),
                                filled: false,
                                color: AppColor.blueMain,
                                loading: submitting,
                                onTap: () => Navigator.pop(ctx),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: SizedBox(
                              height: 50,
                              child: _PrimaryBtn(
                                text: 'booking_confirm'.tr(),
                                filled: true,
                                color: AppColor.blueMain,
                                loading: submitting,
                                onTap: submit,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      );
    },
  );
}

class _CounterBtn extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  const _CounterBtn({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: enabled ? onTap : null,
      child: Container(
        width: 54,
        height: 54,
        decoration: BoxDecoration(
          color: enabled ? Colors.white : const Color(0xFFE5E7EB),
          shape: BoxShape.circle,
          border: Border.all(
            color: enabled ? const Color(0xFFE2E5EC) : const Color(0xFFE5E7EB),
          ),
        ),
        child: Icon(
          icon,
          size: 22,
          color: enabled ? const Color(0xFF111827) : const Color(0xFF9CA3AF),
        ),
      ),
    );
  }
}

class _PrimaryBtn extends StatelessWidget {
  final String text;
  final bool filled;
  final Color color;
  final bool loading;
  final VoidCallback onTap;

  const _PrimaryBtn({
    required this.text,
    required this.filled,
    required this.color,
    required this.loading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: loading ? null : onTap,
      style: ElevatedButton.styleFrom(
        elevation: 0,
        shadowColor: Colors.transparent,
        backgroundColor: filled ? color : const Color(0xFFF0F2F6),
        foregroundColor: filled ? Colors.white : const Color(0xFF111827),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ).copyWith(
        overlayColor: WidgetStateProperty.all(
          filled
              ? Colors.white.withOpacity(0.10)
              : Colors.black.withOpacity(0.05),
        ),
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 150),
        child: loading && filled
            ? const SizedBox(
          key: ValueKey('loading'),
          width: 18,
          height: 18,
          child: CircularProgressIndicator(strokeWidth: 2),
        )
            : Text(
          key: const ValueKey('text'),
          text,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}