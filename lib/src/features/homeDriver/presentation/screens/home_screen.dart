import 'dart:async';

import 'package:easy_localization/easy_localization.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:uputi/src/core/constants/app_images.dart';
import 'package:uputi/src/helpers/flushbar.dart';

import '../../../../../main.dart';
import '../../../../core/constants/app_color.dart';
import '../../../../core/router/pages.dart';
import '../../../../core/storage/shared_storage.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uputi/src/features/homePassenger/presentation/widgets/home_appbar.dart';
import 'package:uputi/src/features/homePassenger/presentation/widgets/telegram_dialog.dart';

import '../bloc/home_bloc.dart';
import '../widgets/shimmer_widgets.dart';
import '../bloc/home_event.dart';
import '../bloc/home_state.dart';
import '../widgets/list_items.dart';

class HomeDriverScreen extends StatefulWidget {
  final ValueNotifier<bool> isVisible;

  const HomeDriverScreen({super.key, required this.isVisible});

  @override
  State<HomeDriverScreen> createState() => _HomeDriverScreenState();
}

class _HomeDriverScreenState extends State<HomeDriverScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver, RouteAware {
  static const Duration _pollInterval = Duration(seconds: 10);
  bool _routeSubbed = false;
  late final TabController _tabController;
  final ScrollController _scrollController = ScrollController();
  int _tabIndex = 0;

  bool _isTelegramDialogOpen = false;
  Timer? _tgBurstTimer;
  int _tgBurstAttempt = 0;
  static const int _tgBurstMax = 5;

  Timer? _pollTimer;
  bool _booted = false;

  bool _loggedOut = false;
  bool _switchingTabProgrammatically = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _tabController = TabController(length: 2, vsync: this);

    _tabController.addListener(() {
      if (_tabIndex == _tabController.index) return;
      setState(() => _tabIndex = _tabController.index);

      if (_switchingTabProgrammatically) return;

      final bloc = context.read<HomeDriverBloc>();
      if (_tabIndex == 1) {
        bloc.add(DriverMyTripsTabOpened());
      } else {
        bloc.add(HomeDriverSilentRefresh());
      }
    });

    _scrollController.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      context.read<HomeDriverBloc>().add(HomeDriverInit());
      if (mounted) setState(() => _booted = true);
    });

    widget.isVisible.addListener(_onVisibilityChanged);
  }

  void _onVisibilityChanged() {
    if (!mounted) return;
    if (widget.isVisible.value) {
      _startPolling();
      final bloc = context.read<HomeDriverBloc>();
      if (_tabIndex == 1) {
        bloc.add(DriverRefreshMyTripsPressed());
      } else {
        bloc.add(HomeDriverSilentRefresh());
      }
    } else {
      _stopPolling();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_routeSubbed) return;
    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      routeObserver.subscribe(this, route);
      _routeSubbed = true;
    }
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final pos = _scrollController.position;
    if (pos.pixels >= pos.maxScrollExtent - 220) {
      context.read<HomeDriverBloc>().add(LoadMoreActiveTrips());
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    widget.isVisible.removeListener(_onVisibilityChanged);
    routeObserver.unsubscribe(this);
    _stopPolling();
    _stopTelegramBurstCheck();
    WidgetsBinding.instance.removeObserver(this);
    _tabController.dispose();
    super.dispose();
  }

  @override
  void didPopNext() {
    if (!widget.isVisible.value) return;
    _startPolling();
    if (!mounted) return;
    context.read<HomeDriverBloc>().add(HomeDriverSilentRefresh());
  }

  @override
  void didPushNext() => _stopPolling();

  @override
  void didPop() => _stopPolling();

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!mounted) return;
    final isCurrent = ModalRoute.of(context)?.isCurrent ?? true;

    if (state == AppLifecycleState.resumed) {
      if (!isCurrent) return;
      if (!widget.isVisible.value) return;
      _startPolling();
      context.read<HomeDriverBloc>().add(HomeDriverSilentRefresh());
      if (_isTelegramDialogOpen) _startTelegramBurstCheck();
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      _stopPolling();
    }
  }

  void _startPolling() {
    if (!widget.isVisible.value) return;

    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(_pollInterval, (_) {
      if (!mounted) {
        _stopPolling();
        return;
      }
      // IndexedStack da isCurrent har doim true bo'ladi,
      // shuning uchun isVisible ni ishlatamiz
      if (!widget.isVisible.value) {
        _stopPolling();
        return;
      }
      context.read<HomeDriverBloc>().add(HomeDriverSilentRefresh());
    });
  }

  void _stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  void _logout() {
    if (_loggedOut) return;
    _loggedOut = true;
    _stopPolling();
    _stopTelegramBurstCheck();
    Prefs.clear();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, Pages.login);
  }

  void _showMessages(BuildContext context, HomeDriverLoaded s) {
    final msg =
        s.cancelMessage ??
            s.createMessage ??
            s.completeMessage ??
            s.acceptMessage ??
            s.rejectMessage;
    if (msg != null && msg.isNotEmpty) {
      (msg.startsWith("Exception")
          ? showErrorFlushBar(msg)
          : showSuccessFlushBar(msg))
          .show(context);
    }
    final err =
        s.cancelError ??
            s.createError ??
            s.completeError ??
            s.acceptError ??
            s.rejectError;
    if (err != null && err.isNotEmpty) {
      showErrorFlushBar(err).show(context);
    }
  }

  Future<void> _syncTelegramDialog(HomeDriverLoaded s) async {
    final bool connected = (s.user.telegramChatId ?? 0) != 0;

    if (connected) {
      _stopTelegramBurstCheck();
      if (_isTelegramDialogOpen && mounted) {
        final nav = Navigator.of(context, rootNavigator: true);
        if (nav.canPop()) nav.pop();
        _isTelegramDialogOpen = false;
      }
      return;
    }

    if (_isTelegramDialogOpen || !mounted) return;
    _isTelegramDialogOpen = true;
    await showTelegramConnectDialog(
      context,
      s.user.id!.toInt(),
      onCheckConnected: () async {
        final bloc = context.read<HomeDriverBloc>();
        bloc.add(HomeDriverSilentRefresh());

        for (int i = 0; i < 10; i++) {
          await Future.delayed(const Duration(milliseconds: 500));
          final st = bloc.state;
          if (st is HomeDriverLoaded) {
            final newChatId = st.user.telegramChatId ?? 0;
            if (newChatId != 0) return true;
          }
        }
        return false;
      },
    );
    if (mounted) _isTelegramDialogOpen = false;
    _stopTelegramBurstCheck();
  }

  void _startTelegramBurstCheck() {
    _stopTelegramBurstCheck();
    _tgBurstAttempt = 0;
    _tgBurstTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      if (!mounted) return;
      final route = ModalRoute.of(context);
      if (route != null && route.isCurrent != true) return;
      if (!_isTelegramDialogOpen) {
        _stopTelegramBurstCheck();
        return;
      }
      _tgBurstAttempt++;
      context.read<HomeDriverBloc>().add(HomeDriverSilentRefresh());
      if (_tgBurstAttempt >= _tgBurstMax) _stopTelegramBurstCheck();
    });
  }

  void _stopTelegramBurstCheck() {
    _tgBurstTimer?.cancel();
    _tgBurstTimer = null;
    _tgBurstAttempt = 0;
  }

  Future<void> _showLanguageSheet() async {
    final current = context.locale;
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => _LanguageSheet(
        current: current,
        onPick: (locale) async {
          Navigator.of(ctx).pop();
          await context.setLocale(locale);
          if (mounted) setState(() {});
        },
      ),
    );
  }

  Widget _topTabBar() {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: AppColor.blueMain.withOpacity(0.25),
            width: 1,
          ),
        ),
        child: TabBar(
          controller: _tabController,
          splashBorderRadius: BorderRadius.circular(14),
          indicatorSize: TabBarIndicatorSize.tab,
          dividerColor: Colors.transparent,
          labelColor: AppColor.blueMain,
          unselectedLabelColor: const Color(0xFF6B7280),
          labelStyle: const TextStyle(fontWeight: FontWeight.w600),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500),
          indicator: BoxDecoration(
            color: AppColor.blueMain.withOpacity(0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          tabs: [
            Tab(text: 'home_tab_bookings'.tr()),
            Tab(text
                : 'home_tab_orders'.tr()),
          ],
        ),
      ),
    );
  }

  Widget _myBookingsSection(HomeDriverLoaded data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (data.inProgress.isEmpty)
          Padding(
            padding: EdgeInsets.only(top: 24),
            child: Center(child: Text('home_no_bookings'.tr())),
          )
        else
          ...data.inProgress.map(
                (b) => TripCard.booking(b,
                  (bookingId) {
                if (data.isCancelLoading) return;
                context.read<HomeDriverBloc>().add(
                  DriverCancelBookingPressed(bookingId: bookingId),
                );
              },
                  (tripId) {
                if (data.isCompleteLoading) return;
                context.read<HomeDriverBloc>().add(
                  DriverCompleteMyBookingTripPressed(tripId: tripId),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _myTripsSection(HomeDriverLoaded data) {
    if (data.isMyTripsLoading) {
      return const Padding(
        key: ValueKey('trips_loading'),
        padding: EdgeInsets.only(top: 32),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (data.myTripsError != null && data.myTripsError!.isNotEmpty) {
      return Padding(
        key: const ValueKey('trips_error'),
        padding: const EdgeInsets.only(top: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(data.myTripsError!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => context.read<HomeDriverBloc>().add(
                DriverRefreshMyTripsPressed(),
              ),
              child: Text('btn_retry'.tr()),
            ),
          ],
        ),
      );
    }

    if (!data.myTripsLoadedOnce) {
      return const SizedBox.shrink();
    }

    if (data.myTrips.isEmpty) {
      return Padding(
        key: ValueKey('my_trips_empty'),
        padding: EdgeInsets.only(top: 24),
        child: Center(child: Text('home_no_trips'.tr())),
      );
    }

    return Column(
      key: const ValueKey('my_trips'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...data.myTrips.map(
              (t) => MyTripCard.trip(
            t,
                (tripId) {
              if (data.isCompleteLoading) return;
              context.read<HomeDriverBloc>().add(
                DriverCompleteTripPressed(tripId: tripId),
              );
            },
            onAcceptBooking: (bookingId) {
              if (data.isAcceptLoading) return;
              context.read<HomeDriverBloc>().add(
                DriverAcceptIncomingBookingPressed(bookingId: bookingId),
              );
            },
            onRejectBooking: (bookingId) {
              if (data.isRejectLoading) return;
              context.read<HomeDriverBloc>().add(
                DriverRejectIncomingBookingPressed(bookingId: bookingId),
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeDriverBloc, HomeDriverState>(
      buildWhen: (prev, curr) {
        if (curr is! HomeDriverLoaded) return false;
        if (prev is! HomeDriverLoaded) return true;
        return prev.user.balance != curr.user.balance;
      },
      builder: (_, appBarState) {
        final bal = appBarState is HomeDriverLoaded
            ? (appBarState.user.balance ?? 0)
            : 0;
        final appBarBalance = _fmtBalance(bal);
        return Scaffold(
          appBar: UPuttiHomeAppBar(
            logoAsset: AppImages.logo,
            balance: appBarBalance,
            locale: context.locale,
            onLanguageTap: _showLanguageSheet,
            onBalanceTap: () async {
              final uri = Uri.parse('https://t.me/Uputi_balance');
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              }
            },
          ),
          backgroundColor: const Color(0xFFF5F7FB),
          body: MultiBlocListener(
            listeners: [
              BlocListener<HomeDriverBloc, HomeDriverState>(
                listenWhen: (_, curr) => curr is HomeDriverUnauthorized,
                listener: (_, __) => _logout(),
              ),
              BlocListener<HomeDriverBloc, HomeDriverState>(
                listenWhen: (prev, curr) =>
                prev is! HomeDriverLoaded && curr is HomeDriverLoaded,
                listener: (_, __) => _startPolling(),
              ),
              BlocListener<HomeDriverBloc, HomeDriverState>(
                listenWhen: (prev, curr) {
                  if (prev is! HomeDriverLoaded || curr is! HomeDriverLoaded)
                    return false;
                  return !prev.isMyTripsLoading &&
                      curr.isMyTripsLoading &&
                      _tabIndex != 1;
                },
                listener: (_, __) {
                  if (_tabIndex == 1) return;
                  _switchingTabProgrammatically = true;
                  _tabController.animateTo(1);
                  setState(() => _tabIndex = 1);
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _switchingTabProgrammatically = false;
                  });
                },
              ),
              BlocListener<HomeDriverBloc, HomeDriverState>(
                listenWhen: (prev, curr) {
                  if (curr is! HomeDriverLoaded) return false;
                  if (prev is! HomeDriverLoaded) return true;
                  return prev.cancelMessage != curr.cancelMessage ||
                      prev.cancelError != curr.cancelError ||
                      prev.createMessage != curr.createMessage ||
                      prev.createError != curr.createError ||
                      prev.completeMessage != curr.completeMessage ||
                      prev.completeError != curr.completeError ||
                      prev.acceptMessage != curr.acceptMessage ||
                      prev.acceptError != curr.acceptError ||
                      prev.rejectMessage != curr.rejectMessage ||
                      prev.rejectError != curr.rejectError ||
                      prev.user.telegramChatId != curr.user.telegramChatId;
                },
                listener: (context, state) async {
                  if (state is HomeDriverLoaded) {
                    _showMessages(context, state);
                    await _syncTelegramDialog(state);
                  }
                },
              ),
            ],
            child: BlocBuilder<HomeDriverBloc, HomeDriverState>(
              builder: (_, state) {
                if (state is HomeDriverUnauthorized) {
                  return const SizedBox.shrink();
                }

                if (state is HomeDriverError) {
                  return Center(child: Text(state.message));
                }

                if (state is HomeDriverLoading || state is HomeDriverInitial) {
                  return const HomeShimmerList();
                }

                final data = state as HomeDriverLoaded;

                return RefreshIndicator(
                  onRefresh: () async {
                    _stopPolling();
                    final bloc = context.read<HomeDriverBloc>();
                    final completer = Completer<void>();

                    // Event yuborishdan OLDIN stream'ni boshlash
                    // va loading boshlangach tugashini kuzatish
                    bool loadingStarted = false;
                    StreamSubscription? sub;
                    sub = bloc.stream.listen((s) {
                      if (s is! HomeDriverLoaded) return;
                      if (_tabIndex == 1) {
                        if (s.isMyTripsLoading) {
                          loadingStarted = true;
                          return;
                        }
                        // loading boshlangan bo'lsa yoki hech qachon true bo'lmagan
                        // bo'lsa ham complete qilamiz
                        if (loadingStarted || !s.isMyTripsLoading) {
                          sub?.cancel();
                          if (!completer.isCompleted) completer.complete();
                        }
                      } else {
                        if (s.isTripsLoadingMore) return;
                        sub?.cancel();
                        if (!completer.isCompleted) completer.complete();
                      }
                    });

                    if (_tabIndex == 1) {
                      bloc.add(DriverRefreshMyTripsPressed());
                    } else {
                      bloc.add(HomeDriverSilentRefresh());
                    }

                    await completer.future.timeout(
                      const Duration(seconds: 10),
                      onTimeout: () {},
                    );
                    sub.cancel();
                    _startPolling();
                  },
                  child: ListView(
                    controller: _scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    children: [
                      _topTabBar(),
                      const SizedBox(height: 12),

                      _tabIndex == 0
                          ? _myBookingsSection(data)
                          : _myTripsSection(data),

                      const SizedBox(height: 26),
                      _SectionTitle('home_active_passenger_orders'.tr()),
                      const SizedBox(height: 12),

                      ...data.trips.map(
                            (t) => TripCard.passengerTrip(t, () {
                          if (data.isCreateLoading) return;
                          context.read<HomeDriverBloc>().add(
                            DriverCreateBookingRequested(tripId: t.id),
                          );
                        }),
                      ),

                      if (data.tripsHasMore) ...[
                        const SizedBox(height: 8),
                        data.isTripsLoadingMore
                            ? const Center(child: CircularProgressIndicator())
                            : TextButton(
                          onPressed: () => context
                              .read<HomeDriverBloc>()
                              .add(LoadMoreActiveTrips()),
                          child: Text('home_show_more'.tr()),
                        ),
                      ],

                      const SizedBox(height: 24),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
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

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 16.5,
        fontWeight: FontWeight.w600,
        color: Color(0xFF111827),
      ),
    );
  }
}

class _LanguageSheet extends StatelessWidget {
  const _LanguageSheet({required this.current, required this.onPick});
  final Locale current;
  final void Function(Locale) onPick;

  static const _options = [
    (locale: Locale('uz'), titleKey: 'lang_uz', icon: 'assets/icons/ic_uzbek.png'),
    (locale: Locale('ru'), titleKey: 'lang_ru', icon: 'assets/icons/ic_russian.png'),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 10),
          Container(width: 44, height: 5, decoration: BoxDecoration(color: const Color(0xFFE5E7EB), borderRadius: BorderRadius.circular(100))),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Align(alignment: Alignment.centerLeft, child: Text('profile_language_title'.tr(), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF111827)))),
          ),
          const SizedBox(height: 8),
          const Divider(height: 1, color: Color(0xFFE5E7EB)),
          for (final o in _options) ...[
            InkWell(
              onTap: () => onPick(o.locale),
              child: SizedBox(
                height: 56,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      ClipRRect(borderRadius: BorderRadius.circular(6), child: Image.asset(o.icon, width: 28, height: 20, fit: BoxFit.cover)),
                      const SizedBox(width: 12),
                      Expanded(child: Text(o.titleKey.tr(), style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF111827)))),
                      if (o.locale.languageCode == current.languageCode) const Icon(Icons.check, size: 20, color: Color(0xFF111827)),
                    ],
                  ),
                ),
              ),
            ),
            const Divider(height: 1, color: Color(0xFFE5E7EB)),
          ],
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}