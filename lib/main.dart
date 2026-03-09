import 'package:chucker_flutter/chucker_flutter.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:uputi/src/core/constants/app_locales.dart';
import 'package:uputi/src/core/storage/shared_storage.dart';
import 'package:uputi/src/di/di.dart';
import 'src/core/router/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Prefs.init();
  await setupDI();
  await EasyLocalization.ensureInitialized();
  ChuckerFlutter.showOnRelease = true;

  runApp(
    EasyLocalization(
      supportedLocales: AppLocales.supported,
      path: AppLocales.path,
      fallbackLocale: AppLocales.fallback,
      startLocale: AppLocales.fallback,
      child: const MyApp(),
    ),
  );
}

final RouteObserver<ModalRoute<void>> routeObserver =
    RouteObserver<ModalRoute<void>>();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorObservers: [routeObserver, ChuckerFlutter.navigatorObserver],
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: false),
      locale: context.locale,

      supportedLocales: context.supportedLocales,
      localizationsDelegates: context.localizationDelegates,

      onGenerateRoute: AppRouter.onGenerateRoute,
    );
  }
}
