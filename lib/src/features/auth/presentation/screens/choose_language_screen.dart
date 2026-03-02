import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/constants/app_color.dart';
import '../../../../core/constants/app_images.dart';
import '../../../../core/router/pages.dart';

class ChooseLanguageScreen extends StatefulWidget {
  const ChooseLanguageScreen({super.key});

  @override
  State<ChooseLanguageScreen> createState() => _ChooseLanguageScreenState();
}

class _ChooseLanguageScreenState extends State<ChooseLanguageScreen> {
  Locale? _selected;
  bool _inited = false;

  static const List<_LangOption> _options = <_LangOption>[
    _LangOption(locale: Locale('uz'), titleKey: 'lang_uz', iconPath: 'assets/icons/ic_uzbek.png'),
    _LangOption(locale: Locale('ru'), titleKey: 'lang_ru', iconPath: 'assets/icons/ic_russian.png'),
    _LangOption(locale: Locale('en'), titleKey: 'lang_en', iconPath: 'assets/icons/ic_uk.png'),
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_inited) {
      _selected = context.locale;
      _inited = true;
    }
  }

  Future<void> _pick(Locale locale) async {
    setState(() => _selected = locale);
    await context.setLocale(locale);
  }

  void _continue() {
    Navigator.pushNamed(context, Pages.login);
  }

  @override
  Widget build(BuildContext context) {
    final Locale current = _selected ?? context.locale;
    final bottom = MediaQuery.of(context).padding.bottom;
    final top = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.fromLTRB(18, top + 52, 18, bottom > 0 ? bottom + 12 : 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 8),

            Text(
              'lang_title'.tr(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: Color(0xFF111827),
                letterSpacing: -0.4,
                height: 1.2,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              'lang_subtitle'.tr(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Color(0xFF9CA3AF),
                height: 1.5,
              ),
            ),

            const SizedBox(height: 32),

            for (final _LangOption opt in _options) ...[
              _LanguageTile(
                iconPath: opt.iconPath,
                title: opt.titleKey.tr(),
                selected: opt.locale.languageCode == current.languageCode,
                onTap: () => _pick(opt.locale),
              ),
              const SizedBox(height: 12),
            ],

            const Spacer(),

            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.blueMain,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shadowColor: Colors.transparent,
                  splashFactory: NoSplash.splashFactory,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.1,
                  ),
                ),
                onPressed: _continue,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('lang_continue'.tr()),
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward_rounded, size: 18),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LanguageTile extends StatelessWidget {
  const _LanguageTile({
    required this.iconPath,
    required this.title,
    required this.selected,
    required this.onTap,
  });

  final String iconPath;
  final String title;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? AppColor.blueMain : const Color(0xFFE5E7EB),
            width: selected ? 1.5 : 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: selected
                  ? AppColor.blueMain.withOpacity(0.08)
                  : Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipOval(
              child: Image.asset(
                iconPath,
                width: 24,
                height: 24,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: selected ? AppColor.blueMain : const Color(0xFF1C2230),
                  letterSpacing: -0.1,
                ),
              ),
            ),
            _RadioDot(selected: selected),
          ],
        ),
      ),
    );
  }
}

class _RadioDot extends StatelessWidget {
  const _RadioDot({required this.selected});
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        color: selected ? AppColor.blueMain : Colors.transparent,
        shape: BoxShape.circle,
        border: Border.all(
          color: selected ? AppColor.blueMain : const Color(0xFFD1D5DB),
          width: 2.0,
        ),
      ),
      alignment: Alignment.center,
      child: selected
          ? const Icon(Icons.check_rounded, size: 13, color: Colors.white)
          : null,
    );
  }
}

class _LangOption {
  const _LangOption({
    required this.locale,
    required this.titleKey,
    required this.iconPath,
  });

  final Locale locale;
  final String titleKey;
  final String iconPath;
}