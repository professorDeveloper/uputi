import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../di/di.dart';
import '../blocs/city_search_bloc.dart';
import '../blocs/search_trips_bloc.dart';
import 'city_search_tab.dart';
import '../../../homePassenger/presentation/widgets/list_items.dart';
import '../../../homePassenger/presentation/widgets/create_booking_dialog.dart';
import '../../../homePassenger/presentation/widgets/offer_price_dialog.dart';

class SearchPassengersScreen extends StatefulWidget {
  const SearchPassengersScreen({super.key});

  @override
  State<SearchPassengersScreen> createState() => _SearchPassengersScreenState();
}

class _SearchPassengersScreenState extends State<SearchPassengersScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [BlocProvider(create: (_) => sl<SearchTripsBloc>())],
      child: Scaffold(
        backgroundColor: _RegionsSearchTab._bg,
        appBar: AppBar(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          title: Text(
            'search_title'.tr(),
            style: const TextStyle(
              fontSize: 18,
              color: _RegionsSearchTab._text,
              fontWeight: FontWeight.w500,
            ),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(58),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
              child: Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _RegionsSearchTab._border),
                ),
                child: TabBar(
                  controller: _tab,
                  physics: const NeverScrollableScrollPhysics(),
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  indicator: BoxDecoration(
                    color: _RegionsSearchTab._softPrimary,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  labelColor: _RegionsSearchTab._primary,
                  unselectedLabelColor: _RegionsSearchTab._muted,
                  labelStyle: const TextStyle(fontWeight: FontWeight.w600),
                  unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500),
                  tabs: [
                    Tab(text: 'search_tab_regions'.tr()),
                    Tab(text: 'search_tab_city'.tr()),
                  ],
                ),
              ),
            ),
          ),
        ),
        body: TabBarView(
          physics: const NeverScrollableScrollPhysics(),
          controller: _tab,
          children: [
            const _RegionsSearchTab(),
            BlocProvider(
              create: (_) => sl<CitySearchBloc>(),
              child: const CitySearchTab(),
            ),
          ],
        ),
      ),
    );
  }
}

class _RegionsSearchTab extends StatefulWidget {
  const _RegionsSearchTab();

  static const _bg = Color(0xFFF3F6FB);
  static const _border = Color(0xFFE6EDF7);
  static const _text = Color(0xFF163A63);
  static const _muted = Color(0xFF7B8EA6);
  static const _primary = Color(0xFF2D7DFF);
  static const _softPrimary = Color(0xFFE8F1FF);
  static const _fieldBg = Color(0xFFF7FAFF);

  @override
  State<_RegionsSearchTab> createState() => _RegionsSearchTabState();
}

class _RegionsSearchTabState extends State<_RegionsSearchTab>
    with AutomaticKeepAliveClientMixin {
  bool _filtersExpanded = true;

  String _from = 'Andijon';
  String _to = 'Samarqand';
  DateTime? _date;

  final List<String> _cities = const [
    'Toshkent', 'Andijon', 'Farg\'ona', 'Namangan', 'Sirdaryo',
    'Jizzax', 'Samarqand', 'Qashqadaryo', 'Surxondaryo',
    'Buxoro', 'Navoiy', 'Xorazm', 'Qoraqalpog\'iston',
  ];

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SafeArea(
      bottom: false,
      child: MultiBlocListener(
        listeners: [
          BlocListener<SearchTripsBloc, SearchTripsState>(
            listenWhen: (p, c) {
              if (c is! SearchTripsLoaded) return false;
              if (p is! SearchTripsLoaded) return true;
              return p.actionMessage != c.actionMessage ||
                  p.actionError != c.actionError ||
                  p.actionLoading != c.actionLoading;
            },
            listener: (context, state) {
              final s = state as SearchTripsLoaded;
              final msg = (s.actionMessage ?? '').trim();
              final err = (s.actionError ?? '').trim();
              if (msg.isNotEmpty) {
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text(msg)));
              }
              if (err.isNotEmpty) {
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text(err)));
              }
            },
          ),
        ],
        child: ListView(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 20),
          children: [
            if (_filtersExpanded) ...[
              _filtersCard(context),
              const SizedBox(height: 12),
            ],
            _actionRow(context),
            const SizedBox(height: 14),
            Text(
              'search_results'.tr(),
              style: const TextStyle(
                fontSize: 16,
                color: _RegionsSearchTab._text,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 10),
            _results(context),
          ],
        ),
      ),
    );
  }

  Widget _filtersCard(BuildContext context) {
    return _surface(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          _field(
            label: 'search_from'.tr(),
            value: _from,
            onTap: () async {
              final v = await _pickCity(context, title: 'search_from'.tr(), selected: _from);
              if (v != null) setState(() => _from = v);
            },
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _field(
                  label: 'search_to'.tr(),
                  value: _to,
                  onTap: () async {
                    final v = await _pickCity(context, title: 'search_to'.tr(), selected: _to);
                    if (v != null) setState(() => _to = v);
                  },
                ),
              ),
              const SizedBox(width: 10),
              InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: _swap,
                child: Container(
                  height: 56,
                  width: 56,
                  decoration: BoxDecoration(
                    color: _RegionsSearchTab._bg,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: _RegionsSearchTab._border),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(Icons.swap_horiz, color: _RegionsSearchTab._primary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _dateField(context),
        ],
      ),
    );
  }

  Widget _dateField(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () async {
        final initial = _date ?? DateTime.now();
        final v = await _pickDate(context, initial: initial);
        if (v != null) setState(() => _date = v);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: _RegionsSearchTab._fieldBg,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _RegionsSearchTab._border),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('search_date'.tr(),
                      style: const TextStyle(fontSize: 12, color: _RegionsSearchTab._muted)),
                  const SizedBox(height: 3),
                  Text(
                    _date == null ? 'search_date_not_selected'.tr() : _formatDate(_date!),
                    style: const TextStyle(fontSize: 16, color: _RegionsSearchTab._text),
                  ),
                ],
              ),
            ),
            if (_date != null)
              InkWell(
                borderRadius: BorderRadius.circular(999),
                onTap: () => setState(() => _date = null),
                child: const Padding(
                  padding: EdgeInsets.all(6),
                  child: Icon(Icons.close, size: 18, color: _RegionsSearchTab._muted),
                ),
              )
            else
              const Icon(Icons.keyboard_arrow_down, color: _RegionsSearchTab._muted),
          ],
        ),
      ),
    );
  }

  Widget _actionRow(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _summaryChip()),
        const SizedBox(width: 12),
        SizedBox(
          height: 50,
          child: BlocBuilder<SearchTripsBloc, SearchTripsState>(
            builder: (context, state) {
              final loading = state is SearchTripsLoading;
              return ElevatedButton(
                onPressed: loading ? null : _runSearch,
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: _RegionsSearchTab._primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                ),
                child: loading
                    ? const SizedBox(
                  width: 18, height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
                    : Text('search_btn'.tr()),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _summaryChip() {
    final dateText = _date == null ? 'search_date_summary'.tr() : _formatDate(_date!);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _RegionsSearchTab._border),
      ),
      child: Text(
        '$_from → $_to • $dateText',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontSize: 15, color: _RegionsSearchTab._text),
      ),
    );
  }

  Widget _results(BuildContext context) {
    return BlocBuilder<SearchTripsBloc, SearchTripsState>(
      builder: (context, state) {
        if (state is SearchTripsLoading) {
          return _surface(
            padding: const EdgeInsets.all(14),
            child: const Center(child: CircularProgressIndicator()),
          );
        }
        if (state is SearchTripsError) {
          return _surface(
            padding: const EdgeInsets.all(14),
            child: Text('search_error'.tr(namedArgs: {'message': state.message}),
                textAlign: TextAlign.center),
          );
        }
        if (state is SearchTripsLoaded) {
          final trips = state.response.items;
          if (trips.isEmpty) {
            return _surface(
              padding: const EdgeInsets.all(14),
              child: Text('search_no_results'.tr(), textAlign: TextAlign.center),
            );
          }
          final actionLoading = state.actionLoading;
          return Column(
            children: trips.map((t) => TripCard.driver(
              t,
                  (_) async {
                if (actionLoading) return;
                final seats = await showSeatsBottomSheet(context, min: 1, max: 4);
                if (!context.mounted || seats == null) return;
                context.read<SearchTripsBloc>().add(
                  SearchTripsCreateBookingRequested(tripId: t.id, seats: seats),
                );
              },
                  (_) async {
                if (actionLoading) return;
                final res = await showOfferPriceBottomSheet(context, minSeats: 1, maxSeats: 4);
                if (!context.mounted || res == null) return;
                context.read<SearchTripsBloc>().add(
                  SearchTripsOfferPriceRequested(
                    tripId: t.id,
                    seats: res.seats,
                    offeredPrice: res.price,
                    comment: res.comment,
                  ),
                );
              },
            )).toList(),
          );
        }
        return _surface(
          padding: const EdgeInsets.all(14),
          child: Text('search_no_results'.tr(), textAlign: TextAlign.center),
        );
      },
    );
  }

  Widget _surface({required EdgeInsets padding, required Widget child}) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _RegionsSearchTab._border),
        boxShadow: const [
          BoxShadow(color: Color(0x0A000000), blurRadius: 18, offset: Offset(0, 10)),
        ],
      ),
      child: child,
    );
  }

  Widget _field({required String label, required String value, required VoidCallback onTap}) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: _RegionsSearchTab._fieldBg,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _RegionsSearchTab._border),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: const TextStyle(fontSize: 12, color: _RegionsSearchTab._muted)),
                  const SizedBox(height: 3),
                  Text(value, style: const TextStyle(fontSize: 16, color: _RegionsSearchTab._text)),
                ],
              ),
            ),
            const Icon(Icons.keyboard_arrow_down, color: _RegionsSearchTab._muted),
          ],
        ),
      ),
    );
  }

  void _swap() {
    setState(() {
      final t = _from;
      _from = _to;
      _to = t;
    });
  }

  void _runSearch() {
    final dateStr = _date == null
        ? null
        : '${_date!.year.toString().padLeft(4, '0')}-${_date!.month.toString().padLeft(2, '0')}-${_date!.day.toString().padLeft(2, '0')}';
    context.read<SearchTripsBloc>().add(
      SearchTripsRequested(from: _from, to: _to, date: dateStr),
    );
  }

  Future<String?> _pickCity(BuildContext context,
      {required String title, required String selected}) async {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) {
        final controller = TextEditingController();
        final notifier = ValueNotifier<List<String>>(_cities);

        void applyFilter() {
          final q = controller.text.trim().toLowerCase();
          notifier.value = q.isEmpty
              ? _cities
              : _cities.where((c) => c.toLowerCase().contains(q)).toList();
        }

        controller.addListener(applyFilter);

        return SafeArea(
          child: Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
            child: SizedBox(
              height: MediaQuery.of(ctx).size.height * 0.72,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 6, 16, 10),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(title, style: const TextStyle(fontSize: 16, color: _RegionsSearchTab._text)),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(),
                          child: Text('search_cancel'.tr()),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    child: TextField(
                      controller: controller,
                      style: const TextStyle(fontSize: 15, color: _RegionsSearchTab._text),
                      decoration: InputDecoration(
                        isDense: true,
                        hintText: 'placeholder_search'.tr(),
                        filled: true,
                        fillColor: _RegionsSearchTab._bg,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: ValueListenableBuilder<List<String>>(
                      valueListenable: notifier,
                      builder: (_, list, __) {
                        return ListView.separated(
                          itemCount: list.length,
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (_, i) {
                            final city = list[i];
                            final isSel = city == selected;
                            return ListTile(
                              title: Text(city, style: const TextStyle(fontSize: 15, color: _RegionsSearchTab._text)),
                              trailing: isSel ? const Icon(Icons.check, color: _RegionsSearchTab._primary) : null,
                              onTap: () => Navigator.of(ctx).pop(city),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<DateTime?> _pickDate(BuildContext context, {required DateTime initial}) async {
    final v = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (v == null) return null;
    return DateTime(v.year, v.month, v.day);
  }

  String _formatDate(DateTime d) {
    const months = [
      'yanvar', 'fevral', 'mart', 'aprel', 'may', 'iyun',
      'iyul', 'avgust', 'sentabr', 'oktabr', 'noyabr', 'dekabr',
    ];
    return '${d.day.toString().padLeft(2, '0')} ${months[d.month - 1]}';
  }
}