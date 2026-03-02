import 'dart:math';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:uputi/src/core/constants/app_images.dart';
import 'package:uputi/src/core/router/pages.dart';

import '../../../../core/storage/shared_storage.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );

    _controller.addStatusListener((status) async {
      if (status == AnimationStatus.completed) {
        if (!mounted) return;
        await _navigate();
      }
    });

    _controller.forward();
  }

  Future<void> _navigate() async {
    final accessToken = Prefs.getAccessToken();
    final role = Prefs.getRole();

    print("Role: $role");
    print("Token: $accessToken");

    if (accessToken == null) {
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, Pages.login);
      return;
    }

    // Token bor — boshqa devicedan kirgan bo'lishi mumkin, /api/user tekshiramiz
    final isValid = await _checkTokenValid(accessToken);

    if (!mounted) return;

    if (!isValid) {
      // Unauthenticated — prefs tozalab loginга yuboramiz
      await Prefs.clear();
      Navigator.pushReplacementNamed(context, Pages.login);
      return;
    }

    switch (role) {
      case 'driver':
        Navigator.pushReplacementNamed(context, Pages.driverShell);
        break;
      case 'passenger':
        Navigator.pushReplacementNamed(context, Pages.passengerSHell);
        break;
      default:
        Navigator.pushReplacementNamed(context, Pages.chooseRole);
    }
  }
  Future<bool> _checkTokenValid(String token) async {
    try {
      final dio = GetIt.instance<Dio>();

      final res = await dio.get(
        '/api/user',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
          validateStatus: (status) => true, // barcha HTTP statuslarni qabul qil
        ),
      );

      print("Token check → status: ${res.statusCode}");

      if (res.statusCode == 401) return false;

      final data = res.data;
      if (data is Map && data['message'] == 'Unauthenticated.') return false;

      return res.statusCode != null &&
          res.statusCode! >= 200 &&
          res.statusCode! < 300;
    } on DioException catch (e) {
      print("Token check network error (offline?): ${e.type}");
      return true;
    } catch (e) {
      print("Token check unknown error: $e");
      return true;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final t = _controller.value;

              final scale = 0.92 + (t * 0.08);
              final dy = -8 * sin(t * pi);
              final opacity = 0.75 + (t * 0.25);

              return Opacity(
                opacity: opacity,
                child: Transform.translate(
                  offset: Offset(0, dy),
                  child: Transform.scale(scale: scale, child: child),
                ),
              );
            },
            child: Image.asset(AppImages.appLogo, fit: BoxFit.contain),
          ),
        ),
      ),
    );
  }
}