import 'dart:convert';

import 'package:Otobook/models/masterBook.dart';
import 'package:Otobook/screens/bookSearch.dart';
import 'package:Otobook/screens/cover_scan.dart';
import 'package:Otobook/services/api.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  late final VoidCallback onDelete;
  List<masterBook> _books = [];
  bool _isLoading = false;
  String _errorMessage = '';

  Future<void> _onSearch(String keyword) async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    try {
      Uri url = Uri.parse(GetData().searchBookUrl);
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
            _books = List<masterBook>.from(
              result['data'].map((i) => masterBook.fromJson(i)),
            );
          });
          // print('Data ditemukan: ${result['data']}');
        } else {
          setState(() {
            _errorMessage = 'Data tidak ditemukan.';
          });
        }
      } else {
        setState(() {
          _errorMessage =
              'Gagal mencari buku. Status code: ${response.statusCode}';
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

  Future<Map<String, dynamic>> _deleteBook(BuildContext context, int id) async {
    Uri url = Uri.parse(GetData().deleteBookUrl + id.toString());

    try {
      final response = await http.delete(url, headers: {
        'Content-Type': 'application/json',
      });

      final responseBody = jsonDecode(response.body);

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Book deleted successfully'),
          ),
        );
        onDelete();
        return responseBody;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete book: ${responseBody['message']}'),
          ),
        );
        return responseBody;
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error occurred: $e'),
        ),
      );
      return {
        'message': 'Error occurred: $e',
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Form'),
        automaticallyImplyLeading: false,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cari sesuatu...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              onSubmitted: _onSearch,
            ),
            const SizedBox(height: 20),
            _isLoading
                ? const CircularProgressIndicator()
                : _errorMessage.isNotEmpty
                    ? Text(_errorMessage, style: TextStyle(color: Colors.red))
                    : _books.isEmpty
                        ? const Text('Tidak ada buku ditemukan.')
                        : Expanded(
                            child: ListView.builder(
                              itemCount: _books.length,
                              itemBuilder: (context, index) {
                                final book = _books[index];
                                return GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => Booksearch(
                                          bookId: book.id,
                                        ),
                                      ),
                                    );
                                  },
                                  child: Card(
                                    margin: const EdgeInsets.all(8.0),
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Row(
                                        children: [
                                          FutureBuilder<String>(
                                            future: fetchCoverPath(book.id),
                                            builder: (context, snapshot) {
                                              if (snapshot.connectionState ==
                                                  ConnectionState.waiting) {
                                                return const CircularProgressIndicator();
                                              } else if (snapshot.hasError) {
                                                return Image.asset(
                                                  'assets/placeholder.jpg',
                                                  width: 100,
                                                  height: 150,
                                                  fit: BoxFit.cover,
                                                );
                                              } else if (!snapshot.hasData ||
                                                  snapshot.data == null) {
                                                return Image.asset(
                                                  'assets/placeholder.jpg',
                                                  width: 100,
                                                  height: 150,
                                                  fit: BoxFit.cover,
                                                );
                                              } else {
                                                final coverPath =
                                                    snapshot.data!;
                                                final coverUrl =
                                                    '${GetData().Url}$coverPath';
                                                return Image.network(
                                                  coverUrl,
                                                  width: 100,
                                                  height: 150,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (context, error,
                                                      stackTrace) {
                                                    return Image.asset(
                                                      'assets/placeholder.jpg',
                                                      width: 100,
                                                      height: 150,
                                                      fit: BoxFit.cover,
                                                    );
                                                  },
                                                );
                                              }
                                            },
                                          ),
                                          const SizedBox(width: 16),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  book.judul,
                                                  style: const TextStyle(
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.bold,
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
                                              ],
                                            ),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.more_vert),
                                            onPressed: () {
                                              showModalBottomSheet(
                                                context: context,
                                                builder:
                                                    (BuildContext context) {
                                                  return Wrap(
                                                    children: <Widget>[
                                                      ListTile(
                                                        leading: const Icon(
                                                            Icons.image),
                                                        title: const Text(
                                                            'Add Cover'),
                                                        onTap: () {
                                                          Navigator.pop(
                                                              context);
                                                          Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                              builder: (context) =>
                                                                  CoverScanner(
                                                                      id: book
                                                                          .id),
                                                            ),
                                                          ).then((result) {
                                                            if (result ==
                                                                true) {
                                                              // Refresh the book list when a cover is added
                                                              setState(() {
                                                                _onSearch(
                                                                    _searchController
                                                                        .text);
                                                              });
                                                            }
                                                          });
                                                        },
                                                      ),
                                                      ListTile(
                                                        leading: const Icon(
                                                            Icons.delete),
                                                        title: const Text(
                                                            'Delete'),
                                                        onTap: () async {
                                                          Navigator.pop(
                                                              context);
                                                          await _deleteBook(
                                                              context, book.id);
                                                          // Refresh the book list after deletion
                                                          setState(() {
                                                            _onSearch(
                                                                _searchController
                                                                    .text);
                                                          });
                                                        },
                                                      ),
                                                    ],
                                                  );
                                                },
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
          ],
        ),
      ),
    );
  }
}
