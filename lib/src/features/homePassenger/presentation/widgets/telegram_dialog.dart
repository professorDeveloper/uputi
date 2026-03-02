import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

String telegramBotUrl(int userId) =>
    "https://t.me/uputi_xabarnoma_bot?start=user_$userId";

Future<void> showTelegramConnectDialog(
    BuildContext context,
    int userId, {
      required Future<bool> Function() onCheckConnected,
    }) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    useRootNavigator: true,
    builder: (context) {
      return _TelegramDialog(
        userId: userId,
        onCheckConnected: onCheckConnected,
      );
    },
  );
}

class _TelegramDialog extends StatefulWidget {
  final int userId;
  final Future<bool> Function() onCheckConnected;

  const _TelegramDialog({
    required this.userId,
    required this.onCheckConnected,
  });

  @override
  State<_TelegramDialog> createState() => _TelegramDialogState();
}

class _TelegramDialogState extends State<_TelegramDialog> {
  bool _isChecking = false;
  String? _errorText;

  Future<void> _handleCheck() async {
    setState(() {
      _isChecking = true;
      _errorText = null;
    });

    try {
      final connected = await widget.onCheckConnected();
      if (!mounted) return;

      if (connected) {
        Navigator.of(context, rootNavigator: true).pop();
      } else {
        setState(() {
          _isChecking = false;
          _errorText = 'telegram_not_connected'.tr();
        });
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isChecking = false;
        _errorText = "Tekshirishda xatolik. Qayta urining.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        insetPadding: const EdgeInsets.symmetric(horizontal: 20),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    width: 90,
                    height: 90,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF4A8CF6),
                    ),
                    child: const Icon(
                      Icons.notifications_none,
                      size: 44,
                      color: Colors.white,
                    ),
                  ),
                  Container(
                    width: 26,
                    height: 26,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF22C55E),
                    ),
                    child: const Icon(
                      Icons.chat_bubble_outline,
                      size: 14,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
               Text(
                'telegram_title'.tr(),
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
               Text(
                'telegram_subtitle'.tr(),
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
              ),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F6FF),
                  borderRadius: BorderRadius.circular(14),
                ),
                child:  Column(
                  children: [
                    _StepRow(number: "1", text: 'telegram_step1'.tr()),
                    SizedBox(height: 10),
                    _StepRow(number: "2", text: 'telegram_step2'.tr()),
                    SizedBox(height: 10),
                    _StepRow(number: "3", text: 'telegram_step3'.tr()),
                  ],
                ),
              ),

              if (_errorText != null) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Color(0xFFEF4444), size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorText!,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFFB91C1C),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 18),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _isChecking
                      ? null
                      : () async {
                    final url = Uri.parse(telegramBotUrl(widget.userId));
                    final ok = await launchUrl(
                      url,
                      mode: LaunchMode.externalApplication,
                    );
                    if (!ok && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                         SnackBar(
                            content: Text('telegram_open_failed'.tr())),
                      );
                    }
                  },
                  icon: const Icon(Icons.chat_bubble_outline),
                  label:  Text(
                    'telegram_connect_btn'.tr(),
                    style: TextStyle(fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    backgroundColor: const Color(0xFF4A8CF6),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton.icon(
                  onPressed: _isChecking ? null : _handleCheck,
                  icon: _isChecking
                      ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Color(0xFF4A8CF6),
                    ),
                  )
                      : const Icon(Icons.check_circle_outline,
                      color: Color(0xFF4A8CF6)),
                  label: Text(
                    _isChecking ? 'telegram_checking'.tr() : 'telegram_check_btn'.tr(),
                    style: const TextStyle(
                      fontSize: 15,
                      color: Color(0xFF4A8CF6),
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    side: const BorderSide(color: Color(0xFF4A8CF6)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StepRow extends StatelessWidget {
  final String number;
  final String text;

  const _StepRow({required this.number, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 26,
          height: 26,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFF4A8CF6),
          ),
          child: Text(
            number,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }
}