import 'dart:async';

import 'package:easy_localization/easy_localization.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart' as geo;

import 'package:uputi/src/core/constants/app_images.dart';
import 'package:uputi/src/helpers/flushbar.dart';

import '../../../../../main.dart';
import '../../../../core/constants/app_color.dart';
import '../../../../core/router/pages.dart';
import '../../../../core/storage/shared_storage.dart';
import '../../../homeDriver/presentation/widgets/shimmer_widgets.dart';
import '../bloc/home_passenger_bloc.dart';
import '../widgets/home_appbar.dart';
import '../widgets/list_items.dart';
import 'package:uputi/src/features/homePassenger/presentation/widgets/create_booking_dialog.dart';
import 'package:uputi/src/features/homePassenger/presentation/widgets/offer_price_dialog.dart';
import 'package:uputi/src/features/homePassenger/presentation/widgets/telegram_dialog.dart';

class HomePassengerScreen extends StatefulWidget {
  final ValueNotifier<bool> isVisible;

  const HomePassengerScreen({super.key, required this.isVisible});

  @override
  State<HomePassengerScreen> createState() => _HomePassengerScreenState();
}

class _HomePassengerScreenState extends State<HomePassengerScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver, RouteAware {
  static const double _defaultLat = 41.311081;
  static const double _defaultLng = 69.240562;
  static const int _radius = 18;

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
  double _lastLat = _defaultLat;
  double _lastLng = _defaultLng;

  bool _booted = false;
  bool _loggedOut = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _tabController = TabController(length: 2, vsync: this);

    _tabController.addListener(() {
      if (_tabIndex == _tabController.index) return;

      setState(() => _tabIndex = _tabController.index);

      final bloc = context.read<HomePassengerBloc>();
      final st = bloc.state;

      if (_tabIndex == 1) {
        if (st is HomePassengerLoaded && !st.myTripsLoadedOnce) {
          bloc.add(MyTripsTabOpened());
        } else {
          bloc.add( HomePassengerSilentRefresh(isTab1: true));
        }
      } else {
        bloc.add( HomePassengerSilentRefresh(isTab1: false));
      }
    });

    _scrollController.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _load(withLocation: true);
      if (mounted) setState(() => _booted = true);
      _startPolling();
    });

    widget.isVisible.addListener(_onVisibilityChanged);
  }

  void _onVisibilityChanged() {
    if (!mounted) return;
    if (widget.isVisible.value) {
      _startPolling();
      final st = context.read<HomePassengerBloc>().state;
      if (st is HomePassengerLoaded) {
        context.read<HomePassengerBloc>().add(
          HomePassengerSilentRefresh(isTab1: _tabIndex == 1),
        );
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
      context.read<HomePassengerBloc>().add(LoadMoreActiveTrips());
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
    _startPolling();
    if (!mounted) return;
    context.read<HomePassengerBloc>().add(
      HomePassengerSilentRefresh(isTab1: _tabIndex == 1),
    );
  }

  @override
  void didPushNext() => _stopPolling();

  @override
  void didPop() => _stopPolling();

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!mounted) return;

    final route = ModalRoute.of(context);
    final isCurrent = route?.isCurrent ?? true;

    if (state == AppLifecycleState.resumed) {
      if (!isCurrent) return;
      if (!_booted) return;
      _startPolling();
      _load(withLocation: false);
      if (_isTelegramDialogOpen) _startTelegramBurstCheck();
      return;
    }
  }

  void _startPolling() {
    if (!widget.isVisible.value) return;
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(_pollInterval, (_) {
      if (!mounted) { _stopPolling(); return; }
      if (!widget.isVisible.value) { _stopPolling(); return; }

      final bloc = context.read<HomePassengerBloc>();
      if (bloc.state is! HomePassengerLoaded) return;

      bloc.add(HomePassengerSilentRefresh(isTab1: _tabIndex == 1));
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

  Future<void> _load({required bool withLocation}) async {
    if (withLocation) {
      final pos = await _getLocation();
      _lastLat = pos?.latitude ?? _defaultLat;
      _lastLng = pos?.longitude ?? _defaultLng;
    }

    if (!mounted) return;
    final bloc = context.read<HomePassengerBloc>();
    final st = bloc.state;

    if (st is HomePassengerLoaded) {
      bloc.add(HomePassengerSilentRefresh(isTab1: _tabIndex == 1));
    } else if (st is! HomePassengerLoading) {
      bloc.add(HomePassengerInit());
    }
  }

  Future<geo.Position?> _getLocation() async {
    try {
      var permission = await geo.Geolocator.checkPermission();
      if (permission == geo.LocationPermission.denied) {
        permission = await geo.Geolocator.requestPermission();
        if (permission == geo.LocationPermission.denied) return null;
      }
      if (permission == geo.LocationPermission.deniedForever) return null;
      return await geo.Geolocator.getCurrentPosition();
    } catch (_) {
      return null;
    }
  }

  void _showMessages(BuildContext context, HomePassengerLoaded s) {
    final msg =
        s.cancelMessage ??
            s.tripCancelMessage ??
            s.createMessage ??
            s.offerMessage;

    if (msg != null && msg.isNotEmpty) {
      (msg.startsWith("Exception")
          ? showErrorFlushBar(msg)
          : showSuccessFlushBar(msg))
          .show(context);
    }

    final err =
        s.cancelError ?? s.tripCancelError ?? s.createError ?? s.offerError;

    if (err != null && err.isNotEmpty) {
      showErrorFlushBar(err).show(context);
    }
  }

  Future<void> _syncTelegramDialog(HomePassengerLoaded s) async {
    final int chatId = s.user.telegramChatId ?? 0;
    final bool connected = chatId != 0;

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
        final bloc = context.read<HomePassengerBloc>();
        bloc.add( HomePassengerSilentRefresh(isTab1: false));

        for (int i = 0; i < 10; i++) {
          await Future.delayed(const Duration(milliseconds: 500));
          final st = bloc.state;
          if (st is HomePassengerLoaded) {
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

      _load(withLocation: false);

      if (_tgBurstAttempt >= _tgBurstMax) {
        _stopTelegramBurstCheck();
      }
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
            Tab(text: 'home_tab_my_orders'.tr()),
          ],
        ),
      ),
    );
  }

  Widget _myBookingsSection(HomePassengerLoaded data) {
    return Column(
      key: const ValueKey('bookings'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (data.inProgress.isEmpty)
          Padding(
            padding: EdgeInsets.only(top: 24),
            child: Center(child: Text('home_no_passenger_bookings'.tr())),
          )
        else
          ...data.inProgress.map(
                (b) => TripCard.booking(b, (bookingId) {
              if (data.isCancelLoading) return;
              context.read<HomePassengerBloc>().add(
                CancelBookingPressed(bookingId: int.parse(bookingId)),
              );
            }),
          ),
      ],
    );
  }

  Widget _myOrdersSection(HomePassengerLoaded data) {
    if (data.myTripsError != null && data.myTripsError!.isNotEmpty) {
      return Padding(
        key: const ValueKey('orders_error'),
        padding: const EdgeInsets.only(top: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(data.myTripsError!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                context.read<HomePassengerBloc>().add(RefreshMyTripsPressed());
              },
              child: Text('btn_retry'.tr()),
            ),
          ],
        ),
      );
    }

    if (data.isMyTripsLoading && !data.myTripsLoadedOnce && !data.isTripCancelLoading) {
      return const Padding(
        key: ValueKey('orders_loading'),
        padding: EdgeInsets.only(top: 40),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (!data.myTripsLoadedOnce) {
      return const SizedBox.shrink();
    }

    if (data.myTrips.isEmpty) {
      return Padding(
        key: ValueKey('orders_empty'),
        padding: EdgeInsets.only(top: 24),
        child: Center(child: Text('home_no_passenger_orders'.tr())),
      );
    }

    return Column(
      key: const ValueKey('orders'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [...data.myTrips.map((t) => MyTripCard.trip(t))],
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomePassengerBloc, HomePassengerState>(
      buildWhen: (prev, curr) {
        if (curr is! HomePassengerLoaded) return false;
        if (prev is! HomePassengerLoaded) return true;
        return prev.user.balance != curr.user.balance;
      },
      builder: (_, appBarState) {
        final bal = appBarState is HomePassengerLoaded
            ? (appBarState.user.balance ?? 0)
            : 0;
        final appBarBalance = _fmtBalance(bal);
        return Scaffold(
          appBar: UPuttiHomeAppBar(
            logoAsset: AppImages.logo,
            balance: appBarBalance,
            locale: context.locale,
            onLanguageTap: _showLanguageSheet,
          ),
          backgroundColor: const Color(0xFFF5F7FB),
          body: MultiBlocListener(
            listeners: [
              BlocListener<HomePassengerBloc, HomePassengerState>(
                listenWhen: (_, curr) => curr is HomePassengerUnauthorized,
                listener: (_, __) => _logout(),
              ),
              BlocListener<HomePassengerBloc, HomePassengerState>(
                listenWhen: (prev, curr) {
                  if (prev is! HomePassengerLoaded ||
                      curr is! HomePassengerLoaded)
                    return false;
                  return !prev.isMyTripsLoading &&
                      curr.isMyTripsLoading &&
                      _tabIndex != 1;
                },
                listener: (_, __) {
                  _tabController.animateTo(1);
                  setState(() => _tabIndex = 1);
                },
              ),
              BlocListener<HomePassengerBloc, HomePassengerState>(
                listenWhen: (prev, curr) {
                  if (curr is! HomePassengerLoaded) return false;
                  if (prev is! HomePassengerLoaded) return true;

                  return prev.cancelMessage != curr.cancelMessage ||
                      prev.cancelError != curr.cancelError ||
                      prev.createMessage != curr.createMessage ||
                      prev.createError != curr.createError ||
                      prev.offerMessage != curr.offerMessage ||
                      prev.offerError != curr.offerError ||
                      prev.tripCancelMessage != curr.tripCancelMessage ||
                      prev.tripCancelError != curr.tripCancelError ||
                      prev.user.telegramChatId != curr.user.telegramChatId;
                },
                listener: (context, state) async {
                  if (state is HomePassengerLoaded) {
                    _showMessages(context, state);
                    await _syncTelegramDialog(state);
                  }
                },
              ),
            ],
            child: BlocBuilder<HomePassengerBloc, HomePassengerState>(
              builder: (_, state) {
                if (state is HomePassengerUnauthorized) {
                  return const SizedBox.shrink();
                }

                if (state is HomePassengerError) {
                  return Center(child: Text(state.message));
                }

                if (state is HomePassengerLoading ||
                    state is HomePassengerInitial) {
                  return const HomeShimmerList();
                }

                final data = state as HomePassengerLoaded;

                return RefreshIndicator(
                  onRefresh: () async {
                    _stopPolling();
                    final bloc = context.read<HomePassengerBloc>();
                    final completer = Completer<void>();

                    bool loadingStarted = false;
                    StreamSubscription? sub;
                    sub = bloc.stream.listen((s) {
                      if (s is! HomePassengerLoaded) return;
                      if (_tabIndex == 1) {
                        if (s.isMyTripsLoading) { loadingStarted = true; return; }
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
                      bloc.add(RefreshMyTripsPressed());
                    } else {
                      bloc.add( HomePassengerSilentRefresh(isTab1: false));
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
                          : _myOrdersSection(data),
                      const SizedBox(height: 26),
                      _SectionTitle('home_all_driver_trips'.tr()),
                      const SizedBox(height: 12),
                      ...data.trips.map(
                            (t) => TripCard.driver(
                          t,
                              (tripId) async {
                            final seats = await showSeatsBottomSheet(
                              context,
                              min: 1,
                              max: 4,
                            );
                            if (!context.mounted || seats == null) return;

                            context.read<HomePassengerBloc>().add(
                              CreateBookingRequested(
                                tripId: t.id,
                                seats: seats,
                              ),
                            );
                          },
                              (tripId) async {
                            final res = await showOfferPriceBottomSheet(
                              context,
                              minSeats: 1,
                              maxSeats: 4,
                            );
                            if (!context.mounted || res == null) return;

                            context.read<HomePassengerBloc>().add(
                              OfferPriceRequested(
                                tripId: int.parse(tripId),
                                seats: res.seats,
                                offeredPrice: res.price,
                                comment: res.comment,
                              ),
                            );
                          },
                        ),
                      ),

                      if (data.isTripsLoadingMore)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Center(child: CircularProgressIndicator()),
                        )
                      else if (data.tripsHasMore)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: TextButton(
                            onPressed: () => context
                                .read<HomePassengerBloc>()
                                .add(LoadMoreActiveTrips()),
                            child: Text('home_show_more'.tr()),
                          ),
                        ),

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