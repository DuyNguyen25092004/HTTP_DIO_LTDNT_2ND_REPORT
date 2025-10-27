import 'package:flutter/material.dart';
import 'providers/book_provider.dart';
import 'screens/home_screen.dart';

void main() {
  final bookProvider = BookProvider();
  bookProvider.Services();
  runApp(MyApp(bookProvider: bookProvider));
}

class MyApp extends StatelessWidget {
  final BookProvider bookProvider;
  const MyApp({super.key, required this.bookProvider});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeScreen(bookProvider: bookProvider),
    );
  }
}
