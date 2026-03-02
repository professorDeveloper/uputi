import '../../data/models/driver_history_resposne.dart';

abstract class FetchDriverHistoryDataSource {
  Future<DriverHistoryResponse> fetchDriverHistory({
    required int type,
    int page = 1,
  });
}
