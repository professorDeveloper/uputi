import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_color.dart';
import '../../../../core/router/pages.dart';
import '../../../../core/storage/shared_storage.dart';
import '../../../../di/di.dart';
import '../../../auth/presentation/blocs/auth/auth_bloc.dart';
import '../../../auth/presentation/screens/auth/login_screen.dart';
import '../blocs/profile_bloc.dart';

class PassengersProfileScreen extends StatefulWidget {
  const PassengersProfileScreen({super.key});

  @override
  State<PassengersProfileScreen> createState() => _PassengersProfileScreenState();
}

class _PassengersProfileScreenState extends State<PassengersProfileScreen> {
  Future<void> doLogout(BuildContext context) async {
    await Prefs.logout();
    if (!context.mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => BlocProvider<AuthBloc>(
          create: (_) => sl<AuthBloc>(),
          child: const LoginScreen(),
        ),
      ),
          (_) => false,
    );
  }

  Future<void> _openSupport() async {
    final uri = Uri.parse('https://t.me/uputi_support');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _showRoleChangeInfo(BuildContext context) async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 42,
                  height: 5,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5E7EB),
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.support_agent_rounded, size: 30, color: Color(0xFF2563EB)),
                ),
                const SizedBox(height: 16),
                Text(
                  'role_change_title'.tr(),
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: Color(0xFF111827)),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'role_change_desc'.tr(),
                  style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280), height: 1.5),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(ctx);
                      _openSupport();
                    },
                    icon: const Icon(Icons.send_rounded, size: 18),
                    label: Text(
                      'role_change_contact_support'.tr(),
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF6B7280),
                    ),
                    child: Text('btn_cancel'.tr(), style: const TextStyle(fontSize: 15)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _openBalance() async {
    final uri = Uri.parse('https://t.me/Uputi_balance');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _navigateToShell(BuildContext context, String role) {
    final target = role == 'driver' ? Pages.driverShell : Pages.passengerSHell;
    Navigator.of(context).pushNamedAndRemoveUntil(target, (_) => false);
  }

  Future<void> _showCarEditSheet(BuildContext context, CarViewData? existing) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetCtx) => _CarEditSheet(
        existing: existing,
        onSave: (model, color, number) {
          context.read<ProfileBloc>().add(
            ProfileCarUpdateRequested(model: model, color: color, number: number),
          );
        },
      ),
    );
  }

  Future<void> _showLanguageSheet(BuildContext outerContext) async {
    await showModalBottomSheet(
      context: outerContext,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => _LanguageSheet(
        current: outerContext.locale,
        onPick: (locale) async {
          Navigator.of(ctx).pop();
          await outerContext.setLocale(locale);
          if (mounted) setState(() {});
        },
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<ProfileBloc>().add(const ProfileFetch());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFFF6F7FB);
    const border = Color(0xFFE7EEF8);
    const text = Color(0xFF111827);
    const sub = Color(0xFF6B7280);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: bg,
        surfaceTintColor: bg,
        centerTitle: true,
        title: Text(
          'profile_title'.tr(),
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w500, color: text),
        ),
      ),
      body: SafeArea(
        child: BlocConsumer<ProfileBloc, ProfileState>(
          listener: (context, state) {
            if (state is ProfileFailure) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
            }
          },
          builder: (context, state) {
            if (state is ProfileLoading || state is ProfileInitial) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is ProfileFailure) {
              return RefreshIndicator(
                onRefresh: () async {
                  context.read<ProfileBloc>().add(const ProfileFetch());
                },
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.5,
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('profile_error'.tr()),
                            const SizedBox(height: 10),
                            ElevatedButton(
                              onPressed: () => context.read<ProfileBloc>().add(const ProfileFetch()),
                              child: Text('profile_retry'.tr()),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

            final loaded = state as ProfileLoaded;
            final data = loaded.data;

            return LayoutBuilder(builder: (context, c) {
              final w = c.maxWidth;
              final contentW = w > 520 ? 520.0 : w;
              final hPad = ((w - contentW) / 2).clamp(0.0, 999.0);

              return RefreshIndicator(
                onRefresh: () async {
                  context.read<ProfileBloc>().add(const ProfileFetch());
                },
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(16 + hPad, 16, 16 + hPad, 18),
                  children: [
                    _Card(
                      borderColor: border,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 22,
                              backgroundColor: const Color(0xFF111827),
                              child: Text(
                                _initials(data.name),
                                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    data.name,
                                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color: text),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    data.phone,
                                    style: const TextStyle(fontSize: 13, color: sub),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    if (data.isDriver) ...[
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          border: BoxBorder.all(
                              color: Colors.black87,
                              width: 0.1
                          ),
                          color: const Color(0xFFFFFFFF),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              CupertinoIcons.creditcard,
                              color: Colors.black87,
                              size: 22,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                _fmtBalance(data.balance),
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 32,
                              child: TextButton.icon(
                                onPressed: _openBalance,
                                style: TextButton.styleFrom(
                                  foregroundColor: const Color(0xFF2563EB),
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                icon: const Icon(Icons.add_rounded, size: 16),
                                label: Text(
                                  'profile_balance_topup'.tr(),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 14),

                    _Card(
                      borderColor: border,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                        child: Column(
                          children: [
                            _kv('profile_name_label'.tr(), data.name),
                            _kv('profile_phone_label'.tr(), data.phone),
                            Row(
                              children: [
                                SizedBox(
                                  width: 92,
                                  child: Text('profile_rating_label'.tr(), style: const TextStyle(fontSize: 15, color: sub)),
                                ),
                                const Icon(Icons.star_rounded, size: 18, color: Color(0xFFF59E0B)),
                                const SizedBox(width: 6),
                                Text(
                                  '${data.rating} (${data.ratingCount})',
                                  style: const TextStyle(fontSize: 16, color: text, fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              child: Divider(height: 1, color: Color(0xFFE5E7EB)),
                            ),
                            Row(
                              children: [
                                const Icon(Icons.person_outline_rounded, color: sub, size: 20),
                                const SizedBox(width: 10),
                                Text('profile_role_label'.tr(), style: const TextStyle(fontSize: 15, color: sub)),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    data.roleLabel,
                                    style: const TextStyle(fontSize: 16, color: text, fontWeight: FontWeight.w500),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                TextButton(
                                  onPressed: () => _showRoleChangeInfo(context),
                                  child: Text(
                                    'profile_role_change'.tr(),
                                    style: TextStyle(color: AppColor.blueMain, fontWeight: FontWeight.w500),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    if (data.isDriver) ...[
                      const SizedBox(height: 14),
                      _Card(
                        borderColor: border,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.directions_car_rounded, color: sub, size: 20),
                                  const SizedBox(width: 8),
                                  Text('profile_car_title'.tr(),
                                      style: const TextStyle(fontSize: 15, color: sub, fontWeight: FontWeight.w500)),
                                  const Spacer(),
                                  loaded.isCarUpdating
                                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                                      : TextButton(
                                    onPressed: () => _showCarEditSheet(context, data.car),
                                    child: Text(
                                      data.car == null ? 'profile_car_add'.tr() : 'profile_car_edit'.tr(),
                                      style: TextStyle(color: AppColor.blueMain, fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                ],
                              ),
                              if (data.car != null) ...[
                                const SizedBox(height: 10),
                                const Divider(height: 1, color: Color(0xFFE5E7EB)),
                                const SizedBox(height: 10),
                                _kv('profile_car_model'.tr(), data.car!.model),
                                _kv('profile_car_color'.tr(), data.car!.color),
                                _kv('profile_car_number'.tr(), data.car!.number),
                              ] else ...[
                                const SizedBox(height: 4),
                                Text(
                                  'profile_car_empty'.tr(),
                                  style: TextStyle(fontSize: 13, color: sub.withOpacity(0.7)),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: 14),

                    _Card(
                      borderColor: border,
                      child: ListTile(
                        onTap: () => _showLanguageSheet(context),
                        leading: const Icon(Icons.language_rounded, color: sub),
                        title: Text('profile_language'.tr(),
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: text)),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _LangFlagChip(locale: context.locale),
                            const SizedBox(width: 4),
                            const Icon(Icons.chevron_right_rounded, color: sub),
                          ],
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      ),
                    ),

                    const SizedBox(height: 10),

                    _Card(
                      borderColor: border,
                      child: ListTile(
                        onTap: _openSupport,
                        leading: const Icon(Icons.headset_mic_rounded, color: sub),
                        title: Text('profile_support'.tr(),
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: text)),
                        trailing: const Icon(Icons.chevron_right_rounded, color: sub),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      ),
                    ),

                    const SizedBox(height: 18),

                    SizedBox(
                      height: 52,
                      child: FilledButton.icon(
                        onPressed: () => doLogout(context),
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFFE23A2E),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                        ),
                        icon: const Icon(Icons.logout_rounded),
                        label: Text('profile_logout'.tr(),
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                      ),
                    ),
                  ],
                ),
              );
            });
          },
        ),
      ),
    );
  }

  String _fmtBalance(int v) {
    final s = v.toString();
    final b = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      final left = s.length - i;
      b.write(s[i]);
      if (left > 1 && left % 3 == 1) b.write(' ');
    }
    return '${b.toString()} UZS';
  }

  Widget _kv(String k, String v) {
    const sub = Color(0xFF6B7280);
    const text = Color(0xFF111827);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          SizedBox(
            width: 92,
            child: Text(k, style: const TextStyle(fontSize: 15, color: sub)),
          ),
          Expanded(
            child: Text(v,
                style: const TextStyle(fontSize: 16, color: text, fontWeight: FontWeight.w500),
                overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }
}

class _CarEditSheet extends StatefulWidget {
  const _CarEditSheet({required this.existing, required this.onSave});

  final CarViewData? existing;
  final void Function(String model, String color, String number) onSave;

  @override
  State<_CarEditSheet> createState() => _CarEditSheetState();
}

class _CarEditSheetState extends State<_CarEditSheet> {
  late final TextEditingController _modelCtrl;
  late final TextEditingController _colorCtrl;
  late final TextEditingController _numberCtrl;

  @override
  void initState() {
    super.initState();
    _modelCtrl = TextEditingController(text: widget.existing?.model ?? '');
    _colorCtrl = TextEditingController(text: widget.existing?.color ?? '');
    _numberCtrl = TextEditingController(text: widget.existing?.number ?? '');
  }

  @override
  void dispose() {
    _modelCtrl.dispose();
    _colorCtrl.dispose();
    _numberCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 12, 16, MediaQuery.of(context).viewInsets.bottom + 24),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 42,
                height: 5,
                decoration: BoxDecoration(
                  color: const Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              widget.existing == null ? 'car_add_title'.tr() : 'car_edit_title'.tr(),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF111827)),
            ),
            const SizedBox(height: 16),
            _SheetField(
              controller: _modelCtrl,
              label: 'car_model_label'.tr(),
              hint: 'car_model_hint'.tr(),
            ),
            const SizedBox(height: 12),
            _SheetField(
              controller: _colorCtrl,
              label: 'car_color_label'.tr(),
              hint: 'car_color_hint'.tr(),
            ),
            const SizedBox(height: 12),
            _SheetField(
              controller: _numberCtrl,
              label: 'car_number_label'.tr(),
              hint: 'car_number_hint'.tr(),
              caps: TextCapitalization.characters,
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 50,
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final m = _modelCtrl.text.trim();
                  final c = _colorCtrl.text.trim();
                  final n = _numberCtrl.text.trim();
                  if (m.isEmpty || c.isEmpty || n.isEmpty) return;
                  Navigator.pop(context);
                  widget.onSave(m, c, n);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.blueMain,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: Text('btn_save'.tr(), style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child, required this.borderColor});
  final Widget child;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: borderColor),
      ),
      child: child,
    );
  }
}

class _SheetField extends StatelessWidget {
  const _SheetField({
    required this.controller,
    required this.label,
    required this.hint,
    this.caps = TextCapitalization.sentences,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final TextCapitalization caps;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280), fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF3F7FF),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE7EEF8)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: TextField(
            controller: controller,
            textCapitalization: caps,
            style: const TextStyle(fontSize: 15, color: Color(0xFF111827), fontWeight: FontWeight.w500),
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: hint,
              hintStyle: TextStyle(color: const Color(0xFF6B7280).withOpacity(0.6), fontSize: 15),
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
      ],
    );
  }
}

String _initials(String name) {
  final t = name.trim();
  if (t.isEmpty) return 'U';
  return t.characters.take(1).toString().toUpperCase();
}
// ─── Language Sheet ────────────────────────────────────────────────────────────

// ─── Language Sheet ────────────────────────────────────────────────────────────

class _LanguageSheet extends StatelessWidget {
  const _LanguageSheet({required this.current, required this.onPick});

  final Locale current;
  final void Function(Locale) onPick;

  static const _options = [
    _LangOption(locale: Locale('uz'), titleKey: 'lang_uz', iconPath: 'assets/icons/ic_uzbek.png'),
    _LangOption(locale: Locale('ru'), titleKey: 'lang_ru', iconPath: 'assets/icons/ic_russian.png'),
  ];

  static const _border = Color(0xFFE5E7EB);
  static const _text = Color(0xFF111827);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 10),
          // drag handle
          Container(
            width: 44,
            height: 5,
            decoration: BoxDecoration(
              color: _border,
              borderRadius: BorderRadius.circular(100),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'profile_language_title'.tr(),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: _text,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Divider(height: 1, color: _border),
          for (int i = 0; i < _options.length; i++) ...[
            _LangItem(
              option: _options[i],
              selected: _options[i].locale.languageCode == current.languageCode,
              onTap: () => onPick(_options[i].locale),
              textColor: _text,
            ),
            const Divider(height: 1, color: _border),
          ],
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}

class _LangItem extends StatelessWidget {
  const _LangItem({
    required this.option,
    required this.selected,
    required this.onTap,
    required this.textColor,
  });

  final _LangOption option;
  final bool selected;
  final VoidCallback onTap;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        height: 56,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Image.asset(
                  option.iconPath,
                  width: 28,
                  height: 20,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  option.titleKey.tr(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
              ),
              if (selected)
                Icon(Icons.check, size: 20, color: textColor),
            ],
          ),
        ),
      ),
    );
  }
}

/// Profile sahifasidagi kichik flag chip (to'rtburchak rounded)
class _LangFlagChip extends StatelessWidget {
  const _LangFlagChip({required this.locale});
  final Locale locale;

  static const _icons = {
    'uz': 'assets/icons/ic_uzbek.png',
    'ru': 'assets/icons/ic_russian.png',
  };

  @override
  Widget build(BuildContext context) {
    final icon = _icons[locale.languageCode] ?? _icons['uz']!;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Image.asset(icon, width: 22, height: 16, fit: BoxFit.cover),
        ),
        const SizedBox(width: 5),
        Text(
          locale.languageCode.toUpperCase(),
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF6B7280),
          ),
        ),
      ],
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