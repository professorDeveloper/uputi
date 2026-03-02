
class DriverBookingModel {
  final int? id;
  final int? tripId;
  final int? userId;
  final int? seats;

  final int? offeredPrice;
  final String? comment;

  final String? role;
  final String? status;

  final String? createdAt;
  final String? updatedAt;

  final DriverBookingTrip trip;

  DriverBookingModel({
    required this.id,
    required this.tripId,
    required this.userId,
    required this.seats,
    required this.offeredPrice,
    required this.comment,
    required this.role,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.trip,
  });

  factory DriverBookingModel.fromJson(Map<String, dynamic> json) {
    return DriverBookingModel(
      id: json['id'] ?? 0,
      tripId: json['trip_id'] ?? 0,
      userId: json['user_id'] ?? 0,
      seats: json['seats'] ?? 0,
      offeredPrice: json['offered_price'] as int?,
      comment: json['comment'] as String?,
      role: json['role'] ?? '',
      status: json['status'] ?? '',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      trip: DriverBookingTrip.fromJson(
        json['trip'] as Map<String, dynamic>? ?? {},
      ),
    );
  }
}

class DriverBookingTrip {
  final int id;
  final int? userId;
  final String fromAddress;
  final String toAddress;
  final String? fromLat;
  final String? fromLng;
  final String? toLat;
  final String? toLng;
  final String? status;
  final String? role;
  final String date;
  final String time;
  final int amount;
  final int seats;
  final String? comment;
  final bool? pochta;
  final String? createdAt;
  final String? updatedAt;
  final String? fromAddressNormalized;
  final String? toAddressNormalized;

  final DriverBookingTripUser? user;

  DriverBookingTrip({
    required this.id,
    this.userId,
    required this.fromAddress,
    required this.toAddress,
    this.fromLat,
    this.fromLng,
    this.toLat,
    this.toLng,
    this.status,
    this.role,
    required this.date,
    required this.time,
    required this.amount,
    required this.seats,
    this.comment,
    this.pochta,
    this.createdAt,
    this.updatedAt,
    this.fromAddressNormalized,
    this.toAddressNormalized,
    this.user,
  });

  factory DriverBookingTrip.fromJson(Map<String, dynamic> json) {
    return DriverBookingTrip(
      id: json['id'] ?? 0,
      userId: json['user_id'],
      fromAddress: json['from_address'] ?? '',
      toAddress: json['to_address'] ?? '',
      fromLat: json['from_lat']?.toString(),
      fromLng: json['from_lng']?.toString(),
      toLat: json['to_lat']?.toString(),
      toLng: json['to_lng']?.toString(),
      status: json['status']?.toString(),
      role: json['role']?.toString(),
      date: json['date'] ?? '',
      time: json['time'] ?? '',
      amount: json['amount'] ?? 0,
      seats: json['seats'] ?? 0,
      comment: json['comment']?.toString(),
      pochta: json['pochta'] as bool?,
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
      fromAddressNormalized: json['from_address_normalized']?.toString(),
      toAddressNormalized: json['to_address_normalized']?.toString(),
      user: json['user'] is Map<String, dynamic>
          ? DriverBookingTripUser.fromJson(json['user'] as Map<String, dynamic>)
          : null,
    );
  }

  String get safeTime {
    final t = (time).trim();
    if (t.isEmpty) return "Noma'lum";
    return t.length >= 5 ? t.substring(0, 5) : t;
  }
}

class DriverBookingTripUser {
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
  final String? createdAt;
  final String? updatedAt;

  DriverBookingTripUser({
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

  factory DriverBookingTripUser.fromJson(Map<String, dynamic> json) {
    return DriverBookingTripUser(
      id: json['id'],
      avatar: json['avatar']?.toString(),
      name: json['name']?.toString(),
      phone: json['phone']?.toString(),
      telegramChatId: json['telegram_chat_id'],
      role: json['role']?.toString(),
      balance: json['balance'],
      rating: json['rating'],
      ratingCount: json['rating_count'],
      deletedAt: json['deleted_at']?.toString(),
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
    );
  }
}