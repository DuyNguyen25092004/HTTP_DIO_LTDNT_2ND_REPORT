import 'package:flutter/material.dart';
import '../models/book_model.dart';
import '../services/book_service.dart';

class BookProvider extends ChangeNotifier {
  List<BookModel> _books = [];
  List<BookModel> get books => _books;

  Future<void> loadBooks() async {
    _books = await BookService().getBooks();
    notifyListeners();
  }

  Future<void> addBook(BookModel book) async {
    final newBook = await BookService().addBook(book);
    _books.insert(0, newBook);
    notifyListeners();
  }

  Future<void> removeBook(String id) async {
    await BookService().deleteBook(id);
    _books.removeWhere((b) => b.id == id);
    notifyListeners();
  }
}
