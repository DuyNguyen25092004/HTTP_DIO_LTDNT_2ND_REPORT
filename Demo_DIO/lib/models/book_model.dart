class BookModel {
  final String id;
  final String title;
  final String author;
  final String year;

  BookModel({
    required this.id,
    required this.title,
    required this.author,
    required this.year,
  });

  factory BookModel.fromJson(Map<String, dynamic> json) {
    return BookModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      author: json['author'] ?? '',
      year: json['year'] ?? '',
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
