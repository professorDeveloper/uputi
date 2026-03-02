
class CityLocationSearchResponse {
  final List<CityTripItem> items;
  final CityPagination pagination;

  CityLocationSearchResponse({
    required this.items,
    required this.pagination,
  });

  factory CityLocationSearchResponse.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'];
    return CityLocationSearchResponse(
      items: rawItems is List
          ? rawItems
          .whereType<Map<String, dynamic>>()
          .map(CityTripItem.fromJson)
          .toList()
          : <CityTripItem>[],
      pagination: CityPagination.fromJson(
        json['pagination'] as Map<String, dynamic>? ?? const {},
      ),
    );
  }
}

class CityTripItem {
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

  final String? createdAt;
  final String? updatedAt;

  final String? fromAddressNormalized;
  final String? toAddressNormalized;

  final double? distance;

  final CityTripUser? user;

  CityTripItem({
    required this.id,
    required this.userId,
    required this.fromLat,
    required this.fromLng,
    required this.fromAddress,
    required this.toLat,
    required this.toLng,
    required this.toAddress,
    required this.status,
    required this.role,
    required this.date,
    required this.time,
    required this.amount,
    required this.seats,
    required this.comment,
    required this.pochta,
    required this.createdAt,
    required this.updatedAt,
    required this.fromAddressNormalized,
    required this.toAddressNormalized,
    required this.distance,
    required this.user,
  });

  factory CityTripItem.fromJson(Map<String, dynamic> json) {
    final u = json['user'];
    return CityTripItem(
      id: json['id'] as int?,
      userId: json['user_id'] as int?,
      fromLat: json['from_lat'] as String?,
      fromLng: json['from_lng'] as String?,
      fromAddress: json['from_address'] as String?,
      toLat: json['to_lat'] as String?,
      toLng: json['to_lng'] as String?,
      toAddress: json['to_address'] as String?,
      status: json['status'] as String?,
      role: json['role'] as String?,
      date: json['date'] as String?,
      time: json['time'] as String?,
      amount: json['amount'] as int?,
      seats: json['seats'] as int?,
      comment: json['comment'] as String?,
      pochta: json['pochta'] as bool?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
      fromAddressNormalized: json['from_address_normalized'] as String?,
      toAddressNormalized: json['to_address_normalized'] as String?,
      distance: (json['distance'] as num?)?.toDouble(),
      user: u is Map<String, dynamic> ? CityTripUser.fromJson(u) : null,
    );
  }
}

class CityTripUser {
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

  final CityCar? car;

  CityTripUser({
    required this.id,
    required this.avatar,
    required this.name,
    required this.phone,
    required this.telegramChatId,
    required this.role,
    required this.balance,
    required this.rating,
    required this.ratingCount,
    required this.deletedAt,
    required this.createdAt,
    required this.updatedAt,
    required this.car,
  });

  factory CityTripUser.fromJson(Map<String, dynamic> json) {
    final carJson = json['car'];
    return CityTripUser(
      id: json['id'] as int?,
      avatar: json['avatar'] as String?,
      name: json['name'] as String?,
      phone: json['phone'] as String?,
      telegramChatId: json['telegram_chat_id'] as int?,
      role: json['role'] as String?,
      balance: json['balance'] as int?,
      rating: json['rating'] as int?,
      ratingCount: json['rating_count'] as int?,
      deletedAt: json['deleted_at'] as String?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
      car: carJson is Map<String, dynamic> ? CityCar.fromJson(carJson) : null,
    );
  }
}

class CityCar {
  final int? id;
  final int? userId;
  final String? model;
  final String? color;
  final String? number;
  final String? createdAt;
  final String? updatedAt;

  CityCar({
    required this.id,
    required this.userId,
    required this.model,
    required this.color,
    required this.number,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CityCar.fromJson(Map<String, dynamic> json) {
    return CityCar(
      id: json['id'] as int?,
      userId: json['user_id'] as int?,
      model: json['model'] as String?,
      color: json['color'] as String?,
      number: json['number'] as String?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }
}

class CityPagination {
  final int? current;
  final int? previous;
  final int? next;
  final int? total;

  const CityPagination({
    required this.current,
    required this.previous,
    required this.next,
    required this.total,
  });

  factory CityPagination.fromJson(Map<String, dynamic> json) {
    return CityPagination(
      current: json['current'] as int?,
      previous: json['previous'] as int?,
      next: json['next'] as int?,
      total: json['total'] as int?,
    );
  }
}
