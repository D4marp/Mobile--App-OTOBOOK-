class Book {
  final String id;
  final String title;
  final String author;
  final String publisher;
  final int publicationYear;
  final String ISBN;
  String synopsis;
  List<String> keywords;

  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.publisher,
    required this.publicationYear,
    required this.ISBN,
    this.synopsis = '',
    this.keywords = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'publisher': publisher,
      'publicationYear': publicationYear,
      'ISBN': ISBN,
      'synopsis': synopsis,
      'keywords': keywords,
    };
  }

  factory Book.fromMap(Map<String, dynamic> map) {
    return Book(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      author: map['author'] ?? '',
      publisher: map['publisher'] ?? '',
      publicationYear: map['publicationYear'] ?? 0,
      ISBN: map['ISBN'] ?? '',
      synopsis: map['synopsis'] ?? '',
      keywords: List<String>.from(map['keywords'] ?? []),
    );
  }
}
