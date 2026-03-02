import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:uputi/src/core/constants/app_images.dart';
import '../../../../../core/constants/app_color.dart';
import '../../../../../core/router/pages.dart';
import '../../../domain/entities/user_role.dart';
import '../../blocs/auth/role_bloc.dart';
import '../../blocs/auth/role_event.dart';
import '../../blocs/auth/role_state.dart';
import '../../widgets/role_card.dart';

class ChooseRoleScreen extends StatefulWidget {
  const ChooseRoleScreen({super.key});

  @override
  State<ChooseRoleScreen> createState() => _ChooseRoleScreenState();
}

class _ChooseRoleScreenState extends State<ChooseRoleScreen> {
  void _selectRole(UserRole role) {
    final apiRole = (role == UserRole.driver) ? "driver" : "passenger";
    context.read<RoleBloc>().add(RoleSelected(role: apiRole));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.white,
      body: BlocListener<RoleBloc, RoleState>(
        listener: (context, state) {
          if (state.error != null) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.error!)));
          }
          if (state.success) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              state.role == "driver" ? Pages.driverShell : Pages.passengerSHell,
                  (_) => false,
            );
          }
        },
        child: BlocBuilder<RoleBloc, RoleState>(
          builder: (context, state) {
            final isLoading = state.loading;
            return SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 26),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(AppImages.appLogo, width: 250, height: 250),
                    ],
                  ),
                  Text(
                    'role_title'.tr(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 22,
                      fontFamily: 'SF Pro Display',
                      fontWeight: FontWeight.w600,
                      height: 1.20,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'role_subtitle'.tr(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFF5B7087),
                      fontSize: 16,
                      fontFamily: 'SF Pro Display',
                      fontWeight: FontWeight.w400,
                      height: 1.40,
                    ),
                  ),
                  const SizedBox(height: 40),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: AbsorbPointer(
                              absorbing: isLoading,
                              child: RoleCard(
                                icon: Icons.person,
                                title: 'role_passenger'.tr(),
                                onTap: () => _selectRole(UserRole.passenger),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: AbsorbPointer(
                              absorbing: isLoading,
                              child: RoleCard(
                                icon: CupertinoIcons.car_detailed,
                                title: 'role_driver'.tr(),
                                onTap: () => _selectRole(UserRole.driver),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),
                  if (isLoading)
                    const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}