import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uputi/src/core/router/pages.dart';

import '../../../../di/di.dart';
import '../../../homePassenger/presentation/bloc/home_passenger_bloc.dart';

import 'package:uputi/src/features/homePassenger/presentation/screens/passenger_home_screen.dart';
import 'package:uputi/src/features/searchPassenger/presentation/screen/search_passengers_screen.dart';
import 'package:uputi/src/features/historyPassenger/presentation/blocs/history_bloc.dart';
import 'package:uputi/src/features/historyPassenger/presentation/screens/passengers_history_screen.dart';
import 'package:uputi/src/features/profilePassenger/presentation/blocs/profile_bloc.dart';
import 'package:uputi/src/features/profilePassenger/presentation/screens/passengers_profile_screen.dart';

import '../../../searchPassenger/presentation/blocs/search_trips_bloc.dart';

class PassengerShell extends StatefulWidget {
  const PassengerShell({super.key});

  @override
  State<PassengerShell> createState() => _PassengerShellState();
}

class _PassengerShellState extends State<PassengerShell> {
  int index = 0;

  late final HomePassengerBloc _homeBloc;

  late final List<Widget> pages;

  @override
  void initState() {
    super.initState();

    _homeBloc = sl<HomePassengerBloc>();

    pages = [
      BlocProvider.value(
        value: _homeBloc,
        child: const HomePassengerScreen(),
      ),
      BlocProvider(
        create: (_) => sl<SearchTripsBloc>(),
        child: const SearchPassengersScreen(),
      ),
      BlocProvider(
        create: (_) => sl<HistoryBloc>(),
        child: const PassengersHistoryScreen(),
      ),
      BlocProvider(
        create: (_) => sl<ProfileBloc>(),
        child: const PassengersProfileScreen(),
      ),
    ];
  }

  @override
  void dispose() {
    _homeBloc.close();
    super.dispose();
  }

  Future<void> _onFabTap() async {
    final res = await Navigator.pushNamed(context, Pages.createTrip);
    if (!mounted) return;
    setState(() => index = 0);
    _homeBloc.add(RefreshMyTripsPressed());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: index, children: pages),
      floatingActionButton: FloatingActionButton(
        onPressed: _onFabTap,
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        child: SizedBox(
          height: 64,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                icon: Icons.home,
                label: 'nav_home'.tr(),
                selected: index == 0,
                onTap: () => setState(() => index = 0),
              ),
              _NavItem(
                icon: Icons.search,
                label: 'nav_search'.tr(),
                selected: index == 1,
                onTap: () => setState(() => index = 1),
              ),
              const SizedBox(width: 40),
              _NavItem(
                icon: Icons.history,
                label: 'nav_history'.tr(),
                selected: index == 2,
                onTap: () => setState(() => index = 2),
              ),
              _NavItem(
                icon: Icons.person,
                label: 'nav_profile'.tr(),
                selected: index == 3,
                onTap: () => setState(() => index = 3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected ? Theme.of(context).primaryColor : Colors.grey;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(fontSize: 12, color: color)),
          ],
        ),
      ),
    );
  }
}