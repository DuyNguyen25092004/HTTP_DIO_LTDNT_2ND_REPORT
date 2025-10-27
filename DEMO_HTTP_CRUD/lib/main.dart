import 'package:book_manger_application/model/book.dart';
import 'package:book_manger_application/service/Services.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Book Manager',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blueAccent,
        brightness: Brightness.light,
      ),
      home: const BookListScreen(),
    );
  }
}

class BookListScreen extends StatefulWidget {
  const BookListScreen({Key? key}) : super(key: key);

  @override
  State<BookListScreen> createState() => _BookListScreenState();
}

class _BookListScreenState extends State<BookListScreen>
    with SingleTickerProviderStateMixin {
  List<Book> books = [];
  bool isLoading = false;
  late AnimationController _controller;
  late Animation<Color?> _gradientAnimation;

  @override
  void initState() {
    super.initState();
    fetchBooks();

    // Gradient animation
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 5))
          ..repeat(reverse: true);
    _gradientAnimation =
        ColorTween(begin: Colors.blueAccent, end: Colors.tealAccent)
            .animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> fetchBooks() async {
    setState(() => isLoading = true);
    books = await Services().getBooks();
    setState(() => isLoading = false);
  }

  Future<void> addBook(Book book) async {
    bool success = await Services().addBook(book);
    if (success) {
      fetchBooks();
      _showSnackBar('Book added successfully');
    } else {
      _showSnackBar('Failed to add book');
    }
  }

  Future<void> updateBook(Book book) async {
    bool success = await Services().updateBook(book);
    if (success) {
      fetchBooks();
      _showSnackBar('Book updated successfully');
    } else {
      _showSnackBar('Failed to update book');
    }
  }

  Future<void> deleteBook(String id) async {
    bool success = await Services().deleteBook(id);
    if (success) {
      fetchBooks();
      _showSnackBar('Book deleted successfully');
    } else {
      _showSnackBar('Failed to delete book');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showAddEditDialog({Book? book}) {
    final titleController = TextEditingController(text: book?.title ?? '');
    final authorController = TextEditingController(text: book?.author ?? '');
    final yearController = TextEditingController(text: book?.year ?? '');
    final isEditing = book != null;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(isEditing ? Icons.edit : Icons.add, color: Colors.blueAccent),
            const SizedBox(width: 8),
            Text(isEditing ? 'Edit Book' : 'Add New Book'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            children: [
              _buildTextField(titleController, 'Title', Icons.book),
              const SizedBox(height: 12),
              _buildTextField(authorController, 'Author', Icons.person),
              const SizedBox(height: 12),
              _buildTextField(yearController, 'Year', Icons.calendar_today,
                  inputType: TextInputType.number),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (titleController.text.isNotEmpty &&
                  authorController.text.isNotEmpty &&
                  yearController.text.isNotEmpty) {
                final newBook = Book(
                  id: book?.id ?? '',
                  title: titleController.text,
                  author: authorController.text,
                  year: yearController.text,
                );
                if (isEditing) {
                  updateBook(newBook);
                } else {
                  addBook(newBook);
                }
                Navigator.pop(context);
              }
            },
            style:
                FilledButton.styleFrom(backgroundColor: Colors.blueAccent),
            child: Text(isEditing ? 'Update' : 'Add'),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      IconData icon, {TextInputType inputType = TextInputType.text}) {
    return TextField(
      controller: controller,
      keyboardType: inputType,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.blueAccent),
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: AnimatedBuilder(
          animation: _gradientAnimation,
          builder: (context, child) => AppBar(
            centerTitle: true,
            title: const Text(
              'Book Manager ',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22,
                letterSpacing: 1.2,
              ),
            ),
            flexibleSpace: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blueAccent, _gradientAnimation.value ?? Colors.teal],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            elevation: 6,
            shadowColor: Colors.blueAccent.withOpacity(0.4),
            actions: [
              IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: fetchBooks,
                  tooltip: "Refresh list"),
            ],
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : books.isEmpty
              ? const Center(
                  child: Text(
                    'No books yet.\nTap + to add one!',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: fetchBooks,
                  color: Colors.blueAccent,
                  child: ListView.builder(
                    itemCount: books.length,
                    itemBuilder: (context, index) => AnimatedOpacity(
                      opacity: 1,
                      duration: Duration(milliseconds: 200 + (index * 100)),
                      child: BookCard(
                        index: index + 1,
                        book: books[index],
                        onEdit: () => _showAddEditDialog(book: books[index]),
                        onDelete: () => deleteBook(books[index].id),
                      ),
                    ),
                  ),
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddEditDialog(),
        backgroundColor: Colors.blueAccent,
        icon: const Icon(Icons.add),
        label: const Text("Add Book"),
      ),
    );
  }
}

class BookCard extends StatelessWidget {
  final int index;
  final Book book;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const BookCard({
    super.key,
    required this.index,
    required this.book,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 4,
      shadowColor: Colors.blueAccent.withOpacity(0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blueAccent,
          child: Text(
            '$index',
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(
          book.title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.black87,
          ),
        ),
        subtitle: Text(
          "by ${book.author} • ${book.year}",
          style: TextStyle(color: Colors.grey[600]),
        ),
        trailing: PopupMenuButton<String>(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          onSelected: (value) {
            if (value == 'edit') onEdit();
            if (value == 'delete') onDelete();
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit, color: Colors.teal),
                  SizedBox(width: 8),
                  Text("Edit"),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: Colors.redAccent),
                  SizedBox(width: 8),
                  Text("Delete", style: TextStyle(color: Colors.redAccent)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}