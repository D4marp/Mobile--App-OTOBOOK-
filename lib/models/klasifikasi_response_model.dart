class Klasifikasi {
  final int id;
  final String deweyNoClass;
  final String? subject;
  final String? narasiKlasifikasi;

  Klasifikasi({
    required this.id,
    required this.deweyNoClass,
    this.subject,
    this.narasiKlasifikasi,
  });
  factory Klasifikasi.fromJson(Map<String, dynamic> json) {
    return Klasifikasi(
      id: json['id'] ?? 0,
      deweyNoClass: json['deweyNoClass'] ?? 'Unknown Dewey No Class',
      subject: json['subject'] ?? '',
      narasiKlasifikasi:
          json['narasi_klasifikasi'] ?? '',
    );
  }
}
