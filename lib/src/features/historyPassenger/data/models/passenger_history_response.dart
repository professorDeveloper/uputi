class PassengerHistoryResponse {
  final TripsPage trips;

  PassengerHistoryResponse({required this.trips});

  factory PassengerHistoryResponse.fromJson(Map<String, dynamic> json) {
    // type=1 => key: "trips",  data: [ Trip... ]
    // type=2 => key: "bookings", data: [ { booking fields + "trip": Trip } ]
    final isBookingResponse =
        json.containsKey('bookings') && !json.containsKey('trips');

    final raw = (json['bookings'] ?? json['trips']) as Map?;
    final pageMap = raw?.cast<String, dynamic>() ?? const <String, dynamic>{};

    return PassengerHistoryResponse(
      trips: isBookingResponse
          ? TripsPage.fromBookingsJson(pageMap)
          : TripsPage.fromJson(pageMap),
    );
  }
}

class TripsPage {
  final int currentPage;
  final List<Trip> data;

  final String? firstPageUrl;
  final int? from;
  final int lastPage;
  final String? lastPageUrl;

  final List<PageLink> links;

  final String? nextPageUrl;
  final String? path;
  final int perPage;
  final String? prevPageUrl;
  final int? to;
  final int total;

  TripsPage({
    required this.currentPage,
    required this.data,
    required this.lastPage,
    required this.perPage,
    required this.total,
    required this.links,
    this.firstPageUrl,
    this.from,
    this.lastPageUrl,
    this.nextPageUrl,
    this.path,
    this.prevPageUrl,
    this.to,
  });

  bool get hasNext => currentPage < lastPage;

  factory TripsPage.fromJson(Map<String, dynamic> json) {
    return TripsPage(
      currentPage: _asInt(json['current_page']),
      data: (json['data'] as List? ?? [])
          .map((e) => Trip.fromJson(e as Map<String, dynamic>))
          .toList(),
      firstPageUrl: json['first_page_url'] as String?,
      from: json['from'] == null ? null : _asInt(json['from']),
      lastPage: _asInt(json['last_page']),
      lastPageUrl: json['last_page_url'] as String?,
      links: (json['links'] as List? ?? [])
          .map((e) => PageLink.fromJson(e as Map<String, dynamic>))
          .toList(),
      nextPageUrl: json['next_page_url'] as String?,
      path: json['path'] as String?,
      perPage: _asInt(json['per_page']),
      prevPageUrl: json['prev_page_url'] as String?,
      to: json['to'] == null ? null : _asInt(json['to']),
      total: _asInt(json['total']),
    );
  }

  /// type=2: data elementi Booking, ichida "trip" nested
  factory TripsPage.fromBookingsJson(Map<String, dynamic> json) {
    final trips = (json['data'] as List? ?? [])
        .map((e) {
          try {
            final bookingMap = e as Map<String, dynamic>;
            final tripMap = bookingMap['trip'] as Map<String, dynamic>?;
            if (tripMap == null) return null;

            // booking ichidagi bookings listini trip ga qo'shamiz
            final bookingEntry = <String, dynamic>{
              'id': bookingMap['id'],
              'trip_id': bookingMap['trip_id'],
              'user_id': bookingMap['user_id'],
              'seats': bookingMap['seats'],
              'offered_price': bookingMap['offered_price'],
              'comment': bookingMap['comment'],
              'role': bookingMap['role'],
              'status': bookingMap['status'],
              'created_at': bookingMap['created_at'],
              'updated_at': bookingMap['updated_at'],
              'user': tripMap['user'],
            };

            // trip ga bookings qo'shamiz (agar yo'q bo'lsa)
            final tripWithBookings = Map<String, dynamic>.from(tripMap);
            if (tripWithBookings['bookings'] == null ||
                (tripWithBookings['bookings'] as List).isEmpty) {
              tripWithBookings['bookings'] = [bookingEntry];
            }

            // booking status ni ishlatamiz
            tripWithBookings['status'] =
                bookingMap['status'] ?? tripMap['status'] ?? '';

            return Trip.fromJson(tripWithBookings);
          } catch (_) {
            return null;
          }
        })
        .whereType<Trip>()
        .toList();

    return TripsPage(
      currentPage: _asInt(json['current_page']),
      data: trips,
      firstPageUrl: json['first_page_url'] as String?,
      from: json['from'] == null ? null : _asInt(json['from']),
      lastPage: _asInt(json['last_page']),
      lastPageUrl: json['last_page_url'] as String?,
      links: (json['links'] as List? ?? [])
          .map((e) => PageLink.fromJson(e as Map<String, dynamic>))
          .toList(),
      nextPageUrl: json['next_page_url'] as String?,
      path: json['path'] as String?,
      perPage: _asInt(json['per_page']),
      prevPageUrl: json['prev_page_url'] as String?,
      to: json['to'] == null ? null : _asInt(json['to']),
      total: _asInt(json['total']),
    );
  }
}

class PageLink {
  final String? url;
  final String label;
  final bool active;

  PageLink({required this.url, required this.label, required this.active});

  factory PageLink.fromJson(Map<String, dynamic> json) {
    return PageLink(
      url: json['url'] as String?,
      label: (json['label'] ?? '').toString(),
      active: json['active'] as bool? ?? false,
    );
  }
}

class Trip {
  final int id;
  final int? userId;

  final double? fromLat;
  final double? fromLng;
  final double? toLat;
  final double? toLng;

  final String fromAddress;
  final String toAddress;

  final String status;
  final String role;

  final String date;
  final String time;

  final int amount;
  final int seats;

  final String? comment;
  final bool pochta;

  final String? createdAt;
  final String? updatedAt;

  final String? fromAddressNormalized;
  final String? toAddressNormalized;

  final List<Booking> bookings;

  Trip({
    required this.id,
    required this.fromAddress,
    required this.toAddress,
    required this.status,
    required this.role,
    required this.date,
    required this.time,
    required this.amount,
    required this.seats,
    required this.pochta,
    required this.bookings,
    this.userId,
    this.fromLat,
    this.fromLng,
    this.toLat,
    this.toLng,
    this.comment,
    this.createdAt,
    this.updatedAt,
    this.fromAddressNormalized,
    this.toAddressNormalized,
  });

  factory Trip.fromJson(Map<String, dynamic> json) {
    return Trip(
      id: _asInt(json['id']),
      userId: json['user_id'] == null ? null : _asInt(json['user_id']),
      fromLat: _asDoubleOrNull(json['from_lat']),
      fromLng: _asDoubleOrNull(json['from_lng']),
      toLat: _asDoubleOrNull(json['to_lat']),
      toLng: _asDoubleOrNull(json['to_lng']),
      fromAddress: (json['from_address'] ?? '').toString(),
      toAddress: (json['to_address'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
      role: (json['role'] ?? '').toString(),
      date: (json['date'] ?? '').toString(),
      time: (json['time'] ?? '').toString(),
      amount: _asInt(json['amount']),
      seats: _asInt(json['seats']),
      comment: json['comment']?.toString(),
      pochta: json['pochta'] as bool? ?? false,
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
      fromAddressNormalized: json['from_address_normalized']?.toString(),
      toAddressNormalized: json['to_address_normalized']?.toString(),
      bookings: (json['bookings'] as List? ?? [])
          .map((e) => Booking.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class Booking {
  final int id;
  final int? tripId;
  final int? userId;

  final int seats;
  final int? offeredPrice;
  final String? comment;

  final String role;
  final String status;

  final String? createdAt;
  final String? updatedAt;

  final User user;

  Booking({
    required this.id,
    required this.seats,
    required this.role,
    required this.status,
    required this.user,
    this.tripId,
    this.userId,
    this.offeredPrice,
    this.comment,
    this.createdAt,
    this.updatedAt,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: _asInt(json['id']),
      tripId: json['trip_id'] == null ? null : _asInt(json['trip_id']),
      userId: json['user_id'] == null ? null : _asInt(json['user_id']),
      seats: _asInt(json['seats']),
      offeredPrice: json['offered_price'] == null ? null : _asInt(json['offered_price']),
      comment: json['comment']?.toString(),
      role: (json['role'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
      user: User.fromJson(json['user'] as Map<String, dynamic>),
    );
  }
}

class User {
  final int id;
  final String? avatar;
  final String name;
  final String phone;

  final int? telegramChatId;

  final String role;
  final int? balance;

  final int? rating;
  final int? ratingCount;

  final String? deletedAt;
  final String? createdAt;
  final String? updatedAt;

  final Car? car;

  User({
    required this.id,
    required this.name,
    required this.phone,
    required this.role,
    this.avatar,
    this.telegramChatId,
    this.balance,
    this.rating,
    this.ratingCount,
    this.deletedAt,
    this.createdAt,
    this.updatedAt,
    this.car,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: _asInt(json['id']),
      avatar: json['avatar']?.toString(),
      name: (json['name'] ?? '').toString(),
      phone: (json['phone'] ?? '').toString(),
      telegramChatId: json['telegram_chat_id'] == null ? null : _asInt(json['telegram_chat_id']),
      role: (json['role'] ?? '').toString(),
      balance: json['balance'] == null ? null : _asInt(json['balance']),
      rating: json['rating'] == null ? null : _asInt(json['rating']),
      ratingCount: json['rating_count'] == null ? null : _asInt(json['rating_count']),
      deletedAt: json['deleted_at']?.toString(),
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
      car: json['car'] == null ? null : Car.fromJson(json['car'] as Map<String, dynamic>),
    );
  }
}

class Car {
  final int id;
  final int? userId;
  final String model;
  final String color;
  final String number;

  final String? createdAt;
  final String? updatedAt;

  Car({
    required this.id,
    required this.model,
    required this.color,
    required this.number,
    this.userId,
    this.createdAt,
    this.updatedAt,
  });

  factory Car.fromJson(Map<String, dynamic> json) {
    return Car(
      id: _asInt(json['id']),
      userId: json['user_id'] == null ? null : _asInt(json['user_id']),
      model: (json['model'] ?? '').toString(),
      color: (json['color'] ?? '').toString(),
      number: (json['number'] ?? '').toString(),
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
    );
  }
}


int _asInt(dynamic v) {
  if (v is int) return v;
  if (v is double) return v.toInt();
  if (v is num) return v.toInt();
  return int.tryParse(v?.toString() ?? '') ?? 0;
}

double? _asDoubleOrNull(dynamic v) {
  if (v == null) return null;
  if (v is double) return v;
  if (v is int) return v.toDouble();
  if (v is num) return v.toDouble();
  return double.tryParse(v.toString());
}
