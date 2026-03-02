import '../../data/models/passenger_history_response.dart';

abstract class PassengerHistoryRepository {
  Future<PassengerHistoryResponse> getPassengerHistory({
    required int type,
    int page,
  });
}
