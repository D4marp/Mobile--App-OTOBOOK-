class masterBook {
  final int id;
  final String judul;
  final String pengarang;
  final String penerbitan;
  final String deskripsi;
  final String isbn;
  final String? sinopsis;
  final String? keyword;

  masterBook({
    required this.id,
    required this.judul,
    required this.pengarang,
    required this.penerbitan,
    required this.deskripsi,
    required this.isbn,
    this.sinopsis,
    this.keyword,
  });

  factory masterBook.fromJson(Map<String, dynamic> json) {
    return masterBook(
      id: json['id'] ?? 0,
      judul: json['judul'] ?? 'Unknown Title',
      pengarang: json['pengarang'] ?? 'Unknown Author',
      penerbitan: json['penerbitan'] ?? 'Unknown Publisher',
      deskripsi: json['deskripsi'] ?? 'No description available',
      isbn: json['isbn'] ?? 'Unknown ISBN',
      sinopsis: json['sinopsis'] ?? 'No synopsis available',
      keyword: json['keyword'] ?? 'No keyword available',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'judul': judul,
      'pengarang': pengarang,
      'penerbitan': penerbitan,
      'deskripsi': deskripsi,
      'isbn': isbn,
      'sinopsis': sinopsis,
      'keyword': keyword,
    };
  }
}
