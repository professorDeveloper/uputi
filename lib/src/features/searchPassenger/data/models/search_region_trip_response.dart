import 'package:uputi/src/features/homePassenger/data/models/response/driver_trip_model.dart';

class SearchRegionTripResponse {
  final List<DriverTripModel> items;
  final PaginationModel pagination;

  SearchRegionTripResponse({required this.items, required this.pagination});

  factory SearchRegionTripResponse.empty() {
    return SearchRegionTripResponse(
      items: const [],
      pagination: PaginationModel(current: 0, previous: null, next: null, total: 0),
    );
  }

  factory SearchRegionTripResponse.fromJson(Map<String, dynamic> json) {
    final itemsJson = json['items'];
    return SearchRegionTripResponse(
      items: itemsJson is List
          ? itemsJson
          .whereType<Map<String, dynamic>>()
          .map((e) => DriverTripModel.fromJson(e))
          .toList()
          : <DriverTripModel>[],
      pagination: PaginationModel.fromJson(
        json['pagination'] as Map<String, dynamic>? ?? {},
      ),
    );
  }
}

class PaginationModel {
  final int? current;
  final int? previous;
  final String? next; // API returns a full URL string, not an int
  final int? total;

  PaginationModel({
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

  factory PaginationModel.fromJson(Map<String, dynamic> json) {
    return PaginationModel(
      current: json['current'] as int?,
      previous: json['previous'] is int ? json['previous'] as int? : null,
      next: json['next'] as String?,
      total: json['total'] as int?,
    );
  }
}