import 'driver_trip_model.dart';

class BookingModel {
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

  final DriverTripModel trip;

  BookingModel({
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

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['id'] ?? 0,
      tripId: json['trip_id'] ?? 0,
      userId: json['user_id'] ?? 0,
      seats: json['seats'] ?? 0,

      offeredPrice: (json['offered_price'] is int && json['offered_price'] != 0)
          ? json['offered_price'] as int
          : null,
      comment: json['comment'] as String?,

      role: json['role'] ?? '',
      status: json['status'] ?? '',

      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',

      trip: DriverTripModel.fromJson(
        json['trip'] as Map<String, dynamic>? ?? {},
      ),
    );
  }
}