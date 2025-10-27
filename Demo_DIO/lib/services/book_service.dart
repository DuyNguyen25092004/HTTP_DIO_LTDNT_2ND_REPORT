import 'package:dio/dio.dart';
import '../models/book_model.dart';

class BookService {
  final Dio _dio;

  BookService(this._dio);

  Future<List<Book>> fetchBooks() async {
    try {
      final response = await _dio.get('/Thang');
      return (response.data as List).map((b) => Book.fromJson(b)).toList();
    } on DioException catch (e) {
      throw Exception('Không thể tải sách: ${e.message}');
    }
  }
}
