part of 'profile_bloc.dart';

@immutable
sealed class ProfileState {
  const ProfileState();
}

final class ProfileInitial extends ProfileState {
  const ProfileInitial();
}

final class ProfileLoading extends ProfileState {
  const ProfileLoading();
}

final class ProfileFailure extends ProfileState {
  final String message;
  const ProfileFailure({required this.message});
}

final class ProfileLoaded extends ProfileState {
  final ProfileViewData data;
  final bool isCarUpdating;

  const ProfileLoaded({
    required this.data,
    this.isCarUpdating = false,
  });
}

// ── View Data ──────────────────────────────────────────────────────────────

@immutable
class ProfileViewData {
  final int id;
  final String name;
  final String phone;
  final int rating;
  final int ratingCount;
  final String role;
  final int balance;
  final CarViewData? car;

  const ProfileViewData({
    required this.id,
    required this.name,
    required this.phone,
    required this.rating,
    required this.ratingCount,
    required this.role,
    this.balance = 0,
    this.car,
  });

  String get roleLabel {
    switch (role) {
      case 'driver':
        return "Haydovchi";
      case 'passenger':
      default:
        return "Yo'lovchi";
    }
  }

  bool get isDriver => role == 'driver';

  ProfileViewData copyWith({
    String? name,
    String? phone,
    int? rating,
    int? ratingCount,
    String? role,
    int? balance,
    CarViewData? car,
    bool clearCar = false,
  }) {
    return ProfileViewData(
      id: id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      rating: rating ?? this.rating,
      ratingCount: ratingCount ?? this.ratingCount,
      role: role ?? this.role,
      balance: balance ?? this.balance,
      car: clearCar ? null : (car ?? this.car),
    );
  }

  factory ProfileViewData.fromResponse(ProfileResponse r) {
    return ProfileViewData(
      id: r.id,
      name: r.name,
      phone: r.phone,
      rating: r.rating ?? 0,
      ratingCount: r.ratingCount ?? 0,
      role: r.role,
      balance: r.balance ?? 0,
      car: r.car != null ? CarViewData.fromCar(r.car!) : null,
    );
  }
}

@immutable
class CarViewData {
  final int id;
  final String model;
  final String color;
  final String number;

  const CarViewData({
    required this.id,
    required this.model,
    required this.color,
    required this.number,
  });

  factory CarViewData.fromCar(Car c) {
    return CarViewData(
      id: c.id,
      model: c.model,
      color: c.color,
      number: c.number,
    );
  }

  factory CarViewData.fromJson(Map<String, dynamic> json) {
    return CarViewData(
      id: _asInt(json['id']),
      model: (json['model'] ?? '').toString(),
      color: (json['color'] ?? '').toString(),
      number: (json['number'] ?? '').toString(),
    );
  }
}

int _asInt(dynamic v) {
  if (v is int) return v;
  if (v is double) return v.toInt();
  if (v is num) return v.toInt();
  return int.tryParse(v?.toString() ?? '') ?? 0;
}