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
  late final HistoryBloc _historyBloc;
  late final ProfileBloc _profileBloc;
  final ValueNotifier<bool> _homeVisible = ValueNotifier<bool>(true);

  late final List<Widget> pages;

  bool _historyLoaded = false;
  bool _profileLoaded = false;

  @override
  void initState() {
    super.initState();

    _homeBloc = sl<HomePassengerBloc>();
    _historyBloc = sl<HistoryBloc>();
    _profileBloc = sl<ProfileBloc>();

    pages = [
      BlocProvider.value(
        value: _homeBloc,
        child: HomePassengerScreen(isVisible: _homeVisible),
      ),
      BlocProvider(
        create: (_) => sl<SearchTripsBloc>(),
        child: const SearchPassengersScreen(),
      ),
      BlocProvider.value(
        value: _historyBloc,
        child: const PassengersHistoryScreen(),
      ),
      BlocProvider.value(
        value: _profileBloc,
        child: const PassengersProfileScreen(),
      ),
    ];
  }

  @override
  void dispose() {
    _homeVisible.dispose();
    _homeBloc.close();
    _historyBloc.close();
    _profileBloc.close();
    super.dispose();
  }

  Future<void> _onFabTap() async {
    final res = await Navigator.pushNamed(context, Pages.createTrip);
    if (!mounted) return;
    setState(() => index = 0);
    // didPopNext HomePassengerScreen da refresh qiladi
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
                onTap: () {
                  setState(() => index = 0);
                  _homeVisible.value = true;
                },
              ),
              _NavItem(
                icon: Icons.search,
                label: 'nav_search'.tr(),
                selected: index == 1,
                onTap: () {
                  setState(() => index = 1);
                  _homeVisible.value = false;
                },
              ),
              const SizedBox(width: 40),
              _NavItem(
                icon: Icons.history,
                label: 'nav_history'.tr(),
                selected: index == 2,
                onTap: () {
                  setState(() => index = 2);
                  _homeVisible.value = false;
                  if (!_historyLoaded) {
                    _historyLoaded = true;
                    _historyBloc.add(HistoryFetchFirst(type: 1));
                  }
                },
              ),
              _NavItem(
                icon: Icons.person,
                label: 'nav_profile'.tr(),
                selected: index == 3,
                onTap: () {
                  setState(() => index = 3);
                  _homeVisible.value = false;
                  if (!_profileLoaded) {
                    _profileLoaded = true;
                    _profileBloc.add(const ProfileFetch());
                  }
                },
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