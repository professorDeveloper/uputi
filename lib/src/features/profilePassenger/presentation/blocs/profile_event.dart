part of 'profile_bloc.dart';

@immutable
sealed class ProfileEvent {
  const ProfileEvent();
}

final class ProfileFetch extends ProfileEvent {
  const ProfileFetch();
}

final class ProfileRefresh extends ProfileEvent {
  const ProfileRefresh();
}

final class ProfileRoleChanged extends ProfileEvent {
  final String role;
  const ProfileRoleChanged(this.role);
}

/// API ga POST /api/role/update yuboradi, keyin shellga o'tadi
final class ProfileRoleUpdateRequested extends ProfileEvent {
  final String role;
  const ProfileRoleUpdateRequested(this.role);
}

/// API ga POST /api/car/driver yuboradi (create or update)
final class ProfileCarUpdateRequested extends ProfileEvent {
  final String model;
  final String color;
  final String number;
  const ProfileCarUpdateRequested({
    required this.model,
    required this.color,
    required this.number,
  });
}