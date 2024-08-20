class Book {
  final String id;
  final String nomorKendali; // Sesuaikan dengan JSON
  final String controlNoId; // Sesuaikan dengan JSON
  final DateTime tanggalDanJamPemakaianTerakhir; // Sesuaikan dengan JSON
  final String karakteristikBahanSertaan; // Sesuaikan dengan JSON
  final String entriUtamaJudulSeragam; // Sesuaikan dengan JSON
  final String issn; // Sesuaikan dengan JSON
  final String judulDisingkat; // Sesuaikan dengan JSON
  final String judulKunci; // Sesuaikan dengan JSON
  final String frekuensiPublikasiMutakhir; // Sesuaikan dengan JSON
  final String frekuensiPublikasiSebelumnya; // Sesuaikan dengan JSON
  final String mediumFisik; // Sesuaikan dengan JSON
  final String dataReferensiGeospasial; // Sesuaikan dengan JSON
  final String dataKoordinatPlanar; // Sesuaikan dengan JSON
  final String representasiGrafisDigital; // Sesuaikan dengan JSON
  final String tahunPenerbitanDanPenandaUrutan; // Sesuaikan dengan JSON
  final String pembatasanAkses; // Sesuaikan dengan JSON
  final String aksesRincianSistem; // Sesuaikan dengan JSON
  final String entriPendahulu; // Sesuaikan dengan JSON
  final String aksesDanLokasiElektronik; // Sesuaikan dengan JSON
  final String catatanKetersediaanBentukFisikTambahan; // Sesuaikan dengan JSON
  final String catatanRincianSistem; // Sesuaikan dengan JSON
  final String entriLanjutan; // Sesuaikan dengan JSON
  final String entriTambahanNamaPertemuan; // Sesuaikan dengan JSON
  final String nomor; // Sesuaikan dengan JSON
  final String nomorPanggilLibraryOfCongress; // Sesuaikan dengan JSON
  final String variasiBentukJudul; // Sesuaikan dengan JSON
  final String judulSebelumnya; // Sesuaikan dengan JSON
  final String ruasTetapDeskripsiFisik; // Sesuaikan dengan JSON
  final String unsurDataPanjangTetap; // Sesuaikan dengan JSON
  final String nomorBNI; // Sesuaikan dengan JSON
  final String isbn; // Sesuaikan dengan JSON
  final String bibId; // Sesuaikan dengan JSON
  final String sumberPengkatalogan; // Sesuaikan dengan JSON
  final String kodeBahasa; // Sesuaikan dengan JSON
  final String kodeWilayah; // Sesuaikan dengan JSON
  final String nomorPanggilDDC; // Sesuaikan dengan JSON
  final String nomorKlasifikasiLainnya; // Sesuaikan dengan JSON
  final String nomorPanggilLokal; // Sesuaikan dengan JSON
  final String entriUtamaNamaOrang; // Sesuaikan dengan JSON
  final String entriUtamaNamaBadanKorporasi; // Sesuaikan dengan JSON
  final String entriUtamaNamaPertemuan; // Sesuaikan dengan JSON
  final String judulSeragam; // Sesuaikan dengan JSON
  final String terjemahanJudul; // Sesuaikan dengan JSON
  final String judulSeragamKolektif; // Sesuaikan dengan JSON
  final String pernyataanJudul; // Sesuaikan dengan JSON
  final String pernyataanEdisi; // Sesuaikan dengan JSON

  // Optional fields
  String synopsis;
  List<String> keywords;
  String coverImagePath;
  String daftarIsiImagePath;

  Book({
    required this.id,
    required this.nomorKendali,
    required this.controlNoId,
    required this.tanggalDanJamPemakaianTerakhir,
    required this.karakteristikBahanSertaan,
    required this.entriUtamaJudulSeragam,
    required this.issn,
    required this.judulDisingkat,
    required this.judulKunci,
    required this.frekuensiPublikasiMutakhir,
    required this.frekuensiPublikasiSebelumnya,
    required this.mediumFisik,
    required this.dataReferensiGeospasial,
    required this.dataKoordinatPlanar,
    required this.representasiGrafisDigital,
    required this.tahunPenerbitanDanPenandaUrutan,
    required this.pembatasanAkses,
    required this.aksesRincianSistem,
    required this.entriPendahulu,
    required this.aksesDanLokasiElektronik,
    required this.catatanKetersediaanBentukFisikTambahan,
    required this.catatanRincianSistem,
    required this.entriLanjutan,
    required this.entriTambahanNamaPertemuan,
    required this.nomor,
    required this.nomorPanggilLibraryOfCongress,
    required this.variasiBentukJudul,
    required this.judulSebelumnya,
    required this.ruasTetapDeskripsiFisik,
    required this.unsurDataPanjangTetap,
    required this.nomorBNI,
    required this.isbn,
    required this.bibId,
    required this.sumberPengkatalogan,
    required this.kodeBahasa,
    required this.kodeWilayah,
    required this.nomorPanggilDDC,
    required this.nomorKlasifikasiLainnya,
    required this.nomorPanggilLokal,
    required this.entriUtamaNamaOrang,
    required this.entriUtamaNamaBadanKorporasi,
    required this.entriUtamaNamaPertemuan,
    required this.judulSeragam,
    required this.terjemahanJudul,
    required this.judulSeragamKolektif,
    required this.pernyataanJudul,
    required this.pernyataanEdisi,
    this.synopsis = '',
    this.keywords = const [],
    this.coverImagePath = '',
    this.daftarIsiImagePath = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nomorKendali': nomorKendali,
      'controlNoId': controlNoId,
      'tanggalDanJamPemakaianTerakhir': tanggalDanJamPemakaianTerakhir.toIso8601String(),
      'karakteristikBahanSertaan': karakteristikBahanSertaan,
      'entriUtamaJudulSeragam': entriUtamaJudulSeragam,
      'issn': issn,
      'judulDisingkat': judulDisingkat,
      'judulKunci': judulKunci,
      'frekuensiPublikasiMutakhir': frekuensiPublikasiMutakhir,
      'frekuensiPublikasiSebelumnya': frekuensiPublikasiSebelumnya,
      'mediumFisik': mediumFisik,
      'dataReferensiGeospasial': dataReferensiGeospasial,
      'dataKoordinatPlanar': dataKoordinatPlanar,
      'representasiGrafisDigital': representasiGrafisDigital,
      'tahunPenerbitanDanPenandaUrutan': tahunPenerbitanDanPenandaUrutan,
      'pembatasanAkses': pembatasanAkses,
      'aksesRincianSistem': aksesRincianSistem,
      'entriPendahulu': entriPendahulu,
      'aksesDanLokasiElektronik': aksesDanLokasiElektronik,
      'catatanKetersediaanBentukFisikTambahan': catatanKetersediaanBentukFisikTambahan,
      'catatanRincianSistem': catatanRincianSistem,
      'entriLanjutan': entriLanjutan,
      'entriTambahanNamaPertemuan': entriTambahanNamaPertemuan,
      'nomor': nomor,
      'nomorPanggilLibraryOfCongress': nomorPanggilLibraryOfCongress,
      'variasiBentukJudul': variasiBentukJudul,
      'judulSebelumnya': judulSebelumnya,
      'ruasTetapDeskripsiFisik': ruasTetapDeskripsiFisik,
      'unsurDataPanjangTetap': unsurDataPanjangTetap,
      'nomorBNI': nomorBNI,
      'isbn': isbn,
      'bibId': bibId,
      'sumberPengkatalogan': sumberPengkatalogan,
      'kodeBahasa': kodeBahasa,
      'kodeWilayah': kodeWilayah,
      'nomorPanggilDDC': nomorPanggilDDC,
      'nomorKlasifikasiLainnya': nomorKlasifikasiLainnya,
      'nomorPanggilLokal': nomorPanggilLokal,
      'entriUtamaNamaOrang': entriUtamaNamaOrang,
      'entriUtamaNamaBadanKorporasi': entriUtamaNamaBadanKorporasi,
      'entriUtamaNamaPertemuan': entriUtamaNamaPertemuan,
      'judulSeragam': judulSeragam,
      'terjemahanJudul': terjemahanJudul,
      'judulSeragamKolektif': judulSeragamKolektif,
      'pernyataanJudul': pernyataanJudul,
      'pernyataanEdisi': pernyataanEdisi,
      'synopsis': synopsis,
      'keywords': keywords,
      'coverImagePath': coverImagePath,
      'daftarIsiImagePath': daftarIsiImagePath,
    };
  }

  factory Book.fromMap(Map<String, dynamic> map) {
    return Book(
      id: map['id'] ?? '',
      nomorKendali: map['nomorKendali'] ?? '',
      controlNoId: map['controlNoId'] ?? '',
      tanggalDanJamPemakaianTerakhir: DateTime.parse(map['tanggalDanJamPemakaianTerakhir'] ?? DateTime.now().toIso8601String()),
      karakteristikBahanSertaan: map['karakteristikBahanSertaan'] ?? '',
      entriUtamaJudulSeragam: map['entriUtamaJudulSeragam'] ?? '',
      issn: map['issn'] ?? '',
      judulDisingkat: map['judulDisingkat'] ?? '',
      judulKunci: map['judulKunci'] ?? '',
      frekuensiPublikasiMutakhir: map['frekuensiPublikasiMutakhir'] ?? '',
      frekuensiPublikasiSebelumnya: map['frekuensiPublikasiSebelumnya'] ?? '',
      mediumFisik: map['mediumFisik'] ?? '',
      dataReferensiGeospasial: map['dataReferensiGeospasial'] ?? '',
      dataKoordinatPlanar: map['dataKoordinatPlanar'] ?? '',
      representasiGrafisDigital: map['representasiGrafisDigital'] ?? '',
      tahunPenerbitanDanPenandaUrutan: map['tahunPenerbitanDanPenandaUrutan'] ?? '',
      pembatasanAkses: map['pembatasanAkses'] ?? '',
      aksesRincianSistem: map['aksesRincianSistem'] ?? '',
      entriPendahulu: map['entriPendahulu'] ?? '',
      aksesDanLokasiElektronik: map['aksesDanLokasiElektronik'] ?? '',
      catatanKetersediaanBentukFisikTambahan: map['catatanKetersediaanBentukFisikTambahan'] ?? '',
      catatanRincianSistem: map['catatanRincianSistem'] ?? '',
      entriLanjutan: map['entriLanjutan'] ?? '',
      entriTambahanNamaPertemuan: map['entriTambahanNamaPertemuan'] ?? '',
      nomor: map['nomor'] ?? '',
      nomorPanggilLibraryOfCongress: map['nomorPanggilLibraryOfCongress'] ?? '',
      variasiBentukJudul: map['variasiBentukJudul'] ?? '',
      judulSebelumnya: map['judulSebelumnya'] ?? '',
      ruasTetapDeskripsiFisik: map['ruasTetapDeskripsiFisik'] ?? '',
      unsurDataPanjangTetap: map['unsurDataPanjangTetap'] ?? '',
      nomorBNI: map['nomorBNI'] ?? '',
      isbn: map['isbn'] ?? '',
      bibId: map['bibId'] ?? '',
      sumberPengkatalogan: map['sumberPengkatalogan'] ?? '',
      kodeBahasa: map['kodeBahasa'] ?? '',
      kodeWilayah: map['kodeWilayah'] ?? '',
      nomorPanggilDDC: map['nomorPanggilDDC'] ?? '',
      nomorKlasifikasiLainnya: map['nomorKlasifikasiLainnya'] ?? '',
      nomorPanggilLokal: map['nomorPanggilLokal'] ?? '',
      entriUtamaNamaOrang: map['entriUtamaNamaOrang'] ?? '',
      entriUtamaNamaBadanKorporasi: map['entriUtamaNamaBadanKorporasi'] ?? '',
      entriUtamaNamaPertemuan: map['entriUtamaNamaPertemuan'] ?? '',
      judulSeragam: map['judulSeragam'] ?? '',
      terjemahanJudul: map['terjemahanJudul'] ?? '',
      judulSeragamKolektif: map['judulSeragamKolektif'] ?? '',
      pernyataanJudul: map['pernyataanJudul'] ?? '',
      pernyataanEdisi: map['pernyataanEdisi'] ?? '',
      synopsis: map['synopsis'] ?? '',
      keywords: List<String>.from(map['keywords'] ?? []),
      coverImagePath: map['coverImagePath'] ?? '',
      daftarIsiImagePath: map['daftarIsiImagePath'] ?? '',
    );
  }
}
