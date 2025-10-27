import 'package:flutter/material.dart';
import '../models/book_model.dart';
import '../providers/book_provider.dart';

class AddEditBookScreen extends StatefulWidget {
  final BookProvider bookProvider;
  final Book? book;

  const AddEditBookScreen({
    super.key,
    required this.bookProvider,
    this.book,
  });

  @override
  State<AddEditBookScreen> createState() => _AddEditBookScreenState();
}

class _AddEditBookScreenState extends State<AddEditBookScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _authorController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.book != null) {
      _nameController.text = widget.book!.name;
      _authorController.text = widget.book!.author;
    }
  }

  Future<void> _saveBook() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final newBook = Book(
      id: widget.book?.id,
      name: _nameController.text.trim(),
      author: _authorController.text.trim(),
    );

    ServiceResult<bool> result;
    if (widget.book == null) {
      result = await widget.bookProvider.addBook(newBook);
    } else {
      result = await widget.bookProvider.updateBook(newBook);
    }

    setState(() => _isLoading = false);

    if (result.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.book == null
              ? "Thêm sách thành công"
              : "Cập nhật sách thành công"),
        ),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.errorMessage ?? "Lỗi không xác định")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.book != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? "Chỉnh sửa sách" : "Thêm sách mới"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: "Tên sách",
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) =>
                          v == null || v.isEmpty ? "Vui lòng nhập tên sách" : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _authorController,
                      decoration: const InputDecoration(
                        labelText: "Tác giả",
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) =>
                          v == null || v.isEmpty ? "Vui lòng nhập tác giả" : null,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: _saveBook,
                      icon: const Icon(Icons.save),
                      label: Text(isEdit ? "Lưu thay đổi" : "Thêm sách"),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 48),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _authorController.dispose();
    super.dispose();
  }
}
