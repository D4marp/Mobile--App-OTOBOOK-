import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:otobook/screen/book/edit_book.dart';
import 'package:otobook/screen/camera/sinopsis_scan.dart';
import 'package:otobook/screen/ip/ip_setting.dart';
import 'package:otobook/services/api.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/master_book_response_model.dart';

class BookdetailPage extends StatefulWidget {
  final int bookId;
  const BookdetailPage({super.key, required this.bookId});

  @override
  State<BookdetailPage> createState() => _BookdetailPageState();
}

class _BookdetailPageState extends State<BookdetailPage> {
  int get bookId => widget.bookId;
  String? rpaResponse;

  Future<String> fetchCoverPath(int masterBukuId) async {
    final response =
        await http.get(Uri.parse('${GetData().getCoverUrl}/$masterBukuId'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);

      return data['path']; // Ambil path dari respon
    } else {
      throw Exception('Failed to load cover');
    }
  }

  Future<void> _getRpaResponse() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? response = prefs.getString('rpa_response_${widget.bookId}');
    setState(() {
      rpaResponse = response; // Simpan pesan respon
    });
  }

  @override
  void initState() {
    super.initState();
    _getRpaResponse(); // Ambil pesan respon saat inisialisasi
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<String>(
        future: fetchCoverPath(widget.bookId),
        builder: (context, snapshot) {
          final coverPath = snapshot.data ?? '';
          final coverUrl =
              coverPath.isNotEmpty ? '${GetData().Url}$coverPath' : '';

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 400.0,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      coverUrl.isNotEmpty
                          ? Image.network(
                              coverUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Image.asset(
                                  'assets/placeholder.jpg',
                                  fit: BoxFit.cover,
                                );
                              },
                            )
                          : Image.asset(
                              'assets/placeholder.jpg',
                              fit: BoxFit.cover,
                            ),
                      const DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.transparent, Colors.black45],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: FutureBuilder<masterBook>(
                  future: GetData.getBookWithSinopsis(widget.bookId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (!snapshot.hasData) {
                      return const Center(child: Text('No data available'));
                    } else {
                      final book = snapshot.data!;
                      return Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              book.judul,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Pengarang: ${book.pengarang}',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.black54,
                              ),
                            ),
                            Text(
                              'Penerbitan: ${book.penerbitan}',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.black54,
                              ),
                            ),
                            Text(
                              'ISBN: ${book.isbn}',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.black54,
                              ),
                            ),
                            Text(
                              'Kota: ${book.kota}',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.black54,
                              ),
                            ),
                            Text(
                              'Tahun Terbit: ${book.tahun}',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.black54,
                              ),
                            ),
                            Text(
                              'Editor: ${book.editor}',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.black54,
                              ),
                            ),
                            Text(
                              'Ilustrator: ${book.ilustrator}',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.black54,
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Deskripsi:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              book.deskripsi,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 16),
                            if (book.sinopsis != null) ...[
                              const Text(
                                'Sinopsis:',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                book.sinopsis!,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                            const SizedBox(height: 8),
                            if (book.keyword != null) ...[
                              const Text(
                                'Keyword:',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                book.keyword!,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                            const SizedBox(height: 8),
                            if (book.noClass != null) ...[
                              const Text(
                                'DeweyNoClass:',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                book.noClass!,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ],
                        ),
                      );
                    }
                  },
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: FutureBuilder<masterBook>(
        future: GetData.getBookWithSinopsis(widget.bookId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('No data available'));
          } else {
            final book = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (book.sinopsis == "No synopsis available") ...[
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                SinopsisScanner(id: widget.bookId),
                          ),
                        ).then((result) {
                          if (result == true) {
                            setState(() {});
                          }
                        });
                      },
                      icon: const Icon(Icons.add_a_photo_rounded),
                      label: const Text('Add Sinopsis'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                        backgroundColor: const Color.fromARGB(255, 37, 198, 1),
                        textStyle: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ] else ...[
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                EditbookPage(id: widget.bookId),
                          ),
                        ).then((result) {
                          if (result == true) {
                            setState(() {});
                          }
                        });
                      },
                      icon: const Icon(Icons.edit, color: Colors.white),
                      label: const Text('Edit Book',
                          style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                        backgroundColor: Colors.blueAccent,
                        textStyle: const TextStyle(fontSize: 16),
                      ),
                    ),
                    if (rpaResponse == null ||
                        rpaResponse!.contains('Error')) ...[
                      // Tombol Add RPA hanya ditampilkan jika rpaResponse null
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  IpSettingsPage(bookId: widget.bookId),
                            ),
                          ).then((result) {
                            if (result != null) {
                              setState(() {
                                rpaResponse = result;
                              });
                              SharedPreferences.getInstance().then((prefs) {
                                prefs.setString(
                                    'rpa_response_${widget.bookId}', result);
                              });
                            }
                          });
                        },
                        icon: const Icon(Icons.arrow_forward_sharp,
                            color: Colors.white),
                        label: const Text('Add RPA',
                            style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                          backgroundColor: Colors.blueAccent,
                          textStyle: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ],
                ],
              ),
            );
          }
        },
      ),
    );
  }
}