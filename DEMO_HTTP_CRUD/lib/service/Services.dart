import 'dart:convert';
import 'package:book_manger_application/model/book.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;

class Services {
  final String url = 'https://68fb974194ec96066026944c.mockapi.io/Thang';

  // GET method
  Future<List<Book>> getBooks() async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200 || response.statusCode == 201) {
        var data = jsonDecode(response.body);
        List<Book> list = (data as List).map((e) => Book.fromJson(e)).toList();
        return list;
      } else {
        throw Exception('Failed to load books');
      }
    } catch (e) {
      debugPrint("Error getting books: $e");
      return [];
    }
  }

  // POST method - Add new book
  Future<bool> addBook(Book book) async {
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(book.toJson()),
      ); 
      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint("Book added successfully");
        return true;
      } else {
        throw Exception('Failed to add book');
      }
    } catch (e) {
      debugPrint("Error adding book: $e");
      return false;
    }
  }

  // PUT method - Update/Modify existing book
  Future<bool> updateBook(Book book) async {
    try {
      final response = await http.put(
        Uri.parse('$url/${book.id}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(book.toJson()),
      );
      
      if (response.statusCode == 200) {
        debugPrint("Book updated successfully");
        return true;
      } else {
        throw Exception('Failed to update book');
      }
    } catch (e) {
      debugPrint("Error updating book: $e");
      return false;
    }
  }

  // DELETE method - Delete book
  Future<bool> deleteBook(String id) async {
    try {
      final response = await http.delete(Uri.parse('$url/$id'));  
      if (response.statusCode == 200 || response.statusCode == 204) {
        debugPrint("Book deleted successfully");
        return true;
      } else {
        throw Exception('Failed to delete book');
      }
    } catch (e) {
      debugPrint("Error deleting book: $e");
      return false;
    }
  }
}

