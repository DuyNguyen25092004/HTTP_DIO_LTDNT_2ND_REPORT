class Book {
  final String id;
  final String title;
  final String author;
  final String year;

  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.year,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['id'].toString(),
      title: json['title'] ?? '',
      author: json['author'] ?? '',
      year: json['year'].toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'author': author,
      'year': year,
    };
  }
}