import 'package:book_manager_application/models/book_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:dio_smart_retry/dio_smart_retry.dart';

class ServiceResult<T> {
  final bool success;
  final T? data;
  final String? errorMessage;

  ServiceResult({required this.success, this.data, this.errorMessage});
}

class BookProvider {
  final String url = 'https://68fb974194ec96066026944c.mockapi.io/Thang';
  late final Dio _dio;

  Services() {
    _dio = Dio(
      BaseOptions(
        baseUrl: url,
        connectTimeout: const Duration(seconds: 5),
        receiveTimeout: const Duration(seconds: 3),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    // retry mechanism
    _dio.interceptors.add(
      RetryInterceptor(
        dio: _dio,
        retries: 3,
        retryDelays: const [
          Duration(seconds: 1),
          Duration(seconds: 2),
          Duration(seconds: 3),
        ],
      ),
    );
  }

  // thêm token động
  void setAuthToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  void clearAuthToken() {
    _dio.options.headers.remove('Authorization');
  }

  String _getErrorMessage(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return 'Connection timeout - please check your internet';
      case DioExceptionType.sendTimeout:
        return 'Send timeout - request took too long';
      case DioExceptionType.receiveTimeout:
        return 'Receive timeout - server is not responding';
      case DioExceptionType.badResponse:
        return 'Server error: ${error.response?.statusCode} - ${error.response?.statusMessage}';
      case DioExceptionType.cancel:
        return 'Request was cancelled';
      case DioExceptionType.connectionError:
        return 'No internet connection. Please check your network';
      case DioExceptionType.badCertificate:
        return 'Certificate verification failed';
      case DioExceptionType.unknown:
      default:
        return 'Unexpected error occurred. Please try again';
    }
  }

  // GET method
  Future<ServiceResult<List<Book>>> getBooks() async {
    try {
      final response = await _dio.get('');
      if (response.statusCode == 200 || response.statusCode == 201) {
        List<Book> list =
            (response.data as List).map((e) => Book.fromJson(e)).toList();
        return ServiceResult(success: true, data: list);
      } else {
        return ServiceResult(
          success: false,
          errorMessage: 'Failed to load books',
        );
      }
    } on DioException catch (e) {
      String errorMsg = _getErrorMessage(e);
      if (e.type == DioExceptionType.connectionError) {
        errorMsg = "No internet connection available";
      } else if (e.response?.statusCode == 404) {
        errorMsg = "The server not found";
      }
      debugPrint("Error getting books: $errorMsg");
      return ServiceResult(success: false, errorMessage: errorMsg);
    } catch (e) {
      debugPrint("Unexpected error getting books: $e");
      return ServiceResult(
        success: false,
        errorMessage: 'An unexpected error occurred',
      );
    }
  }

  // POST method - Add new book
  Future<ServiceResult<bool>> addBook(Book book) async {
    try {
      final response = await _dio.post('', data: book.toJson());
      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint("Book added successfully");
        return ServiceResult(success: true, data: true);
      } else {
        return ServiceResult(
          success: false,
          errorMessage: 'Failed to add book',
        );
      }
    } on DioException catch (e) {
      String errorMsg = _getErrorMessage(e);
      if (e.response?.statusCode == 400) {
        errorMsg = "Invalid book data. Please check your input";
      }
      debugPrint("Error adding book: $errorMsg");
      return ServiceResult(success: false, errorMessage: errorMsg);
    } catch (e) {
      debugPrint("Unexpected error adding book: $e");
      return ServiceResult(
        success: false,
        errorMessage: 'Failed to add book. Please try again',
      );
    }
  }

  // PUT method - Update book
  Future<ServiceResult<bool>> updateBook(Book book) async {
    try {
      final response = await _dio.put('/${book.id}', data: book.toJson());
      if (response.statusCode == 200) {
        debugPrint("Book updated successfully");
        return ServiceResult(success: true, data: true);
      } else {
        return ServiceResult(
          success: false,
          errorMessage: 'Failed to update book',
        );
      }
    } on DioException catch (e) {
      String errorMsg = _getErrorMessage(e);
      if (e.response?.statusCode == 404) {
        errorMsg = "Book not found";
      } else if (e.response?.statusCode == 400) {
        errorMsg = "Invalid book data";
      }
      debugPrint("Error updating book: $errorMsg");
      return ServiceResult(success: false, errorMessage: errorMsg);
    } catch (e) {
      debugPrint("Unexpected error updating book: $e");
      return ServiceResult(
        success: false,
        errorMessage: 'Failed to update book. Please try again',
      );
    }
  }

  // DELETE method
  Future<ServiceResult<bool>> deleteBook(String id) async {
    try {
      final response = await _dio.delete('/$id');
      if (response.statusCode == 200 || response.statusCode == 204) {
        debugPrint("Book deleted successfully");
        return ServiceResult(success: true, data: true);
      } else {
        return ServiceResult(
          success: false,
          errorMessage: 'Failed to delete book',
        );
      }
    } on DioException catch (e) {
      String errorMsg = _getErrorMessage(e);
      if (e.response?.statusCode == 404) {
        errorMsg = "Book not found";
      }
      debugPrint("Error deleting book: $errorMsg");
      return ServiceResult(success: false, errorMessage: errorMsg);
    } catch (e) {
      debugPrint("Unexpected error deleting book: $e");
      return ServiceResult(
        success: false,
        errorMessage: 'Failed to delete book. Please try again',
      );
    }
  }

  void cancelRequests() {
    _dio.close(force: true);
  }
}
