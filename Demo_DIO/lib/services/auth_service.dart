import 'package:dio/dio.dart';
import '../models/user_model.dart';
import '../providers/book_provider.dart'; // Để dùng ServiceResult

class AuthService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'https://68fceaa996f6ff19b9f6b38a.mockapi.io/Users',
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 5),
    ),
  );

  Future<ServiceResult<UserModel>> login(String email, String password) async {
    try {
      final response = await _dio.get('', queryParameters: {
        'email': email,
        'password': password,
      });

      if (response.statusCode == 200) {
        final List data = response.data;
        if (data.isNotEmpty) {
          final user = UserModel.fromJson(data.first);
          return ServiceResult(success: true, data: user);
        } else {
          return ServiceResult(success: false, errorMessage: 'Sai email hoặc mật khẩu');
        }
      } else {
        return ServiceResult(success: false, errorMessage: 'Đăng nhập thất bại');
      }
    } on DioException catch (e) {
      return ServiceResult(success: false, errorMessage: e.message);
    } catch (e) {
      return ServiceResult(success: false, errorMessage: 'Lỗi không xác định');
    }
  }
}
