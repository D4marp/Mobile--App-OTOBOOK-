import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:otobook/models/klasifikasi_response_model.dart';
import 'package:otobook/screen/book/edit_klasifikasi_buku.dart';
import 'package:otobook/services/api.dart';

import 'tajuk_subject.dart';

class Klasifikasibuku extends StatefulWidget {
  const Klasifikasibuku({super.key});

  @override
  State<Klasifikasibuku> createState() => _KlasifikasibukuState();
}

class _KlasifikasibukuState extends State<Klasifikasibuku> {
  final TextEditingController _searchController = TextEditingController();
  List<Klasifikasi> _books = [];
  bool _isLoading = false;
  String _errorMessage = '';

  Future<void> _onSearch(String keyword) async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    try {
      Uri url = Uri.parse(GetData().searchKlasifikasiUrl);
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(<String, String>{
          'keyword': keyword,
        }),
      );
      if (response.statusCode == 200) {
        final body = response.body;
        final result = jsonDecode(body);

        if (result['data'] != null) {
          setState(() {
            _books = List<Klasifikasi>.from(
              result['data'].map((i) => Klasifikasi.fromJson(i)),
            );
          });
        } else {
          setState(() {
            _errorMessage = 'Data tidak ditemukan.';
          });
        }
      } else {
        setState(() {
          _errorMessage =
              'Gagal mencari Klasifikasi. Status code: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error fetching books: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Klasifikasi Buku'),
        backgroundColor: Colors.blueAccent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cari Klasifikasi...',
                prefixIcon: const Icon(Icons.search, color: Colors.teal),
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15.0),
                  borderSide: BorderSide.none,
                ),
              ),
              onSubmitted: _onSearch,
            ),
            const SizedBox(height: 20),
            _isLoading
                ? const CircularProgressIndicator.adaptive()
                : _errorMessage.isNotEmpty
                    ? Text(_errorMessage,
                        style: const TextStyle(color: Colors.red))
                    : _books.isEmpty
                        ? const Text('Tidak ada buku ditemukan.',
                            style: TextStyle(fontSize: 16))
                        : Expanded(
                            child: ListView.builder(
                              itemCount: _books.length,
                              itemBuilder: (context, index) {
                                final book = _books[index]; // Objek Klasifikasi
                                return Card(
                                  child: ListTile(
                                    title: Text(
                                        'Dewey No: ${book.deweyNoClass}'), // Menampilkan deweyNoClass
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                            'Uraian Klasifikasi: ${book.narasiKlasifikasi}'), // Menampilkan narasi_klasifikasi
                                        Text(
                                            'Subject: ${book.subject ?? 'Tidak ada subject'}'), // Menampilkan subject atau pesan default
                                      ],
                                    ),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => Editklasifikasibuku(
                                              klasifikasiId: book
                                                  .id), // Halaman untuk mengedit klasifikasi
                                        ),
                                      );
                                    },
                                  ),
                                );
                              },
                            ),
                          )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigasi ke halaman untuk menambah tajuk subjek
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  TajukSubject(), // Halaman untuk menambah tajuk subjek
            ),
          );
        },
        child: const Icon(Icons.add),
        backgroundColor: Colors.blueAccent,
        tooltip: 'Tambah Tajuk Subjek',
      ),
    );
  }
}
