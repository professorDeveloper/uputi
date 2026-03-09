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
        previous: null,
        next: null,
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
  final String? next;
  final int? total;

  DriverSearchPagination({
    required this.current,
    required this.previous,
    required this.next,
    required this.total,
  });

  bool get hasNextPage => next != null && next!.isNotEmpty;

  int? get nextPage {
    if (next == null) return null;
    final uri = Uri.tryParse(next!);
    final pageStr = uri?.queryParameters['page'];
    return pageStr != null ? int.tryParse(pageStr) : null;
  }

  factory DriverSearchPagination.fromJson(Map<String, dynamic> json) {
    return DriverSearchPagination(
      current: json['current'] as int?,
      previous: json['previous'] is int ? json['previous'] as int? : null,
      next: json['next'] as String?,
      total: json['total'] as int?,
    );
  }
}