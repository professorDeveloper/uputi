class Pagination {
  final int current;
  final String? nextUrl;
  final String? previousUrl;
  final int total;

  Pagination({
    required this.current,
    required this.nextUrl,
    required this.previousUrl,
    required this.total,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
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

class TripsPage {
  final List<DriverTripModel> items;
  final Pagination pagination;

  TripsPage({
    required this.items,
    required this.pagination,
  });

  factory TripsPage.fromJson(Map<String, dynamic> json) {
    final rawItems = (json['items'] as List<dynamic>? ?? []);
    final paginationJson = (json['pagination'] as Map<String, dynamic>? ?? {});

    return TripsPage(
      items: rawItems
          .map((e) => DriverTripModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      pagination: Pagination.fromJson(paginationJson),
    );
  }

  bool get hasMore => pagination.nextUrl != null;

  int get nextPage => pagination.nextPage ?? pagination.current;
}

class DriverTripModel {
  final int id;
  final String fromAddress;
  final String toAddress;
  final String date;
  final String time;
  final int amount;
  final int seats;
  final DriverUser user;

  DriverTripModel({
    required this.id,
    required this.fromAddress,
    required this.toAddress,
    required this.date,
    required this.time,
    required this.amount,
    required this.seats,
    required this.user,
  });

  factory DriverTripModel.fromJson(Map<String, dynamic> json) {
    return DriverTripModel(
      id: json['id'] ?? 0,
      fromAddress: json['from_address'] ?? '',
      toAddress: json['to_address'] ?? '',
      date: json['date'] ?? '',
      time: json['time'] ?? '',
      amount: json['amount'] ?? 0,
      seats: json['seats'] ?? 0,
      user: DriverUser.fromJson(json['user'] ?? {}),
    );
  }
}

class DriverUser {
  final int id;
  final String name;
  final String phone;
  final double rating;
  final int ratingCount;
  final DriverCar? car;

  DriverUser({
    required this.id,
    required this.name,
    required this.phone,
    required this.rating,
    required this.ratingCount,
    this.car,
  });

  factory DriverUser.fromJson(Map<String, dynamic> json) {
    return DriverUser(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      rating: (json['rating'] ?? 0).toDouble(),
      ratingCount: json['rating_count'] ?? 0,
      car: json['car'] == null ? null : DriverCar.fromJson(json['car']),
    );
  }
}

class DriverCar {
  final String model;
  final String color;
  final String number;

  DriverCar({
    required this.model,
    required this.color,
    required this.number,
  });

  factory DriverCar.fromJson(Map<String, dynamic> json) {
    return DriverCar(
      model: json['model'] ?? '',
      color: json['color'] ?? '',
      number: json['number'] ?? '',
    );
  }
}