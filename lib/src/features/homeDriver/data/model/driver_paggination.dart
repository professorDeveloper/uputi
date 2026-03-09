class DriverPagination {
  final int current;
  final String? nextUrl;
  final String? previousUrl;
  final int total;

  DriverPagination({
    required this.current,
    required this.nextUrl,
    required this.previousUrl,
    required this.total,
  });

  factory DriverPagination.fromJson(Map<String, dynamic> json) {
    return DriverPagination(
      current: json['current'] ?? 1,
      nextUrl: json['next'],
      previousUrl: json['previous'],
      total: json['total'] ?? 0,
    );
  }

  int? _extractPageFromUrl(String? url) {
    if (url == null) return null;
    final uri = Uri.tryParse(url);
    if (uri == null) return null;
    final pageParam = uri.queryParameters['page'];
    return pageParam != null ? int.tryParse(pageParam) : null;
  }

  int? get nextPage => _extractPageFromUrl(nextUrl);

  int? get previousPage => _extractPageFromUrl(previousUrl);
}

class PassengerTripsPage {
  final List<PassengerTripModel> items;
  final DriverPagination pagination;

  PassengerTripsPage({required this.items, required this.pagination});

  factory PassengerTripsPage.fromJson(Map<String, dynamic> json) {
    final rawItems = (json['items'] as List<dynamic>? ?? []);
    final paginationJson = (json['pagination'] as Map<String, dynamic>? ?? {});

    return PassengerTripsPage(
      items: rawItems
          .map((e) => PassengerTripModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      pagination: DriverPagination.fromJson(paginationJson),
    );
  }

  bool get hasMore => pagination.nextUrl != null;

  int get nextPage => pagination.nextPage ?? pagination.current;
}

class PassengerTripModel {
  final int id;
  final String fromAddress;
  final String toAddress;
  final String? fromLat;
  final String? fromLng;
  final String? toLat;
  final String? toLng;
  final String date;
  final String time;
  final int amount;
  final int seats;
  final String? comment;
  final bool? pochta;
  final PassengerTripUser user;

  PassengerTripModel({
    required this.id,
    required this.fromAddress,
    required this.toAddress,
    this.fromLat,
    this.fromLng,
    this.toLat,
    this.toLng,
    required this.date,
    required this.time,
    required this.amount,
    required this.seats,
    this.comment,
    this.pochta,
    required this.user,
  });

  factory PassengerTripModel.fromJson(Map<String, dynamic> json) {
    return PassengerTripModel(
      id: json['id'] ?? 0,
      fromAddress: json['from_address'] ?? '',
      toAddress: json['to_address'] ?? '',
      fromLat: json['from_lat']?.toString(),
      fromLng: json['from_lng']?.toString(),
      toLat: json['to_lat']?.toString(),
      toLng: json['to_lng']?.toString(),
      date: json['date'] ?? '',
      time: json['time'] ?? '',
      amount: json['amount'] ?? 0,
      seats: json['seats'] ?? 0,
      comment: json['comment']?.toString(),
      pochta: json['pochta'] as bool?,
      user: PassengerTripUser.fromJson(
        json['user'] as Map<String, dynamic>? ?? {},
      ),
    );
  }
}

class PassengerTripUser {
  final int id;
  final String name;
  final String phone;
  final double rating;
  final int ratingCount;

  PassengerTripUser({
    required this.id,
    required this.name,
    required this.phone,
    required this.rating,
    required this.ratingCount,
  });

  factory PassengerTripUser.fromJson(Map<String, dynamic> json) {
    return PassengerTripUser(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      rating: (json['rating'] ?? 0).toDouble(),
      ratingCount: json['rating_count'] ?? 0,
    );
  }
}
