class Sinopsisbook {
  final int id;
  final String sinopsis;
  final String keyword;
  final int masterBookId;

  Sinopsisbook({
    required this.id,
    required this.sinopsis,
    this.keyword = '',
    required this.masterBookId,
  });
  factory Sinopsisbook.fromJson(Map<String, dynamic> json) {
    return Sinopsisbook(
      id: json['id'] ?? 0,
      sinopsis: json['sinopsis'] ?? 'Unknown Sinopsis',
      keyword: json['keyword'] ?? 'Unknown Keyword',
      masterBookId: json['masterBookId'] ?? 0,
    );
  }
}
