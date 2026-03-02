import '../../data/models/driver_history_resposne.dart';
import '../repo/driver_history_repo.dart';

class GetDriverHistoryUseCase {
  final DriverHistoryRepository repository;

  GetDriverHistoryUseCase(this.repository);

  Future<DriverHistoryResponse> call(GetDriverHistoryParams params) {
    return repository.getDriverHistory(type: params.type, page: params.page);
  }
}

class GetDriverHistoryParams {
  final int type;
  final int page;

  const GetDriverHistoryParams({required this.type, this.page = 1});
}
