import 'package:uputi/src/features/homeDriver/data/model/driver_paggination.dart';

class SearchDriverRegionResponse {
  final List<PassengerTripModel> items;
  final DriverSearchPagination pagination;

  SearchDriverRegionResponse({required this.items, required this.pagination});

  factory SearchDriverRegionResponse.empty() {
    return SearchDriverRegionResponse(
      items: const [],
      pagination: DriverSearchPagination(
        current: 0,
        previous: 0,
        next: 0,
        total: 0,
      ),
    );
  }

  factory SearchDriverRegionResponse.fromJson(Map<String, dynamic> json) {
    final itemsJson = json['items'];
    return SearchDriverRegionResponse(
      items: itemsJson is List
          ? itemsJson
                .whereType<Map<String, dynamic>>()
                .map((e) => PassengerTripModel.fromJson(e))
                .toList()
          : <PassengerTripModel>[],
      pagination: DriverSearchPagination.fromJson(
        json['pagination'] as Map<String, dynamic>? ?? {},
      ),
    );
  }
}

class DriverSearchPagination {
  final int? current;
  final int? previous;
  final int? next;
  final int? total;

  DriverSearchPagination({
    required this.current,
    required this.previous,
    required this.next,
    required this.total,
  });

  factory DriverSearchPagination.fromJson(Map<String, dynamic> json) {
    return DriverSearchPagination(
      current: json['current'] as int?,
      previous: json['previous'] as int?,
      next: json['next'] as int?,
      total: json['total'] as int?,
    );
  }
}
