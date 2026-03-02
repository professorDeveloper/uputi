sealed class ChooseDirectionsEvent {}

class ChooseDirectionsStarted extends ChooseDirectionsEvent {}

class ChooseDirectionsCenterChanged extends ChooseDirectionsEvent {
  final double lat;
  final double lng;
  ChooseDirectionsCenterChanged({required this.lat, required this.lng});
}

class ChooseDirectionsPickAt extends ChooseDirectionsEvent {
  final double lat;
  final double lng;
  ChooseDirectionsPickAt({required this.lat, required this.lng});
}

class ChooseDirectionsCommitPressed extends ChooseDirectionsEvent {}

class ChooseDirectionsSwitchToA extends ChooseDirectionsEvent {}
class ChooseDirectionsSwitchToB extends ChooseDirectionsEvent {}

class ChooseDirectionsClearA extends ChooseDirectionsEvent {}
class ChooseDirectionsClearB extends ChooseDirectionsEvent {}
