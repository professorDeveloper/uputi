import '../models/response/user_model.dart';

abstract class UserRemoteDataSource {
  Future<UserModel> getUser();
}
