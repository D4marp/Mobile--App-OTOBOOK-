class Book {
  final String id;
  final String title;
  final String author;
  final String publisher;
  final int publicationYear;
  final String ISBN;
  String synopsis;
  List<String> keywords;
  String coverImagePath;
  String daftarIsiImagePath; // New field for table of contents image path

  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.publisher,
    required this.publicationYear,
    required this.ISBN,
    this.synopsis = '',
    this.keywords = const [],
    this.coverImagePath = '',
    this.daftarIsiImagePath = '', // Initialize the new field
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
      'coverImagePath': coverImagePath,
      'daftarIsiImagePath': daftarIsiImagePath, // Include the new field
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
      coverImagePath: map['coverImagePath'] ?? '',
      daftarIsiImagePath: map['daftarIsiImagePath'] ?? '', // Read the new field
    );
  }
}
