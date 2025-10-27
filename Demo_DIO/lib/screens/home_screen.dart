import 'package:flutter/material.dart';
import '../models/book_model.dart';
import '../providers/book_provider.dart';
import '../screens/login_screen.dart';
import '../screens/add_edit_book_screen.dart';

class HomeScreen extends StatefulWidget {
  final BookProvider bookProvider;
  const HomeScreen({super.key, required this.bookProvider});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Book> _books = [];
  bool _isLoading = true;
  bool _isLoggedIn = false;
  String? _token;

  @override
  void initState() {
    super.initState();
    _fetchBooks();
  }

  Future<void> _fetchBooks() async {
    final result = await widget.bookProvider.getBooks();
    setState(() {
      _isLoading = false;
      if (result.success && result.data != null) {
        _books = result.data!;
      }
    });
  }

  void _onLoginSuccess(String token) {
    setState(() {
      _isLoggedIn = true;
      _token = token;
      widget.bookProvider.setAuthToken(token);
    });
  }

  void _logout() {
    setState(() {
      _isLoggedIn = false;
      _token = null;
      widget.bookProvider.clearAuthToken();
    });
  }

  Future<void> _deleteBook(String id) async {
    final result = await widget.bookProvider.deleteBook(id);
    if (result.success) {
      _fetchBooks();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Xóa thành công")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.errorMessage ?? "Xóa thất bại")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Danh sách sách"),
        actions: [
          _isLoggedIn
              ? IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: _logout,
                )
              : IconButton(
                  icon: const Icon(Icons.login),
                  onPressed: () async {
                    final token = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LoginScreen(),
                      ),
                    );
                    if (token != null) _onLoginSuccess(token);
                  },
                ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _books.isEmpty
              ? const Center(child: Text("Không có sách nào"))
              : ListView.builder(
                  itemCount: _books.length,
                  itemBuilder: (context, index) {
                    final book = _books[index];
                    return Card(
                      child: ListTile(
                        title: Text(book.name),
                        subtitle: Text(book.author),
                        trailing: _isLoggedIn
                            ? Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit),
                                    onPressed: () async {
                                      final updated = await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => AddEditBookScreen(
                                            bookProvider: widget.bookProvider,
                                            book: book,
                                          ),
                                        ),
                                      );
                                      if (updated == true) _fetchBooks();
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete),
                                    onPressed: () => _deleteBook(book.id ?? ''),
                                  ),
                                ],
                              )
                            : null,
                      ),
                    );
                  },
                ),
      floatingActionButton: _isLoggedIn
          ? FloatingActionButton(
              onPressed: () async {
                final added = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddEditBookScreen(
                      bookProvider: widget.bookProvider,
                    ),
                  ),
                );
                if (added == true) _fetchBooks();
              },
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}
