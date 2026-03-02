import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uputi/src/core/router/pages.dart';
import 'package:uputi/src/features/auth/presentation/screens/auth/choose_role_screen.dart';
import 'package:uputi/src/features/auth/presentation/screens/auth/login_screen.dart';
import 'package:uputi/src/features/auth/presentation/screens/auth/otp_screen.dart';
import 'package:uputi/src/features/createTrip/presentation/blocs/choose_direction_bloc.dart';
import 'package:uputi/src/features/createTrip/presentation/screens/choose_directions_screen.dart';
import 'package:uputi/src/features/createTrip/presentation/screens/create_trip_screeen.dart';
import 'package:uputi/src/features/createTripDriver/presentation/bloc/create_trip_bloc.dart';
import 'package:uputi/src/features/driver/driver_screen.dart';
import 'package:uputi/src/features/shells/presentation/screen/driver_shell.dart';
import 'package:uputi/src/features/shells/presentation/screen/passenger_shell.dart';

import '../../di/di.dart';
import '../../features/auth/presentation/blocs/auth/auth_bloc.dart';
import '../../features/auth/presentation/blocs/auth/otp_bloc.dart';
import '../../features/auth/presentation/blocs/auth/role_bloc.dart';
import '../../features/auth/presentation/screens/choose_language_screen.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/createTripDriver/presentation/screens/create_driver_trip_screen.dart';

class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case Pages.splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case Pages.chooseLanguage:
        return MaterialPageRoute(builder: (_) => const ChooseLanguageScreen());
      case Pages.login:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => BlocProvider(
            create: (_) => sl<AuthBloc>(),
            child: const LoginScreen(),
          ),
        );
      case Pages.otp:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => BlocProvider(
            create: (_) => sl<OtpBloc>(),
            child: const OtpScreen(),
          ),
        );
      case Pages.chooseRole:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => sl<RoleBloc>(),
            child: const ChooseRoleScreen(),
          ),
        );

      case Pages.createTrip:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => sl<ChooseDirectionsBloc>(),
            child: const CreateTripScreen(),
          ),
        );
      case Pages.createTripDriver:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => sl<ChooseDirectionsBloc>(),
            child: const CreateDriverTripScreen(),
          ),
        );
      case Pages.passengerSHell:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => PassengerShell(),
        );
      case Pages.driverShell:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => DriverShell(),
        );

      default:
        return MaterialPageRoute(
          builder: (_) =>
              const Scaffold(body: Center(child: Text('Route not found'))),
        );
    }
  }
}
