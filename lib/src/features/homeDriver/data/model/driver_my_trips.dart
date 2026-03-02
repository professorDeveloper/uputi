import 'dart:convert';


class DriverMyTripsResponse {
  final List<DriverMyTripItem> items;

  const DriverMyTripsResponse({required this.items});

  factory DriverMyTripsResponse.fromJsonList(List<dynamic> json) {
    return DriverMyTripsResponse(
      items: json
          .map((e) => DriverMyTripItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  factory DriverMyTripsResponse.fromJsonString(String source) {
    final decoded = jsonDecode(source);
    if (decoded is List) return DriverMyTripsResponse.fromJsonList(decoded);
    if (decoded is Map && decoded['data'] is List) {
      return DriverMyTripsResponse.fromJsonList(decoded['data'] as List);
    }
    throw const FormatException('Invalid DriverMyTripsResponse format');
  }
}

/// Driver o'zi yaratgan trip
class DriverMyTripItem {
  final int? id;
  final int? userId;

  final String? fromLat;
  final String? fromLng;
  final String? fromAddress;

  final String? toLat;
  final String? toLng;
  final String? toAddress;

  final String? status;
  final String? role;

  final String? date;
  final String? time;

  final int? amount;
  final int? seats;

  final String? comment;
  final bool? pochta;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  final String? fromAddressNormalized;
  final String? toAddressNormalized;

  final List<DriverMyTripBooking> bookings;

  const DriverMyTripItem({
    this.id,
    this.userId,
    this.fromLat,
    this.fromLng,
    this.fromAddress,
    this.toLat,
    this.toLng,
    this.toAddress,
    this.status,
    this.role,
    this.date,
    this.time,
    this.amount,
    this.seats,
    this.comment,
    this.pochta,
    this.createdAt,
    this.updatedAt,
    this.fromAddressNormalized,
    this.toAddressNormalized,
    required this.bookings,
  });

  factory DriverMyTripItem.fromJson(Map<String, dynamic> json) {
    return DriverMyTripItem(
      id: _toInt(json['id']),
      userId: _toInt(json['user_id']),
      fromLat: json['from_lat']?.toString(),
      fromLng: json['from_lng']?.toString(),
      fromAddress: json['from_address']?.toString(),
      toLat: json['to_lat']?.toString(),
      toLng: json['to_lng']?.toString(),
      toAddress: json['to_address']?.toString(),
      status: json['status']?.toString(),
      role: json['role']?.toString(),
      date: json['date']?.toString(),
      time: json['time']?.toString(),
      amount: _toInt(json['amount']),
      seats: _toInt(json['seats']),
      comment: json['comment']?.toString(),
      pochta: _toBool(json['pochta']),
      createdAt: _toDateTime(json['created_at']),
      updatedAt: _toDateTime(json['updated_at']),
      fromAddressNormalized: json['from_address_normalized']?.toString(),
      toAddressNormalized: json['to_address_normalized']?.toString(),
      bookings: (json['bookings'] as List<dynamic>? ?? [])
          .whereType<Map>()
          .map((e) => DriverMyTripBooking.fromJson(e.cast<String, dynamic>()))
          .toList(),
    );
  }

  String get safeTime {
    final t = (time ?? '').trim();
    if (t.isEmpty) return "Noma'lum";
    return t.length >= 5 ? t.substring(0, 5) : t;
  }

  DriverMyTripBooking? get passengerBooking {
    for (final b in bookings) {
      if ((b.role ?? '').toLowerCase().trim() == 'passenger') return b;
    }
    return null;
  }

  bool get hasPassenger => passengerBooking != null;

  static int? _toInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    return int.tryParse(v.toString());
  }

  static DateTime? _toDateTime(dynamic v) {
    if (v == null) return null;
    return DateTime.tryParse(v.toString());
  }

  static bool? _toBool(dynamic v) {
    if (v == null) return null;
    if (v is bool) return v;
    if (v is num) return v != 0;
    final s = v.toString().toLowerCase().trim();
    if (s == 'true' || s == '1') return true;
    if (s == 'false' || s == '0') return false;
    return null;
  }
}

class DriverMyTripBooking {
  final int? id;
  final int? tripId;
  final int? userId;
  final int? seats;
  final int? offeredPrice;
  final String? comment;
  final String? role;
  final String? status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  final DriverMyTripUser? user;

  const DriverMyTripBooking({
    this.id,
    this.tripId,
    this.userId,
    this.seats,
    this.offeredPrice,
    this.comment,
    this.role,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.user,
  });

  factory DriverMyTripBooking.fromJson(Map<String, dynamic> json) {
    return DriverMyTripBooking(
      id: _toInt(json['id']),
      tripId: _toInt(json['trip_id']),
      userId: _toInt(json['user_id']),
      seats: _toInt(json['seats']),
      offeredPrice: _toInt(json['offered_price']),
      comment: json['comment']?.toString(),
      role: json['role']?.toString(),
      status: json['status']?.toString(),
      createdAt: _toDateTime(json['created_at']),
      updatedAt: _toDateTime(json['updated_at']),
      user: (json['user'] is Map<String, dynamic>)
          ? DriverMyTripUser.fromJson(json['user'] as Map<String, dynamic>)
          : null,
    );
  }

  static int? _toInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    return int.tryParse(v.toString());
  }

  static DateTime? _toDateTime(dynamic v) {
    if (v == null) return null;
    return DateTime.tryParse(v.toString());
  }
}

class DriverMyTripUser {
  final int? id;
  final String? avatar;
  final String? name;
  final String? phone;
  final int? telegramChatId;
  final String? role;
  final int? balance;
  final int? rating;
  final int? ratingCount;
  final String? deletedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const DriverMyTripUser({
    this.id,
    this.avatar,
    this.name,
    this.phone,
    this.telegramChatId,
    this.role,
    this.balance,
    this.rating,
    this.ratingCount,
    this.deletedAt,
    this.createdAt,
    this.updatedAt,
  });

  factory DriverMyTripUser.fromJson(Map<String, dynamic> json) {
    return DriverMyTripUser(
      id: _toInt(json['id']),
      avatar: json['avatar']?.toString(),
      name: json['name']?.toString(),
      phone: json['phone']?.toString(),
      telegramChatId: _toInt(json['telegram_chat_id']),
      role: json['role']?.toString(),
      balance: _toInt(json['balance']),
      rating: _toInt(json['rating']),
      ratingCount: _toInt(json['rating_count']),
      deletedAt: json['deleted_at']?.toString(),
      createdAt: _toDateTime(json['created_at']),
      updatedAt: _toDateTime(json['updated_at']),
    );
  }

  static int? _toInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    return int.tryParse(v.toString());
  }

  static DateTime? _toDateTime(dynamic v) {
    if (v == null) return null;
    return DateTime.tryParse(v.toString());
  }
}