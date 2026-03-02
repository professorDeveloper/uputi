import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../utils/balance_formatter.dart';
import '../../../../utils/url_launchers.dart';
import '../../data/models/response/booking_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/response/driver_trip_model.dart';
import '../../data/models/response/my_trips_model.dart';
import '../bloc/home_passenger_bloc.dart';

class TripCard extends StatelessWidget {
  final String from;
  final String to;
  final String date;
  final String time;
  final String? seatsText;

  final String price;
  final String? bookingStatus;

  final String driverName;
  final String carModel;
  final String carColor;
  final String carNumber;
  final String? phone;

  final String? statusText;
  final Color? statusColor;

  final String? offerPriceText;
  final String? offerComment;

  final _SheetAction leftAction;
  final _SheetAction rightAction;

  const TripCard({
    super.key,
    required this.from,
    required this.to,
    required this.date,
    required this.time,
    required this.price,
    this.bookingStatus,
    required this.driverName,
    required this.carModel,
    required this.carColor,
    required this.carNumber,
    required this.leftAction,
    required this.rightAction,
    this.phone,
    this.seatsText,
    this.statusText,
    this.statusColor,

    this.offerPriceText,
    this.offerComment,
  });

  factory TripCard.booking(
      BookingModel b,
      void Function(String bookingId) onCancel,
      ) {
    final t = b.trip;
    final u = t.user;
    final c = u.car;

    final rawStatus = (b.status ?? "").toLowerCase().trim();
    final hasOffer = b.offeredPrice != null;

    String? sText;
    Color? sColor;

    if (rawStatus == "in_progress") {
      sText = 'trip_status_in_progress'.tr();
      sColor = const Color(0xFF2563EB);
    } else if (rawStatus == "requested" || hasOffer) {
      sText = 'trip_status_in_offer'.tr();
      sColor = const Color(0xFFF59E0B);
    } else if (rawStatus == "accepted" || rawStatus == "confirmed") {
      sText = 'trip_status_confirmed'.tr();
      sColor = const Color(0xFF10B981);
    } else if (rawStatus == "canceled" || rawStatus == "cancelled") {
      sText = 'trip_status_cancelled'.tr();
      sColor = const Color(0xFFEF4444);
    } else if (rawStatus.isNotEmpty) {
      sText = 'trip_status_in_progress'.tr();
      sColor = const Color(0xFF2563EB);
    }

    final offerPrice = b.offeredPrice == null
        ? null
        : formatPrice(b.offeredPrice!);
    final offerComment = (b.comment == null || b.comment!.trim().isEmpty)
        ? null
        : b.comment!.trim();

    return TripCard(
      from: t.fromAddress ?? 'Nomaʼlum manzil',
      to: t.toAddress ?? 'Nomaʼlum manzil',
      date: t.date ?? 'Nomaʼlum sana',
      time: _safeTime(t.time),
      bookingStatus: rawStatus,
      seatsText: b.seats == null ? null : "${b.seats}",
      price: formatPrice(t.amount),
      driverName: u.name ?? 'Nomaʼlum haydovchi',
      carModel: c?.model ?? 'Nomaʼlum',
      carColor: c?.color ?? 'Nomaʼlum',
      carNumber: c?.number ?? 'Nomaʼlum',
      phone: u.phone,
      statusText: sText,
      statusColor: sColor,
      offerPriceText: offerPrice,
      offerComment: offerComment,
      leftAction: _SheetAction(
        text: "Qo‘ng‘iroq qilish",
        icon: Icons.call,
        bg: const Color(0xFFEFFDF5),
        fg: const Color(0xFF16A34A),
        onTap: () => callPhone(u.phone ?? ''),
      ),
      rightAction: _SheetAction(
        text: 'trip_booking_cancel'.tr(),
        icon: Icons.close,
        bg: const Color(0xFFFFF1F2),
        fg: const Color(0xFFEF4444),
        onTap: () => onCancel(b.id.toString()),
      ),
    );
  }

  factory TripCard.driver(
      DriverTripModel t,
      void Function(String tripId) onBooking,
      void Function(String tripId) inviteMoney,
      ) {
    final u = t.user;
    final c = u.car;

    return TripCard(
      from: t.fromAddress ?? 'Nomaʼlum manzil',
      to: t.toAddress ?? 'Nomaʼlum manzil',
      date: t.date ?? 'Nomaʼlum sana',
      time: _safeTime(t.time),
      seatsText: t.seats.toString(),
      price: formatPrice(t.amount),
      driverName: u.name ?? 'Nomaʼlum haydovchi',
      carModel: c?.model ?? 'Nomaʼlum',
      carColor: c?.color ?? 'Nomaʼlum',
      carNumber: c?.number ?? 'Nomaʼlum',
      phone: u.phone,
      leftAction: _SheetAction(
        text: 'trip_book_order'.tr(),
        icon: Icons.check_circle,
        bg: const Color(0xFF16A34A),
        fg: Colors.white,
        onTap: () => onBooking(t.id.toString()),
        filled: true,
      ),
      rightAction: _SheetAction(
        text: 'trip_offer_price'.tr(),
        icon: Icons.payments_outlined,
        bg: const Color(0xFF2563EB),
        fg: Colors.white,
        onTap: () => inviteMoney(t.id.toString()),
        filled: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),

        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        hoverColor: Colors.transparent,
        focusColor: Colors.transparent,

        onTap: () => TripDetailsSheet.show(context, card: this),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE5E7EB)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 16,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 3.5,
                    height: 42,
                    decoration: BoxDecoration(
                      color: (statusColor ?? const Color(0xFF2563EB))
                          .withOpacity(0.9),
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                  const SizedBox(width: 10),

                  Expanded(
                    child: Column(
                      children: [
                        _LocationLine(
                          icon: Icons.location_on,
                          iconColor: const Color(0xFFEF4444),
                          text: from,
                        ),
                        const SizedBox(height: 6),
                        _LocationLine(
                          icon: Icons.circle,
                          iconColor: const Color(0xFF22C55E),
                          text: to,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 10),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _PriceChip(price: price),
                      if (statusText != null && statusColor != null) ...[
                        const SizedBox(height: 8),
                        _StatusChip(text: statusText!, color: statusColor!),
                      ],
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _MetaChip(icon: Icons.calendar_today, text: date),
                  const SizedBox(width: 10),
                  _MetaChip(icon: Icons.access_time, text: time),
                  if (seatsText != null) ...[
                    const SizedBox(width: 10),
                    _MetaChip(icon: Icons.event_seat, text: seatsText!),
                  ],
                  const Spacer(),
                  const Icon(Icons.chevron_right, color: Color(0xFF9CA3AF)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _safeTime(String? raw) {
    final t = (raw ?? '').trim();
    if (t.isEmpty) return 'Nomaʼlum vaqt';
    return t.length >= 5 ? t.substring(0, 5) : t;
  }
}

class TripDetailsSheet extends StatelessWidget {
  final TripCard card;

  const TripDetailsSheet({super.key, required this.card});

  static Future<void> show(BuildContext context, {required TripCard card}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      clipBehavior: Clip.antiAlias,
      builder: (_) => TripDetailsSheet(card: card),
    );
  }

  @override
  Widget build(BuildContext context) {
    final st = (card.bookingStatus ?? '').toLowerCase().trim();
    final hideCall = st == 'requested' || st == 'offered';
    final hasOffer =
        (card.offerPriceText?.trim().isNotEmpty ?? false) ||
            (card.offerComment?.trim().isNotEmpty ?? false);

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          16,
          10,
          16,
          16 + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: double.infinity,
                height: 44,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 44,
                      height: 5,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE5E7EB),
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),

                    Positioned(
                      right: 0,
                      child: IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                        splashRadius: 18,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              _InfoRow(
                label: 'trip_from_label'.tr(),
                value: card.from,
                icon: Icons.location_on,
              ),
              const SizedBox(height: 10),
              _InfoRow(label: "Qayerga", value: card.to, icon: Icons.flag),

              const SizedBox(height: 14),

              Row(
                children: [
                  Expanded(
                    child: _InfoTile(
                      label: 'trip_date_label'.tr(),
                      value: card.date,
                      icon: Icons.calendar_today,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _InfoTile(
                      label: 'trip_time_label'.tr(),
                      value: card.time,
                      icon: Icons.access_time,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _InfoTile(
                      label: "O‘rinlar",
                      value: card.seatsText ?? "-",
                      icon: Icons.people_alt_outlined,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _InfoTile(
                      label: 'trip_price_label'.tr(),
                      value: card.price,
                      icon: Icons.payments_outlined,
                    ),
                  ),
                ],
              ),

              if (hasOffer) ...[
                const SizedBox(height: 12),
                _SoftBox(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (card.offerPriceText?.trim().isNotEmpty ?? false)
                        Row(
                          children: [
                            const Icon(
                              Icons.payments_outlined,
                              size: 18,
                              color: Color(0xFF6B7280),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'trip_offer_label'.tr(namedArgs: {'price': card.offerPriceText!}),
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF111827),
                              ),
                            ),
                          ],
                        ),
                      if (card.offerComment?.trim().isNotEmpty ?? false) ...[
                        if (card.offerPriceText?.trim().isNotEmpty ?? false)
                          const SizedBox(height: 8),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.chat_bubble_outline,
                              size: 18,
                              color: Color(0xFF6B7280),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                card.offerComment!,
                                style: const TextStyle(
                                  color: Color(0xFF374151),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 14),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F7FF),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFD6E4FF)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: const Color(0xFF2563EB),
                          child: Text(
                            card.driverName.isNotEmpty
                                ? card.driverName[0]
                                : '',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            card.driverName,
                            style: const TextStyle(
                              fontSize: 15.5,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF111827),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _MiniInfo(
                            label: "Model",
                            value: card.carModel,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _MiniInfo(label: "Rang", value: card.carColor),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'trip_car_number'.tr(namedArgs: {'num': card.carNumber}),
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF111827),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              if (hideCall) ...[
                SizedBox(
                  width: double.infinity,
                  child: _ActionButton(
                    action: card.rightAction,
                    onTap: () {
                      Navigator.pop(context);
                      card.rightAction.onTap();
                    },
                  ),
                ),
              ] else ...[
                Row(
                  children: [
                    Expanded(
                      child: _ActionButton(
                        action: card.leftAction,
                        onTap: () {
                          Navigator.pop(context);
                          card.leftAction.onTap();
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _ActionButton(
                        action: card.rightAction,
                        onTap: () {
                          Navigator.pop(context);
                          card.rightAction.onTap();
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _SheetAction {
  final String text;
  final IconData icon;
  final Color bg;
  final Color fg;
  final VoidCallback onTap;
  final bool filled;

  const _SheetAction({
    required this.text,
    required this.icon,
    required this.bg,
    required this.fg,
    required this.onTap,
    this.filled = false,
  });
}

class _ActionButton extends StatelessWidget {
  final _SheetAction action;
  final VoidCallback onTap;

  const _ActionButton({required this.action, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(action.icon, size: 18, color: action.fg),
        label: Text(
          action.text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(color: action.fg, fontWeight: FontWeight.w600),
        ),
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: action.bg,
          foregroundColor: action.fg,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
        ),
      ),
    );
  }
}

class _LocationLine extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String text;

  const _LocationLine({
    required this.icon,
    required this.iconColor,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: iconColor),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF111827),
            ),
          ),
        ),
      ],
    );
  }
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String text;

  const _MetaChip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(width: 2),
          Icon(icon, size: 16, color: const Color(0xFF6B7280)),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: Color(0xFF374151),
            ),
          ),
          const SizedBox(width: 2),
        ],
      ),
    );
  }
}

class _PriceChip extends StatelessWidget {
  final String price;

  const _PriceChip({required this.price});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFEEF2FF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        price,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          color: Color(0xFF1F2937),
        ),
      ),
    );
  }
}

class _StatusChip extends StatefulWidget {
  final String text;
  final Color color;

  const _StatusChip({required this.text, required this.color});

  @override
  State<_StatusChip> createState() => _StatusChipState();
}

class _StatusChipState extends State<_StatusChip>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  bool get _isPulsing =>
      widget.text == 'trip_status_in_progress'.tr() || widget.text == 'trip_status_searching'.tr();

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _anim = Tween<double>(begin: 0.15, end: 0.45).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
    if (_isPulsing) {
      _ctrl.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isPulsing) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: widget.color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          widget.text,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: widget.color,
            fontSize: 12,
          ),
        ),
      );
    }

    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: widget.color.withOpacity(_anim.value),
            borderRadius: BorderRadius.circular(999),
            boxShadow: [
              BoxShadow(
                color: widget.color.withOpacity(_anim.value * 0.6),
                blurRadius: 6 + _anim.value * 8,
                spreadRadius: _anim.value * 2,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.85 + _anim.value * 0.15),
                ),
              ),
              const SizedBox(width: 5),
              Text(
                widget.text,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _InfoRow({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: const Color(0xFF6B7280)),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(color: Color(0xFF6B7280), fontSize: 12),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF111827),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _InfoTile({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: const Color(0xFF6B7280)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF111827),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SoftBox extends StatelessWidget {
  final Widget child;

  const _SoftBox({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: child,
    );
  }
}

class _MiniInfo extends StatelessWidget {
  final String label;
  final String value;

  const _MiniInfo({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(color: Color(0xFF6B7280), fontSize: 12),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Color(0xFF111827),
            ),
          ),
        ],
      ),
    );
  }
}

class MyTripCard extends StatelessWidget {
  final MyTripItem t;

  const MyTripCard({super.key, required this.t});

  factory MyTripCard.trip(MyTripItem t) => MyTripCard(t: t);

  @override
  Widget build(BuildContext context) {
    final rawStatus = (t.status ?? '').toLowerCase().trim();

    String statusText;
    Color statusColor;

    if (rawStatus == 'active') {
      statusText = 'trip_status_searching'.tr();
      statusColor = const Color(0xFF2563EB);
    } else if (rawStatus == 'in_progress') {
      statusText = 'trip_status_in_progress'.tr();
      statusColor = const Color(0xFFF59E0B);
    } else {
      statusText = rawStatus.isEmpty ? "Jarayonda" : rawStatus;
      statusColor = const Color(0xFF6B7280);
    }

    final price = formatPrice(t.amount ?? 0);
    final date = t.date ?? 'Nomaʼlum sana';
    final time = t.safeTime;
    final seatsText = (t.seats == null) ? null : "${t.seats}";

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        hoverColor: Colors.transparent,
        focusColor: Colors.transparent,
        onTap: () => MyTripDetailsSheet.show(
          context,
          trip: t,
          onCancel: (tripId) {
            context.read<HomePassengerBloc>().add(
              CancelMyTripPressed(tripId: tripId),
            );
          },
        ),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE5E7EB)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 16,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 3.5,
                    height: 42,
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      children: [
                        _LocationLine(
                          icon: Icons.location_on,
                          iconColor: const Color(0xFFEF4444),
                          text: t.fromAddress ?? 'Nomaʼlum manzil',
                        ),
                        const SizedBox(height: 6),
                        _LocationLine(
                          icon: Icons.circle,
                          iconColor: const Color(0xFF22C55E),
                          text: t.toAddress ?? 'Nomaʼlum manzil',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _PriceChip(price: price),
                      const SizedBox(height: 8),
                      _StatusChip(text: statusText, color: statusColor),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _MetaChip(icon: Icons.calendar_today, text: date),
                  const SizedBox(width: 10),
                  _MetaChip(icon: Icons.access_time, text: time),
                  if (seatsText != null) ...[
                    const SizedBox(width: 10),
                    _MetaChip(icon: Icons.event_seat, text: seatsText),
                  ],
                  const Spacer(),
                  const Icon(Icons.chevron_right, color: Color(0xFF9CA3AF)),
                ],
              ),
              if (t.hasDriver && t.driverUser != null) ...[
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(
                      Icons.person,
                      size: 16,
                      color: Color(0xFF6B7280),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        "${t.driverUser?.name ?? 'Haydovchi'} • "
                            "${t.driverUser?.car?.model ?? '-'} • "
                            "${t.driverUser?.car?.number ?? '-'}",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF374151),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class MyTripDetailsSheet extends StatelessWidget {
  final MyTripItem trip;
  final void Function(int tripId)? onCancel;

  const MyTripDetailsSheet({super.key, required this.trip, this.onCancel});

  static Future<void> show(
      BuildContext context, {
        required MyTripItem trip,
        void Function(int tripId)? onCancel,
      }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      clipBehavior: Clip.antiAlias,
      builder: (_) => MyTripDetailsSheet(trip: trip, onCancel: onCancel),
    );
  }

  @override
  Widget build(BuildContext context) {
    final price = formatPrice(trip.amount ?? 0);
    final date = trip.date ?? '-';
    final time = trip.safeTime;
    final seats = trip.seats?.toString() ?? '-';
    final comment = (trip.comment ?? '').trim();

    final rawStatus = (trip.status ?? '').toLowerCase().trim();

    String statusText;
    Color statusColor;

    if (rawStatus == 'active') {
      statusText = 'trip_status_searching'.tr();
      statusColor = const Color(0xFF2563EB);
    } else if (rawStatus == 'in_progress') {
      statusText = 'trip_status_in_progress'.tr();
      statusColor = const Color(0xFFF59E0B);
    } else if (rawStatus == 'completed' ||
        rawStatus == 'done' ||
        rawStatus == 'finished') {
      statusText = 'trip_status_completed'.tr();
      statusColor = const Color(0xFF10B981);
    } else if (rawStatus == 'canceled' || rawStatus == 'cancelled') {
      statusText = 'trip_status_cancelled'.tr();
      statusColor = const Color(0xFFEF4444);
    } else {
      statusText = rawStatus.isEmpty ? "Jarayonda" : rawStatus;
      statusColor = const Color(0xFF6B7280);
    }

    final driver = trip.driverUser;
    final hasDriver = trip.hasDriver && driver != null;
    final phone = (driver?.phone ?? '').trim();

    final cancelCb = onCancel;

    final canCancel =
        (rawStatus == 'active' || rawStatus == 'in_progress') &&
            cancelCb != null &&
            trip.id != null;

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          16,
          10,
          16,
          16 + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: double.infinity,
                height: 44,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 44,
                      height: 5,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE5E7EB),
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                    Positioned(
                      right: 0,
                      top: 0,
                      bottom: 0,
                      child: IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                        splashRadius: 18,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              Align(
                alignment: Alignment.centerLeft,
                child: _StatusChip(text: statusText, color: statusColor),
              ),

              const SizedBox(height: 12),

              _InfoRow(
                label: 'trip_from_label'.tr(),
                value: trip.fromAddress ?? "-",
                icon: Icons.location_on,
              ),
              const SizedBox(height: 10),
              _InfoRow(
                label: 'trip_to_label'.tr(),
                value: trip.toAddress ?? "-",
                icon: Icons.flag,
              ),

              const SizedBox(height: 14),

              Row(
                children: [
                  Expanded(
                    child: _InfoTile(
                      label: 'trip_date_label'.tr(),
                      value: date,
                      icon: Icons.calendar_today,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _InfoTile(
                      label: 'trip_time_label'.tr(),
                      value: time,
                      icon: Icons.access_time,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _InfoTile(
                      label: "O‘rinlar",
                      value: seats,
                      icon: Icons.people_alt_outlined,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _InfoTile(
                      label: 'trip_price_label'.tr(),
                      value: price,
                      icon: Icons.payments_outlined,
                    ),
                  ),
                ],
              ),

              if (comment.isNotEmpty) ...[
                const SizedBox(height: 12),
                _SoftBox(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.chat_bubble_outline,
                        size: 18,
                        color: Color(0xFF6B7280),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          comment,
                          style: const TextStyle(color: Color(0xFF374151)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 14),

              if (hasDriver) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F7FF),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFFD6E4FF)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 18,
                            backgroundColor: const Color(0xFF2563EB),
                            child: Text(
                              (driver!.name ?? 'H').isNotEmpty
                                  ? (driver.name![0])
                                  : 'H',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              driver.name ?? "Haydovchi",
                              style: const TextStyle(
                                fontSize: 15.5,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF111827),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _MiniInfo(
                              label: 'trip_car_model_label'.tr(),
                              value: driver.car?.model ?? "-",
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _MiniInfo(
                              label: 'trip_car_color_label'.tr(),
                              value: driver.car?.color ?? "-",
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'trip_car_number'.tr(namedArgs: {'num': driver.car?.number ?? "-"}),
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF111827),
                        ),
                      ),

                      if (phone.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton.icon(
                            onPressed: () => callPhone(phone),
                            icon: const Icon(Icons.call, size: 18),
                            label: const Text(
                              "Qo‘ng‘iroq qilish",
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF16A34A),
                              elevation: 0,
                              shadowColor: Colors.transparent,
                              surfaceTintColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(999),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ] else ...[
                _SoftBox(
                  child: Row(
                    children:  [
                      Icon(
                        Icons.info_outline,
                        size: 18,
                        color: Color(0xFF6B7280),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'trip_no_driver'.tr(),
                          style: TextStyle(color: Color(0xFF374151)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              if (canCancel) ...[
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      cancelCb?.call(trip.id!);
                    },
                    icon: const Icon(Icons.close, size: 18),
                    label: Text(
                      'trip_cancel'.tr(),
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEF4444),
                      elevation: 0,
                      shadowColor: Colors.transparent,
                      surfaceTintColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}