import 'dart:convert';

class MyTripsResponse {
  final List<MyTripItem> items;

  const MyTripsResponse({required this.items});

  factory MyTripsResponse.fromJsonList(List<dynamic> json) {
    return MyTripsResponse(
      items: json
          .map((e) => MyTripItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  factory MyTripsResponse.fromJsonString(String source) {
    final decoded = jsonDecode(source);
    if (decoded is List) return MyTripsResponse.fromJsonList(decoded);
    if (decoded is Map && decoded['data'] is List) {
      return MyTripsResponse.fromJsonList(decoded['data'] as List);
    }
    throw const FormatException('Invalid MyTripsResponse format');
  }
}

class MyTripItem {
  final int? id;
  final int? userId;

  final String? fromLat;
  final String? fromLng;
  final String? fromAddress;

  final String? toLat;
  final String? toLng;
  final String? toAddress;

  final String? status; // active / in_progress ...
  final String? role;

  final String? date;
  final String? time; // "12:00:00"

  final int? amount;
  final int? seats;

  final String? comment;
  final bool? pochta;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  final String? fromAddressNormalized;
  final String? toAddressNormalized;

  final List<MyTripBooking> bookings;

  const MyTripItem({
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

  factory MyTripItem.fromJson(Map<String, dynamic> json) {
    return MyTripItem(
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
          .map((e) => MyTripBooking.fromJson(e.cast<String, dynamic>()))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'from_lat': fromLat,
    'from_lng': fromLng,
    'from_address': fromAddress,
    'to_lat': toLat,
    'to_lng': toLng,
    'to_address': toAddress,
    'status': status,
    'role': role,
    'date': date,
    'time': time,
    'amount': amount,
    'seats': seats,
    'comment': comment,
    'pochta': pochta,
    'created_at': createdAt?.toIso8601String(),
    'updated_at': updatedAt?.toIso8601String(),
    'from_address_normalized': fromAddressNormalized,
    'to_address_normalized': toAddressNormalized,
    'bookings': bookings.map((e) => e.toJson()).toList(),
  };


  MyTripBooking? get driverBooking {
    for (final b in bookings) {
      if ((b.role ?? '').toLowerCase().trim() == 'driver') return b;
    }
    return null;
  }

  bool get hasDriver => driverBooking != null;

  MyTripUser? get driverUser => driverBooking?.user;

  String get safeTime {
    final t = (time ?? '').trim();
    if (t.isEmpty) return 'Nomaʼlum vaqt';
    return t.length >= 5 ? t.substring(0, 5) : t;
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

class MyTripBooking {
  final int? id;
  final int? tripId;
  final int? userId;
  final int? seats;
  final int? offeredPrice;
  final String? comment;
  final String? role;   // driver
  final String? status; // in_progress
  final DateTime? createdAt;
  final DateTime? updatedAt;

  final MyTripUser? user;

  const MyTripBooking({
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

  factory MyTripBooking.fromJson(Map<String, dynamic> json) {
    return MyTripBooking(
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
          ? MyTripUser.fromJson(json['user'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'trip_id': tripId,
    'user_id': userId,
    'seats': seats,
    'offered_price': offeredPrice,
    'comment': comment,
    'role': role,
    'status': status,
    'created_at': createdAt?.toIso8601String(),
    'updated_at': updatedAt?.toIso8601String(),
    'user': user?.toJson(),
  };

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

class MyTripUser {
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

  final MyTripCar? car;

  const MyTripUser({
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
    this.car,
  });

  factory MyTripUser.fromJson(Map<String, dynamic> json) {
    return MyTripUser(
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
      car: (json['car'] is Map<String, dynamic>)
          ? MyTripCar.fromJson(json['car'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'avatar': avatar,
    'name': name,
    'phone': phone,
    'telegram_chat_id': telegramChatId,
    'role': role,
    'balance': balance,
    'rating': rating,
    'rating_count': ratingCount,
    'deleted_at': deletedAt,
    'created_at': createdAt?.toIso8601String(),
    'updated_at': updatedAt?.toIso8601String(),
    'car': car?.toJson(),
  };

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

class MyTripCar {
  final int? id;
  final int? userId;
  final String? model;
  final String? color;
  final String? number;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const MyTripCar({
    this.id,
    this.userId,
    this.model,
    this.color,
    this.number,
    this.createdAt,
    this.updatedAt,
  });

  factory MyTripCar.fromJson(Map<String, dynamic> json) {
    return MyTripCar(
      id: _toInt(json['id']),
      userId: _toInt(json['user_id']),
      model: json['model']?.toString(),
      color: json['color']?.toString(),
      number: json['number']?.toString(),
      createdAt: _toDateTime(json['created_at']),
      updatedAt: _toDateTime(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'model': model,
    'color': color,
    'number': number,
    'created_at': createdAt?.toIso8601String(),
    'updated_at': updatedAt?.toIso8601String(),
  };

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
