import 'package:dio/dio.dart';
import '../models/book_model.dart';
import 'auth_service.dart';

class BookService {
  static final BookService _instance = BookService._internal();
  factory BookService() => _instance;
  late final Dio dio;

  static const String baseUrl = 'https://68fceaa996f6ff19b9f6b38a.mockapi.io/Thang';

  BookService._internal() {
    dio = Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ));

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

  Future<List<BookModel>> getBooks() async {
    final resp = await dio.get(baseUrl);
    if (resp.statusCode == 200) {
      return (resp.data as List)
          .map((e) => BookModel.fromJson(e))
          .toList();
    } else {
      throw Exception('Không thể tải danh sách sách');
    }
  }

  Future<BookModel> addBook(BookModel book) async {
    final resp = await dio.post(baseUrl, data: book.toJson());
    return BookModel.fromJson(resp.data);
  }

  Future<BookModel> updateBook(String id, BookModel book) async {
    final resp = await dio.put('$baseUrl/$id', data: book.toJson());
    return BookModel.fromJson(resp.data);
  }

  Future<void> deleteBook(String id) async {
    await dio.delete('$baseUrl/$id');
  }
}
