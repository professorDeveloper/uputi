import '../models/passenger_history_response.dart';
abstract class FetchHistoryDataSource {
  Future<PassengerHistoryResponse> fetchPassengerHistory({
    required int type,
    int page,
  });
}