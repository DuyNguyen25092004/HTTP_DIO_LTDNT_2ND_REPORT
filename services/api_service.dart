import 'package:dio/dio.dart';
import '../models/user_model.dart';
import 'auth_service.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  late final Dio dio;

  ApiService._internal() {
    dio = Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ));

    // Interceptor để chèn token tự động
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await AuthService.instance.getToken();
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = token;
        }
        return handler.next(options);
      },
    ));
  }

  // Đăng nhập
  Future<String> login({required String email, required String password}) async {
    const url = 'https://68fceaa996f6ff19b9f6b38a.mockapi.io/Users';
    final resp = await dio.get(url);
    if (resp.statusCode == 200) {
      final users = (resp.data as List)
          .map((e) => UserModel.fromJson(e))
          .toList();

      final found = users.firstWhere(
        (u) => u.email == email && u.password == password,
        orElse: () => UserModel(id: '', email: '', password: '', token: ''),
      );

      if (found.id.isNotEmpty) {
        await AuthService.instance.saveToken(found.token);
        return found.token;
      } else {
        throw Exception('Email hoặc mật khẩu không đúng');
      }
    } else {
      throw Exception('Lỗi kết nối API');
    }
  }
}
