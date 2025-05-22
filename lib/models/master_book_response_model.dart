class masterBook {
  final int id;
  final String judul;
  final String pengarang;
  final String penerbitan;
  final String deskripsi;
  final String isbn;
  final String kota;
  final String tahun;
  final String editor;
  final String? kategori;
  final String? ilustrator;
  final String? sinopsis;
  final String? keyword;
  final String? noClass;

  masterBook({
    required this.id,
    required this.judul,
    required this.pengarang,
    required this.penerbitan,
    required this.deskripsi,
    required this.isbn,
    required this.kota,
    required this.tahun,
    required this.editor,
    this.kategori,
    this.ilustrator,
    this.sinopsis,
    this.keyword,
    this.noClass,
  });

  factory masterBook.fromJson(Map<String, dynamic> json) {
    return masterBook(
      id: json['id'] ?? 0,
      judul: json['judul'] ?? 'Unknown Title',
      pengarang: json['pengarang'] ?? 'Unknown Author',
      penerbitan: json['penerbitan'] ?? 'Unknown Publisher',
      deskripsi: json['deskripsi'] ?? 'No description available',
      isbn: json['isbn'] ?? 'Unknown ISBN',
      kota: json['kota'] ?? 'Unknown City',
      tahun: json['tahun'] ?? 'Unknown Year',
      editor: json['editor'] ?? 'Unknown Editor',
      ilustrator: json['ilustrator'] ?? 'Unknown Illustrator',
      kategori: json['kategori'] ?? 'Unknown Category',
      sinopsis: json['sinopsis'] ?? 'No synopsis available',
      keyword: json['keyword'] ?? 'No keyword available',
      noClass: json['no_class'] ?? 'Unknown Classification Number',
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
      'kota': kota,
      'tahun': tahun,
      'editor': editor,
      'ilustrator': ilustrator,
      'kategori': kategori,
      'sinopsis': sinopsis,
      'keyword': keyword,
      'no_class': noClass,
    };
  }
}
