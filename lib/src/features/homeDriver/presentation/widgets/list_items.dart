import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:map_launcher/map_launcher.dart';

import '../../../../core/constants/app_icons.dart';
import '../../../../utils/balance_formatter.dart';
import '../../../../utils/url_launchers.dart';
import '../../data/model/driver_booking_model.dart';
import '../../data/model/driver_my_trips.dart';
import '../../data/model/driver_paggination.dart';

class TripCard extends StatelessWidget {
  final String from;
  final String to;
  final double? fromLat;
  final double? fromLng;
  final double? toLat;
  final double? toLng;
  final String date;
  final String time;
  final String price;
  final String? seatsText;
  final String? statusText;
  final Color? statusColor;
  final String passengerName;
  final String? passengerPhone;
  final double passengerRating;
  final String? comment;
  final _SheetAction leftAction;
  final _SheetAction rightAction;

  const TripCard._({
    required this.from,
    required this.to,
    this.fromLat,
    this.fromLng,
    this.toLat,
    this.toLng,
    required this.date,
    required this.time,
    required this.price,
    this.seatsText,
    this.statusText,
    this.statusColor,
    required this.passengerName,
    this.passengerPhone,
    required this.passengerRating,
    this.comment,
    required this.leftAction,
    required this.rightAction,
  });

  factory TripCard.passengerTrip(
      PassengerTripModel t,
      VoidCallback onAccept,
      ) {
    return TripCard._(
      from: t.fromAddress,
      to: t.toAddress,
      fromLat: double.tryParse(t.fromLat ?? ''),
      fromLng: double.tryParse(t.fromLng ?? ''),
      toLat: double.tryParse(t.toLat ?? ''),
      toLng: double.tryParse(t.toLng ?? ''),
      date: t.date,
      time: _safeTime(t.time),
      price: formatPrice(t.amount),
      seatsText: "${t.seats} o'rin",
      passengerName: t.user.name,
      passengerPhone: t.user.phone,
      passengerRating: t.user.rating,
      comment: t.comment,
      leftAction: _SheetAction(
        label: 'trip_close'.tr(),
        icon: Icons.close,
        color: const Color(0xFF6B7280),
        onTap: (ctx) => Navigator.pop(ctx),
      ),
      rightAction: _SheetAction(
        label: 'trip_accept'.tr(),
        icon: Icons.check_circle_outline,
        color: const Color(0xFF16A34A),
        onTap: (ctx) {
          Navigator.pop(ctx);
          onAccept();
        },
      ),
    );
  }

  factory TripCard.booking(
      DriverBookingModel b,
      void Function(int bookingId) onCancel,
      void Function(int tripId) onComplete,
      ) {
    final trip = b.trip;
    final passenger = trip.user;

    return TripCard._(
      from: trip.fromAddress,
      to: trip.toAddress,
      fromLat: double.tryParse(trip.fromLat ?? ''),
      fromLng: double.tryParse(trip.fromLng ?? ''),
      toLat: double.tryParse(trip.toLat ?? ''),
      toLng: double.tryParse(trip.toLng ?? ''),
      date: trip.date,
      time: trip.safeTime,
      price: formatPrice(trip.amount),
      statusText: 'trip_active_booking'.tr(),
      statusColor: const Color(0xFF2563EB),
      passengerName: passenger?.name ?? 'trip_unknown'.tr(),
      passengerPhone: passenger?.phone,
      passengerRating: (passenger?.rating ?? 0).toDouble(),
      comment: trip.comment,
      leftAction: _SheetAction(
        label: 'trip_complete'.tr(),
        icon: Icons.flag_rounded,
        color: const Color(0xFF2563EB),
        onTap: (ctx) {
          Navigator.pop(ctx);
          onComplete(trip.id);
        },
      ),
      rightAction: _SheetAction(
        label: 'trip_cancel'.tr(),
        icon: Icons.cancel_outlined,
        color: const Color(0xFFDC2626),
        onTap: (ctx) {
          Navigator.pop(ctx);
          onCancel(b.id!);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasComment = (comment ?? '').trim().isNotEmpty;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _showSheet(context),
          child: Ink(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: statusColor?.withOpacity(0.3) ?? const Color(0xFFE5E7EB),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (statusText != null && statusColor != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: statusColor!.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 7,
                                height: 7,
                                decoration: BoxDecoration(
                                  color: statusColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                statusText!,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: statusColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      const Spacer(),
                      if (hasComment)
                        IconButton(
                          tooltip: 'trip_comment_title'.tr(),
                          visualDensity: VisualDensity.compact,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: const Icon(
                            Icons.comment_outlined,
                            size: 18,
                            color: Color(0xFF6B7280),
                          ),
                          onPressed: () =>
                              _showCommentDialog(context, comment!.trim()),
                        ),
                      const Icon(
                        Icons.keyboard_arrow_right_rounded,
                        size: 22,
                        color: Color(0xFF9CA3AF),
                      ),
                    ],
                  ),
                  if (statusText != null) const SizedBox(height: 12),

                  _RouteBlock(from: from, to: to),
                  const SizedBox(height: 10),

                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      _MetaChip(
                          icon: Icons.calendar_today_outlined, text: date),
                      _MetaChip(
                          icon: Icons.access_time_rounded, text: time),
                      if (seatsText != null)
                        _MetaChip(
                            icon: Icons.event_seat_outlined,
                            text: seatsText!),
                      _PriceTag(price: price),
                    ],
                  ),

                  const SizedBox(height: 12),

                  Row(
                    children: [
                      const Icon(Icons.person_outline,
                          size: 16, color: Color(0xFF9CA3AF)),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          passengerName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF374151),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.star_rounded,
                          size: 14, color: Color(0xFFF59E0B)),
                      const SizedBox(width: 3),
                      Text(
                        passengerRating.toStringAsFixed(1),
                        style: const TextStyle(
                            fontSize: 12, color: Color(0xFF6B7280)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _TripDetailSheet(card: this),
    );
  }

  void _showCommentDialog(BuildContext context, String comment) {
    showDialog(
      context: context,
      useRootNavigator: false,
      builder: (dialogContext) => AlertDialog(
        title: Text('trip_comment_title'.tr()),
        content: Text(comment),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('trip_close'.tr()),
          ),
        ],
      ),
    );
  }
}

class _TripDetailSheet extends StatelessWidget {
  final TripCard card;

  const _TripDetailSheet({required this.card});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
      EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD1D5DB),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              _RouteBlock(
                from: card.from,
                to: card.to,
                fromLat: card.fromLat,
                fromLng: card.fromLng,
                toLat: card.toLat,
                toLng: card.toLng,
              ),

              const SizedBox(height: 14),

              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _MetaChip(
                      icon: Icons.calendar_today_outlined, text: card.date),
                  _MetaChip(
                      icon: Icons.access_time_rounded, text: card.time),
                  if (card.seatsText != null)
                    _MetaChip(
                        icon: Icons.event_seat_outlined,
                        text: card.seatsText!),
                  _PriceTag(price: card.price),
                ],
              ),

              if ((card.comment ?? '').isNotEmpty) ...[
                const SizedBox(height: 12),
                _CommentBox(comment: card.comment!),
              ],

              const SizedBox(height: 14),
              _Label('trip_passenger_label'.tr()),
              const SizedBox(height: 8),
              _PassengerTile(
                name: card.passengerName,
                phone: card.passengerPhone,
                rating: card.passengerRating,
              ),

              if ((card.passengerPhone ?? '').isNotEmpty) ...[
                const SizedBox(height: 8),
                _CallBtn(phone: card.passengerPhone!),
              ],

              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(
                    child: _ActionBtn(action: card.leftAction),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _ActionBtn(action: card.rightAction),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class MyTripCard extends StatelessWidget {
  final DriverMyTripItem trip;
  final void Function(int tripId) onComplete;
  final void Function(int bookingId)? onAcceptBooking;
  final void Function(int bookingId)? onRejectBooking;

  const MyTripCard._({
    required this.trip,
    required this.onComplete,
    this.onAcceptBooking,
    this.onRejectBooking,
  });

  factory MyTripCard.trip(
      DriverMyTripItem t,
      void Function(int tripId) onComplete, {
        void Function(int bookingId)? onAcceptBooking,
        void Function(int bookingId)? onRejectBooking,
      }) =>
      MyTripCard._(
        trip: t,
        onComplete: onComplete,
        onAcceptBooking: onAcceptBooking,
        onRejectBooking: onRejectBooking,
      );

  @override
  Widget build(BuildContext context) {
    final s = trip.status ?? '';
    final statusColor = _statusColor(s);
    final statusLabel = _statusLabel(s);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _showSheet(context),
          child: Ink(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE5E7EB)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _StatusBadge(label: statusLabel, color: statusColor),
                      const Spacer(),
                      if (trip.amount != null)
                        _PriceTag(price: formatPrice(trip.amount!)),
                      const SizedBox(width: 6),
                      const Icon(
                        Icons.keyboard_arrow_right_rounded,
                        size: 22,
                        color: Color(0xFF9CA3AF),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _RouteBlock(
                    from: trip.fromAddress ?? 'trip_unknown'.tr(),
                    to: trip.toAddress ?? 'trip_unknown'.tr(),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _MetaChip(
                          icon: Icons.calendar_today_outlined,
                          text: trip.date ?? 'trip_unknown'.tr()),
                      const SizedBox(width: 8),
                      _MetaChip(
                          icon: Icons.access_time_rounded,
                          text: trip.safeTime),
                      const Spacer(),
                      _MetaChip(
                          icon: Icons.people_outline,
                          text: '${trip.bookings.length} bron'),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showSheet(BuildContext ctx) {
    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _MyTripSheet(
        trip: trip,
        onComplete: onComplete,
        onAcceptBooking: onAcceptBooking,
        onRejectBooking: onRejectBooking,
      ),
    );
  }
}

class _MyTripSheet extends StatelessWidget {
  final DriverMyTripItem trip;
  final void Function(int) onComplete;
  final void Function(int bookingId)? onAcceptBooking;
  final void Function(int bookingId)? onRejectBooking;

  const _MyTripSheet({
    required this.trip,
    required this.onComplete,
    this.onAcceptBooking,
    this.onRejectBooking,
  });

  @override
  Widget build(BuildContext context) {
    final canComplete = (trip.status ?? '').toLowerCase() == 'active';
    final statusColor = _statusColor(trip.status ?? '');
    final statusLabel = _statusLabel(trip.status ?? '');

    return Padding(
      padding:
      EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD1D5DB),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              _StatusBadge(label: statusLabel, color: statusColor),
              const SizedBox(height: 12),

              _RouteBlock(
                from: trip.fromAddress ?? 'trip_unknown'.tr(),
                to: trip.toAddress ?? 'trip_unknown'.tr(),
                fromLat: double.tryParse(trip.fromLat ?? ''),
                fromLng: double.tryParse(trip.fromLng ?? ''),
                toLat: double.tryParse(trip.toLat ?? ''),
                toLng: double.tryParse(trip.toLng ?? ''),
              ),

              const SizedBox(height: 14),

              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _MetaChip(
                      icon: Icons.calendar_today_outlined,
                      text: trip.date ?? 'trip_unknown'.tr()),
                  _MetaChip(
                      icon: Icons.access_time_rounded, text: trip.safeTime),
                  if (trip.seats != null && (trip.seats ?? 0) > 0)
                    _MetaChip(
                        icon: Icons.event_seat_outlined,
                        text: "${trip.seats} o'rin"),
                  if (trip.amount != null)
                    _PriceTag(price: formatPrice(trip.amount!)),
                ],
              ),

              if ((trip.comment ?? '').isNotEmpty) ...[
                const SizedBox(height: 12),
                _CommentBox(comment: trip.comment!),
              ],

              if (trip.bookings.isNotEmpty) ...[
                const SizedBox(height: 16),
                _Label('trip_passengers_label'.tr(namedArgs: {'count': '${trip.bookings.length}'})),
                const SizedBox(height: 8),
                ...trip.bookings.map((b) => _BookingRow(
                  booking: b,
                  onAccept: onAcceptBooking != null
                      ? (id) {
                    Navigator.pop(context);
                    onAcceptBooking!(id);
                  }
                      : null,
                  onReject: onRejectBooking != null
                      ? (id) {
                    Navigator.pop(context);
                    onRejectBooking!(id);
                  }
                      : null,
                )),
              ],

              if (canComplete) ...[
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      onComplete(trip.id!);
                    },
                    icon: const Icon(Icons.flag_rounded),
                    label: Text(
                      'trip_finish'.tr(),
                      style: TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w600),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}


class _BookingRow extends StatelessWidget {
  final DriverMyTripBooking booking;
  final void Function(int bookingId)? onAccept;
  final void Function(int bookingId)? onReject;

  const _BookingRow({
    required this.booking,
    this.onAccept,
    this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    final user = booking.user;
    final phone = user?.phone ?? '';
    final name = user?.name ?? "Noma'lum";
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
    final rating = (user?.rating ?? 0).toDouble();
    final status = booking.status ?? '';
    final statusLabel = _bookingStatusLabel(status);
    final statusColor = _bookingStatusColor(status);

    final isPending = status.toLowerCase() == 'pending' ||
        status.toLowerCase() == 'requested';

    final isAccepted = status.toLowerCase() == 'in_progress' ||
        status.toLowerCase() == 'accepted';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isAccepted
              ? const Color(0xFF16A34A).withOpacity(0.3)
              : const Color(0xFFE5E7EB),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: Color(0xFF1E3A5F),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  initial,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(Icons.star_rounded,
                            size: 13, color: Color(0xFFF59E0B)),
                        const SizedBox(width: 3),
                        Text(
                          rating.toStringAsFixed(1),
                          style: const TextStyle(
                              fontSize: 12, color: Color(0xFF6B7280)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  statusLabel,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          Row(
            children: [
              if (booking.seats != null) ...[
                const Icon(Icons.event_seat_outlined,
                    size: 13, color: Color(0xFF9CA3AF)),
                const SizedBox(width: 4),
                Text(
                  "${booking.seats} o'rindiq",
                  style: const TextStyle(
                      fontSize: 12, color: Color(0xFF6B7280)),
                ),
                const SizedBox(width: 12),
              ],
              if (booking.offeredPrice != null) ...[
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFBFDBFE)),
                  ),
                  child: Text(
                    formatPrice(booking.offeredPrice!),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1D4ED8),
                    ),
                  ),
                ),
              ],
              const Spacer(),
              if (phone.isNotEmpty)
                GestureDetector(
                  onTap: () => callPhone(phone),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.phone_outlined,
                        size: 18, color: Color(0xFF2563EB)),
                  ),
                ),
            ],
          ),

          if (isPending) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                if (onAccept != null)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => onAccept!(booking.id!),
                      icon: const Icon(Icons.check_circle_outline, size: 16),
                      label: Text(
                        'trip_accept'.tr(),
                        style: TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF16A34A),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 11),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                if (onAccept != null && onReject != null)
                  const SizedBox(width: 8),
                if (onReject != null)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => onReject!(booking.id!),
                      icon: const Icon(Icons.close, size: 16),
                      label: Text(
                        'trip_cancel'.tr(),
                        style: TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFDC2626),
                        side: const BorderSide(color: Color(0xFFDC2626)),
                        padding: const EdgeInsets.symmetric(vertical: 11),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
              ],
            ),
          ],

          if (isAccepted) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.check_circle_rounded,
                    size: 15, color: Color(0xFF16A34A)),
                const SizedBox(width: 6),
                const Text(
                  'Qabul qilingan',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF16A34A),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

String _bookingStatusLabel(String status) {
  switch (status.toLowerCase()) {
    case 'pending':
    case 'requested':
      return 'booking_status_pending'.tr();
    case 'accepted':
    case 'in_progress':
      return 'booking_status_accepted'.tr();
    case 'cancelled':
    case 'canceled':
    case 'rejected':
      return 'booking_status_cancelled'.tr();
    case 'completed':
      return 'booking_status_completed'.tr();
    default:
      return status.isEmpty ? "Noma'lum" : status;
  }
}

Color _bookingStatusColor(String status) {
  switch (status.toLowerCase()) {
    case 'pending':
    case 'requested':
      return const Color(0xFFF59E0B);
    case 'accepted':
    case 'in_progress':
      return const Color(0xFF16A34A);
    case 'cancelled':
    case 'canceled':
    case 'rejected':
      return const Color(0xFFDC2626);
    case 'completed':
      return const Color(0xFF2563EB);
    default:
      return const Color(0xFF6B7280);
  }
}



class _SheetAction {
  final String label;
  final IconData icon;
  final Color color;
  final void Function(BuildContext ctx) onTap;

  _SheetAction({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });
}

class _ActionBtn extends StatelessWidget {
  final _SheetAction action;

  const _ActionBtn({required this.action});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () => action.onTap(context),
      icon: Icon(action.icon, size: 18),
      label: Text(
        action.label,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: action.color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 13),
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        elevation: 0,
      ),
    );
  }
}

class _RouteBlock extends StatefulWidget {
  final String from;
  final String to;
  final double? fromLat;
  final double? fromLng;
  final double? toLat;
  final double? toLng;

  const _RouteBlock({
    required this.from,
    required this.to,
    this.fromLat,
    this.fromLng,
    this.toLat,
    this.toLng,
  });

  @override
  State<_RouteBlock> createState() => _RouteBlockState();
}

class _RouteBlockState extends State<_RouteBlock> {
  List<AvailableMap> _cachedMaps = [];

  @override
  void initState() {
    super.initState();
    final hasCoords = (widget.fromLat != null && widget.fromLng != null) ||
        (widget.toLat != null && widget.toLng != null);
    if (hasCoords) _loadMaps();
  }

  Future<void> _loadMaps() async {
    try {
      final maps = await MapLauncher.installedMaps;
      if (mounted) setState(() => _cachedMaps = maps);
    } catch (e) {
      debugPrint('MapLauncher load error: $e');
    }
  }

  Future<void> _openDirectionTo(double destLat, double destLng) async {
    if (_cachedMaps.isEmpty) return;

    final coords = Coords(destLat, destLng);

    if (_cachedMaps.length == 1) {
      await _cachedMaps.first.showDirections(destination: coords);
      return;
    }

    if (!mounted) return;
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _MapPickerSheet(maps: _cachedMaps, coords: coords),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: (widget.fromLat != null && widget.fromLng != null)
              ? () => _openDirectionTo(widget.fromLat!, widget.fromLng!)
              : null,
          child: Row(
            children: [
              const Icon(Icons.circle, size: 10, color: Color(0xFF22C55E)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.from,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    decoration: (widget.fromLat != null && widget.fromLng != null)
                        ? TextDecoration.underline
                        : null,
                    decorationColor: const Color(0xFF9CA3AF),
                  ),
                ),
              ),
              if (widget.fromLat != null && widget.fromLng != null)
                const Icon(Icons.near_me_outlined, size: 14, color: Color(0xFF9CA3AF)),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Container(width: 2, height: 10, color: const Color(0xFFD1D5DB)),
        ),
        GestureDetector(
          onTap: (widget.toLat != null && widget.toLng != null)
              ? () => _openDirectionTo(widget.toLat!, widget.toLng!)
              : null,
          child: Row(
            children: [
              const Icon(Icons.location_on_outlined, size: 12, color: Color(0xFFEF4444)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.to,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    decoration: (widget.toLat != null && widget.toLng != null)
                        ? TextDecoration.underline
                        : null,
                    decorationColor: const Color(0xFF9CA3AF),
                  ),
                ),
              ),
              if (widget.toLat != null && widget.toLng != null)
                const Icon(Icons.near_me_outlined, size: 14, color: Color(0xFF9CA3AF)),
            ],
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
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: const Color(0xFF9CA3AF)),
        const SizedBox(width: 4),
        Text(text,
            style:
            const TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
      ],
    );
  }
}

class _PriceTag extends StatelessWidget {
  final String price;

  const _PriceTag({required this.price});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFBFDBFE)),
      ),
      child: Text(
        price,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: Color(0xFF1D4ED8),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

class _PassengerTile extends StatelessWidget {
  final String name;
  final String? phone;
  final double rating;

  const _PassengerTile({
    required this.name,
    this.phone,
    required this.rating,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          const Icon(Icons.person_outline,
              size: 18, color: Color(0xFF6B7280)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w600)),
                Row(
                  children: [
                    const Icon(Icons.star_rounded,
                        size: 12, color: Color(0xFFF59E0B)),
                    const SizedBox(width: 3),
                    Text(rating.toStringAsFixed(1),
                        style: const TextStyle(
                            fontSize: 12, color: Color(0xFF6B7280))),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CallBtn extends StatelessWidget {
  final String phone;

  const _CallBtn({required this.phone});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => callPhone(phone),
        icon: const Icon(Icons.phone_outlined, size: 18),
        label: Text(phone,
            style: const TextStyle(
                fontSize: 14, fontWeight: FontWeight.w500)),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Color(0xFF2563EB)),
          foregroundColor: const Color(0xFF2563EB),
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}

class _CommentBox extends StatelessWidget {
  final String comment;

  const _CommentBox({required this.comment});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.comment_outlined,
              size: 16, color: Color(0xFF9CA3AF)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(comment,
                style: const TextStyle(
                    fontSize: 13, color: Color(0xFF374151))),
          ),
        ],
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;

  const _Label(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: Color(0xFF6B7280),
      ),
    );
  }
}


String _safeTime(String t) {
  final s = t.trim();
  if (s.isEmpty) return "Noma'lum";
  return s.length >= 5 ? s.substring(0, 5) : s;
}

Color _statusColor(String status) {
  switch (status.toLowerCase()) {
    case 'active':
      return const Color(0xFF2563EB);
    case 'in_progress':
      return const Color(0xFFF59E0B);
    case 'completed':
      return const Color(0xFF16A34A);
    case 'cancelled':
    case 'canceled':
      return const Color(0xFFDC2626);
    default:
      return const Color(0xFF6B7280);
  }
}


String _statusLabel(String status) {
  switch (status.toLowerCase()) {
    case 'active':
      return 'trip_status_active'.tr();
    case 'in_progress':
      return 'trip_status_in_progress'.tr();
    case 'completed':
      return 'trip_status_completed'.tr();
    case 'cancelled':
    case 'canceled':
      return 'trip_status_cancelled'.tr();
    default:
      return status.isEmpty ? "Noma'lum" : status;
  }
}

class _MapPickerSheet extends StatelessWidget {
  final List<AvailableMap> maps;
  final Coords coords;

  const _MapPickerSheet({required this.maps, required this.coords});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 10),
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFE5E7EB),
              borderRadius: BorderRadius.circular(99),
            ),
          ),
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'map_picker_title'.tr(),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF6B7280),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Divider(height: 1, color: Color(0xFFF3F4F6)),
          ...maps.asMap().entries.map((entry) {
            final i = entry.key;
            final map = entry.value;
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _MapOptionTile(
                  map: map,
                  onTap: () async {
                    Navigator.pop(context);
                    await map.showDirections(destination: coords);
                  },
                ),
                if (i < maps.length - 1)
                  const Divider(height: 1, indent: 72, color: Color(0xFFF3F4F6)),
              ],
            );
          }),
          const Divider(height: 1, color: Color(0xFFF3F4F6)),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  backgroundColor: const Color(0xFFF3F4F6),
                  foregroundColor: const Color(0xFF374151),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  'btn_cancel'.tr(),
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

class _MapOptionTile extends StatelessWidget {
  final AvailableMap map;
  final VoidCallback onTap;

  const _MapOptionTile({required this.map, required this.onTap});

  Widget _buildIcon() {
    if (map.mapType == MapType.yandexMaps || map.mapType == MapType.yandexNavi) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.asset(AppIcons.yandexMap, width: 44, height: 44, fit: BoxFit.cover),
      );
    }
    if (map.mapType == MapType.google) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.asset(AppIcons.googleMap, width: 44, height: 44, fit: BoxFit.cover),
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SvgPicture.asset(
        map.icon,
        width: 44,
        height: 44,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            _buildIcon(),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                map.mapName,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF111827),
                ),
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Color(0xFFC7C7CC), size: 22),
          ],
        ),
      ),
    );
  }
}