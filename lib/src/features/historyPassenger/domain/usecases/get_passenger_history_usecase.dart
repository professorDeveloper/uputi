import '../../data/models/passenger_history_response.dart';
import '../repositories/passenger_history_repository.dart';

class GetPassengerHistoryUseCase {
  final PassengerHistoryRepository repository;
  GetPassengerHistoryUseCase(this.repository);

  Future<PassengerHistoryResponse> call(GetPassengerHistoryParams params) {
    return repository.getPassengerHistory(type: params.type, page: params.page);
  }
}

class GetPassengerHistoryParams {
  final int type;
  final int page;

  const GetPassengerHistoryParams({
    required this.type,
    this.page = 1,
  });
}
