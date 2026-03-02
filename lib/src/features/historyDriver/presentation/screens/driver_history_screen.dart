import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:uputi/src/core/constants/app_icons.dart';
import 'package:uputi/src/features/historyDriver/presentation/bloc/history_event.dart';

import '../../../../core/constants/app_color.dart';
import '../../data/models/driver_history_resposne.dart';
import '../bloc/history_bloc.dart';
import '../bloc/history_state.dart';

class DriverHistoryScreen extends StatefulWidget {
  const DriverHistoryScreen({super.key});

  @override
  State<DriverHistoryScreen> createState() => _DriverHistoryScreenState();
}

class _DriverHistoryScreenState extends State<DriverHistoryScreen>
    with SingleTickerProviderStateMixin {
  late final ScrollController _scrollController;
  late final TabController _tabController;

  int _lastType = 1;

  @override
  void initState() {
    super.initState();

    _scrollController = ScrollController()..addListener(_onScroll);
    _tabController = TabController(length: 2, vsync: this);

    _tabController.addListener(() {
      if (_tabController.indexIsChanging) return;
      final nextType = _tabController.index + 1;
      if (nextType == _lastType) return;

      _lastType = nextType;
      _scrollToTopDeferred();
      context.read<DriverHistoryBloc>().add(DriverHistoryChangeType(type: nextType));
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DriverHistoryBloc>().add(DriverHistoryFetchFirst(type: 1));
    });
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final maxScroll = _scrollController.position.maxScrollExtent;
    final current = _scrollController.offset;

    if (current >= maxScroll - 220) {
      context.read<DriverHistoryBloc>().add(DriverHistoryLoadMore());
    }
  }

  Future<void> _onRefresh() async {
    context.read<DriverHistoryBloc>().add(DriverHistoryRefresh());
    await Future<void>.delayed(const Duration(milliseconds: 350));
  }

  void _scrollToTopDeferred() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
      );
    });
  }

  void _syncTabWithState(int type) {
    final index = (type - 1).clamp(0, 1);
    if (_tabController.index == index) return;
    _tabController.animateTo(index);
  }

  @override
  void dispose() {
    _tabController.removeListener(() {});
    _tabController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ui = _HistoryUi(primary: AppColor.blueMain);

    return Scaffold(
      backgroundColor: ui.bg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleSpacing: 0,
        leadingWidth: 64,
        title:  Text(
          'history_title'.tr(),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w400,
            color: Colors.black,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(52),
          child: Column(
            children: [
              const SizedBox(height: 4),
              TabBar(
                controller: _tabController,
                labelColor: ui.primary,
                unselectedLabelColor: Colors.black54,
                indicatorColor: ui.primary,
                indicatorWeight: 2,
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13.5,
                ),
                tabs:  [
                  Tab(text: 'history_tab_created'.tr()),
                  Tab(text: 'history_tab_found'.tr()),
                ],
              ),
              Container(height: 1, color: Colors.black.withOpacity(0.06)),
            ],
          ),
        ),
      ),
      body: BlocConsumer<DriverHistoryBloc, DriverHistoryState>(
        listener: (context, state) {
          final type = switch (state) {
            DriverHistoryInitial s => s.type,
            DriverHistoryLoading s => s.type,
            DriverHistoryLoaded s => s.type,
            DriverHistoryFailure s => s.type,
            _ => 1,
          };

          _lastType = type;
          _syncTabWithState(type);
        },
        builder: (context, state) {
          if (state is DriverHistoryLoading) {
            return const Center(child: CupertinoActivityIndicator());
          }

          if (state is DriverHistoryFailure) {
            return _ErrorView(
              ui: ui,
              message: state.message,
              onRetry: () => context.read<DriverHistoryBloc>().add(
                DriverHistoryFetchFirst(type: _lastType),
              ),
            );
          }

          if (state is DriverHistoryLoaded) {
            if (state.items.isEmpty) {
              return RefreshIndicator(
                color: ui.primary,
                onRefresh: _onRefresh,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    SizedBox(height: MediaQuery.of(context).size.height * 0.22),
                    _EmptyHistory(
                      ui: ui,
                      asset: AppIcons.placeHolderHistory,
                      title: 'history_empty'.tr(),
                    ),
                  ],
                ),
              );
            }

            final footerCount = state.hasNext ? 1 : 0;

            return RefreshIndicator(
              color: ui.primary,
              onRefresh: _onRefresh,
              child: ListView.builder(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                itemCount: state.items.length + footerCount,
                itemBuilder: (context, index) {
                  final isFooter = index >= state.items.length;
                  if (isFooter) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      child: Center(
                        child: state.isLoadingMore
                            ? const CupertinoActivityIndicator()
                            : const SizedBox(height: 18),
                      ),
                    );
                  }

                  final trip = state.items[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _TripCard(trip: trip, ui: ui),
                  );
                },
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}


class _HistoryUi {
  _HistoryUi({required this.primary});

  final Color primary;
  final Color bg = const Color(0xFFF4F6F8);

  List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: Colors.black.withOpacity(0.06),
      blurRadius: 18,
      offset: const Offset(0, 10),
    ),
  ];
}


class _EmptyHistory extends StatelessWidget {
  const _EmptyHistory({
    required this.ui,
    required this.asset,
    required this.title,
  });

  final _HistoryUi ui;
  final String asset;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 320),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              asset,
              width: 50,
              height: 50,
              colorFilter: ColorFilter.mode(ui.primary, BlendMode.srcIn),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class _TripCard extends StatefulWidget {
  const _TripCard({required this.trip, required this.ui});

  final Trip trip;
  final _HistoryUi ui;

  @override
  State<_TripCard> createState() => _TripCardState();
}

class _TripCardState extends State<_TripCard> {
  bool expanded = false;

  @override
  Widget build(BuildContext context) {
    final t = widget.trip;
    final ui = widget.ui;

    final statusUi = _StatusUi.from(t.historyStatus, ui.primary);

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => setState(() => expanded = !expanded),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            boxShadow: ui.cardShadow,
          ),
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _RouteVertical(
                      from: t.fromAddress,
                      to: t.toAddress,
                      primary: ui.primary,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _Pill(
                        text: statusUi.text,
                        fg: statusUi.fg,
                        bg: statusUi.bg,
                      ),
                      const SizedBox(height: 8),
                      AnimatedRotation(
                        turns: expanded ? 0.5 : 0.0,
                        duration: const Duration(milliseconds: 180),
                        child: Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: Colors.black.withOpacity(0.45),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  _MetaChip(
                    icon: Icons.calendar_today_outlined,
                    text: t.date,
                    primary: ui.primary,
                  ),
                  const SizedBox(width: 10),
                  _MetaChip(
                    icon: Icons.access_time,
                    text: t.time,
                    primary: ui.primary,
                  ),
                  const Spacer(),
                  Text(
                    HistoryFormat.moneyUzs(t.amount),
                    style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),

              AnimatedSize(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOut,
                child: expanded
                    ? Column(
                  children: [
                    const SizedBox(height: 12),
                    Container(
                      height: 1,
                      color: Colors.black.withOpacity(0.06),
                    ),
                    const SizedBox(height: 12),
                    _PassengersSection(
                      primary: ui.primary,
                      trip: t,
                    ),
                  ],
                )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class _PassengersSection extends StatelessWidget {
  const _PassengersSection({required this.primary, required this.trip});

  final Color primary;
  final Trip trip;

  @override
  Widget build(BuildContext context) {
    final passengers = trip.passengerUsers;

    if (passengers.isEmpty) {
      return Row(
        children:  [
          Icon(Icons.info_outline, size: 18, color: Colors.black54),
          SizedBox(width: 8),
          Text(
            'history_passenger_not_found'.tr(),
            style: TextStyle(color: Colors.black54, fontWeight: FontWeight.w500),
          ),
        ],
      );
    }

    return Column(
      children: passengers
          .map((passenger) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: _PassengerRow(primary: primary, user: passenger, trip: trip),
      ))
          .toList(),
    );
  }
}

class _PassengerRow extends StatelessWidget {
  const _PassengerRow({
    required this.primary,
    required this.user,
    required this.trip,
  });

  final Color primary;
  final User user;
  final Trip trip;

  @override
  Widget build(BuildContext context) {
    final ratingText = HistoryFormat.ratingText(user.rating, user.ratingCount);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 22,
          backgroundColor: primary,
          foregroundImage:
          (user.avatar != null && user.avatar!.isNotEmpty)
              ? NetworkImage(user.avatar!)
              : null,
          child: (user.avatar == null || user.avatar!.isEmpty)
              ? Text(
            HistoryFormat.initials(user.name),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          )
              : null,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      user.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  if (ratingText != null) ...[
                    const SizedBox(width: 10),
                    _RatingChip(text: ratingText),
                  ],
                ],
              ),
              const SizedBox(height: 6),
              Text(
                user.phone,
                style: const TextStyle(
                  fontSize: 12.5,
                  color: Colors.black54,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'history_seats'.tr(namedArgs: {'count': '${trip.seats}'}),
                style: const TextStyle(
                  fontSize: 12.5,
                  color: Colors.black54,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}


class _RouteVertical extends StatelessWidget {
  const _RouteVertical({
    required this.from,
    required this.to,
    required this.primary,
  });

  final String from;
  final String to;
  final Color primary;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: SizedBox(
            width: 16,
            child: Column(
              children: [
                _Dot(color: Colors.black87),
                Container(
                  width: 2,
                  height: 22,
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.14),
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
                _Dot(color: primary),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                from,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                to,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}



class _MetaChip extends StatelessWidget {
  const _MetaChip({
    required this.icon,
    required this.text,
    required this.primary,
  });

  final IconData icon;
  final String text;
  final Color primary;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: primary.withOpacity(0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: primary),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}


class _RatingChip extends StatelessWidget {
  const _RatingChip({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    const yellow = Color(0xFFFFC107);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.black.withOpacity(0.10)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_rounded, size: 18, color: yellow),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}


class _Pill extends StatelessWidget {
  const _Pill({required this.text, required this.fg, required this.bg});

  final String text;
  final Color fg;
  final Color bg;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: fg),
      ),
    );
  }
}



class _Dot extends StatelessWidget {
  const _Dot({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}



class _ErrorView extends StatelessWidget {
  final _HistoryUi ui;
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({
    required this.ui,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'error_with_message'.tr(args: [message]),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.black54,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: ui.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: onRetry,
              child: Text('btn_retry'.tr()),
            ),
          ],
        ),
      ),
    );
  }
}



enum HistoryStatus { completed, canceled }

class _StatusUi {
  const _StatusUi({required this.text, required this.fg, required this.bg});

  final String text;
  final Color fg;
  final Color bg;

  static _StatusUi from(HistoryStatus status, Color primary) {
    switch (status) {
      case HistoryStatus.completed:
        return _StatusUi(
          text: 'history_status_completed'.tr(),
          fg: primary,
          bg: primary.withOpacity(0.10),
        );
      case HistoryStatus.canceled:
        return  _StatusUi(
          text: 'history_status_cancelled'.tr(),
          fg: Color(0xFFB42318),
          bg: Color(0xFFFFEFEF),
        );
    }
  }
}



extension TripDriverHistoryX on Trip {
  HistoryStatus get historyStatus {
    final s = status.trim().toLowerCase();
    if (s.contains('cancel') || s.contains('canceled') || s.contains('reject')) {
      return HistoryStatus.canceled;
    }
    return HistoryStatus.completed;
  }

  List<User> get passengerUsers {
    if (bookings.isEmpty) return [];
    return bookings
        .where((b) {
      final r1 = b.role.toLowerCase();
      final r2 = b.user.role.toLowerCase();
      return r1 == 'passenger' || r2 == 'passenger';
    })
        .map((b) => b.user)
        .toList();
  }
}


class HistoryFormat {
  static String moneyUzs(int value) {
    final s = value.toString();
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      final fromEnd = s.length - i;
      buf.write(s[i]);
      if (fromEnd > 1 && fromEnd % 3 == 1) buf.write(' ');
    }
    return "${buf.toString()} so'm";
  }

  static String initials(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return ' ';
    final parts = trimmed.split(RegExp(r'\s+'));
    String firstRune(String s) => String.fromCharCode(s.runes.first).toUpperCase();
    if (parts.length == 1) return firstRune(parts.first);
    return '${firstRune(parts.first)}${firstRune(parts.last)}';
  }

  static String? ratingText(int? rating, int? count) {
    if (rating == null) return null;
    if (count == null || count <= 0) return rating.toString();
    return '$rating ($count)';
  }
}