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