import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uputi/src/helpers/flushbar.dart';

import '../../../../../core/constants/app_color.dart';
import '../../../../../core/constants/app_images.dart';
import '../../../../../core/constants/app_style.dart';
import '../../../../../core/router/pages.dart';
import '../../../../../utils/phone_formatter.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_event.dart';
import '../../blocs/auth/auth_state.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final phoneController = TextEditingController();
  final nameController = TextEditingController();

  final maskFormatter = MaskTextInputFormatter(
    mask: '+998 (##) ###-##-##',
    filter: {"#": RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );

  @override
  void dispose() {
    phoneController.dispose();
    nameController.dispose();
    super.dispose();
  }

  void _submit() {
    if (phoneController.text.trim().isEmpty) {
      showErrorFlushBar('error_phone_empty'.tr()).show(context);
      return;
    } else if (nameController.text.trim().isEmpty) {
      showErrorFlushBar('error_name_empty'.tr()).show(context);
      return;
    }
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    final name = nameController.text.trim();
    final phone9 = extractPhone9Digits(phoneController);
    context.read<AuthBloc>().add(AuthStartPressed(name: name, phone: phone9));
  }

  Future<void> _openSupport() async {
    final uri = Uri.parse('https://t.me/uputi_support');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hintColor = AppColor.grey.withOpacity(0.75);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      body: BlocListener<AuthBloc, AuthState>(
        listenWhen: (prev, curr) =>
        prev.error != curr.error ||
            prev.loggedIn != curr.loggedIn ||
            prev.verificationId != curr.verificationId,
        listener: (context, state) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!context.mounted) return;

            if (state.error != null) {
              showErrorFlushBar(state.error!).show(context);
              return;
            }

            if (state.loggedIn) {
              final role = (state.user?.role ?? "").trim();
              final target = role == 'passenger'
                  ? Pages.passengerSHell
                  : role == 'driver'
                  ? Pages.driverShell
                  : Pages.chooseRole;
              Navigator.of(context).pushNamedAndRemoveUntil(target, (r) => false);
              return;
            }

            final vid = state.verificationId;
            if (vid != null && vid.isNotEmpty) {
              final phone = "+998${extractPhone9Digits(phoneController)}";
              Navigator.of(context).pushNamed(
                Pages.otp,
                arguments: {"verificationId": vid, "phoneNumber": phone},
              );
            }
          });
        },
        child: SafeArea(
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.asset(AppImages.loginpic, height: 160, fit: BoxFit.cover),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 18.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'login_title'.tr(),
                                style: AppStyle.sfProDisplay24w600.copyWith(fontSize: 22.5),
                              ),
                              const SizedBox(height: 6),
                              Padding(
                                padding: const EdgeInsets.only(right: 24),
                                child: Text(
                                  'login_subtitle'.tr(),
                                  style: AppStyle.sfproDisplay14w400Black.copyWith(color: AppColor.grey),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 13),
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColor.lightGrey),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 22,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('phone_label'.tr(), style: AppStyle.sfproDisplay14w400Black),
                          const SizedBox(height: 10),
                          _LightField(
                            child: TextFormField(
                              controller: phoneController,
                              inputFormatters: [maskFormatter],
                              keyboardType: TextInputType.phone,
                              style: TextStyle(
                                fontFamily: "SfProDisplay",
                                color: AppColor.black,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                              decoration: InputDecoration(
                                hintText: 'phone_hint'.tr(),
                                hintStyle: TextStyle(
                                  color: hintColor,
                                  fontFamily: "SfProDisplay",
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                                prefixIcon: Icon(Icons.call, color: AppColor.blueMain),
                                isDense: true,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text('name_label'.tr(), style: AppStyle.sfproDisplay14w400Black),
                          const SizedBox(height: 10),
                          _LightField(
                            child: TextFormField(
                              controller: nameController,
                              keyboardType: TextInputType.name,
                              textCapitalization: TextCapitalization.words,
                              style: TextStyle(
                                fontFamily: "SfProDisplay",
                                color: AppColor.black,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                              decoration: InputDecoration(
                                hintText: 'name_hint'.tr(),
                                hintStyle: TextStyle(
                                  color: hintColor,
                                  fontFamily: "SfProDisplay",
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                                prefixIcon: Icon(Icons.person, color: AppColor.blueMain),
                                isDense: true,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          BlocBuilder<AuthBloc, AuthState>(
                            builder: (context, state) {
                              return SizedBox(
                                height: 52,
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: state.loading ? null : _submit,
                                  style: ElevatedButton.styleFrom(
                                    disabledBackgroundColor: AppColor.blueMain,
                                    disabledForegroundColor: Colors.white,
                                    foregroundColor: Colors.white,
                                    backgroundColor: AppColor.blueMain,
                                    elevation: 0,
                                    shadowColor: Colors.transparent,
                                    splashFactory: NoSplash.splashFactory,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                  child: state.loading
                                      ? const SizedBox(
                                    height: 18,
                                    width: 18,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                  )
                                      : Text(
                                    'login_btn'.tr(),
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: _openSupport,
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 13),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0F5FF),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFD1E0FF)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: AppColor.blueMain.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(11),
                            ),
                            child: Icon(Icons.headset_mic_rounded, color: AppColor.blueMain, size: 20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'support_problem'.tr(),
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF111827),
                                  ),
                                ),
                                const SizedBox(height: 1),
                                Text(
                                  'support_contact'.tr(),
                                  style: TextStyle(fontSize: 11, color: AppColor.grey),
                                ),
                              ],
                            ),
                          ),
                          Icon(Icons.arrow_forward_ios_rounded, size: 13, color: AppColor.blueMain),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LightField extends StatelessWidget {
  final Widget child;
  const _LightField({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColor.lightBlue,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColor.lightGrey),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Theme(
        data: Theme.of(context).copyWith(
          inputDecorationTheme: const InputDecorationTheme(
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 16),
          ),
        ),
        child: child,
      ),
    );
  }
}