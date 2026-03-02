import 'package:uputi/src/features/homePassenger/data/models/response/driver_trip_model.dart';

class SearchRegionTripResponse {
  final List<DriverTripModel> items;
  final PaginationModel pagination;

  SearchRegionTripResponse({required this.items, required this.pagination});

  factory SearchRegionTripResponse.empty() {
    return SearchRegionTripResponse(
      items: const [],
      pagination: PaginationModel(current: 0, previous: 0, next: 0, total: 0),
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
  final int? next;
  final int? total;

  PaginationModel({
    required this.current,
    required this.previous,
    required this.next,
    required this.total,
  });

  factory PaginationModel.fromJson(Map<String, dynamic> json) {
    return PaginationModel(
      current: json['current'] as int?,
      previous: json['previous'] as int?,
      next: json['next'] as int?,
      total: json['total'] as int?,
    );
  }
}
