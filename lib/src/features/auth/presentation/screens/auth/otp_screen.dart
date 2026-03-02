import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_device_type/flutter_device_type.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:uputi/src/helpers/flushbar.dart';

import '../../../../../core/constants/app_color.dart';
import '../../../../../core/constants/app_images.dart';
import '../../../../../core/constants/app_style.dart';
import '../../../../../core/router/pages.dart';
import '../../../../../core/storage/shared_storage.dart';
import '../../../../../utils/phone_formatter.dart';
import '../../blocs/auth/otp_bloc.dart';
import '../../blocs/auth/otp_event.dart';
import '../../blocs/auth/otp_state.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  String verificationId = "";
  String phoneNumber = "";

  final controller = TextEditingController();
  final errorController = StreamController<ErrorAnimationType>();
  bool isError = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Map) {
        setState(() {
          verificationId = (args["verificationId"] ?? args["vertificationId"] ?? "").toString();
          phoneNumber = (args["phoneNumber"] ?? "").toString();
        });
      }
    });
  }

  @override
  void dispose() {
    controller.dispose();
    errorController.close();
    super.dispose();
  }

  void _verify(String code) {
    FocusScope.of(context).unfocus();
    context.read<OtpBloc>().add(
      OtpVerifyPressed(verificationId: verificationId, code: code),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.Bg,
      appBar: AppBar(
        toolbarHeight: 60,
        backgroundColor: AppColor.White,
        elevation: Device.get().isAndroid ? 0.4 : 0.1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('otp_appbar'.tr(), style: AppStyle.sfproDisplay16Black),
        centerTitle: true,
      ),
      body: BlocListener<OtpBloc, OtpState>(
        listener: (context, state) async {
          if (state.error != null) {
            setState(() => isError = true);
            errorController.add(ErrorAnimationType.shake);
            showErrorFlushBar(state.error!).show(context);
          }

          if (state.accessToken != null && state.accessToken!.isNotEmpty) {
            await Prefs.setAccessToken(state.accessToken!);
            await Prefs.setRole(state.user!.role!);
            if (state.user!.role.isEmpty) {
              Navigator.pushReplacementNamed(context, Pages.chooseRole);
            } else if (state.user!.role == "driver") {
              Navigator.pushNamedAndRemoveUntil(context, Pages.driverShell, (_) => false);
            } else {
              Navigator.pushNamedAndRemoveUntil(context, Pages.passengerSHell, (_) => false);
            }
          }
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 44),
              Center(
                child: Image(image: AssetImage(AppImages.verifypic), width: 150, height: 120),
              ),
              const SizedBox(height: 18),
              Text(
                formatPhoneNumber(phoneNumber),
                textAlign: TextAlign.center,
                style: AppStyle.sfProDisplay24w600,
              ),
              const SizedBox(height: 12),
              Text(
                'otp_description'.tr(),
                textAlign: TextAlign.center,
                style: AppStyle.sfproDisplay16Gray5,
              ),
              const SizedBox(height: 26),
              BlocBuilder<OtpBloc, OtpState>(
                builder: (context, state) {
                  return Column(
                    children: [
                      PinCodeTextField(
                        appContext: context,
                        controller: controller,
                        autoFocus: true,
                        length: 6,
                        keyboardType: TextInputType.number,
                        textStyle: AppStyle.sfproDisplay15Black,
                        cursorColor: Colors.transparent,
                        errorAnimationController: errorController,
                        animationType: AnimationType.fade,
                        hintCharacter: "0",
                        pinTheme: PinTheme(
                          shape: PinCodeFieldShape.circle,
                          fieldHeight: 55,
                          fieldWidth: 55,
                          activeBorderWidth: 1,
                          selectedBorderWidth: 1,
                          inactiveBorderWidth: 1,
                          activeFillColor: AppColor.White,
                          inactiveFillColor: AppColor.Gray,
                          selectedFillColor: AppColor.White,
                          activeColor: isError ? AppColor.RedMain : AppColor.blueMain,
                          selectedColor: AppColor.blueMain,
                          inactiveColor: AppColor.Gray,
                          errorBorderColor: AppColor.RedMain,
                        ),
                        onChanged: (_) {
                          if (isError) setState(() => isError = false);
                        },
                        onCompleted: (code) => _verify(code),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}