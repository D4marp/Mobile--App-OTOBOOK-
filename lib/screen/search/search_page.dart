import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:otobook/models/master_book_response_model.dart';
import 'package:otobook/screen/book/book_search.dart';
import 'package:otobook/screen/camera/cover_scan.dart';
import 'package:otobook/services/api.dart';

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
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(<String, String>{'keyword': keyword}),
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
    final response = await http.get(
      Uri.parse('${GetData().getCoverUrl}/$masterBukuId'),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return data['path'];
    } else {
      throw Exception('Failed to load cover');
    }
  }

  Future<Map<String, dynamic>> _deleteBook(BuildContext context, int id) async {
    Uri url = Uri.parse(GetData().deleteBookUrl + id.toString());

    try {
      final response = await http.delete(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      final responseBody = jsonDecode(response.body);

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Book deleted successfully')),
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error occurred: $e')));
      return {'message': 'Error occurred: $e'};
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cari Buku'),
        backgroundColor: Colors.blueAccent,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cari buku...',
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
                ? Text(_errorMessage, style: const TextStyle(color: Colors.red))
                : _books.isEmpty
                ? const Text(
                  'Tidak ada buku ditemukan.',
                  style: TextStyle(fontSize: 16),
                )
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
                              builder: (context) => Booksearch(bookId: book.id),
                            ),
                          );
                        },
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          margin: const EdgeInsets.symmetric(
                            vertical: 10.0,
                            horizontal: 5.0,
                          ),
                          elevation: 5,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              children: [
                                FutureBuilder<String>(
                                  future: fetchCoverPath(book.id),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return const SizedBox(
                                        width: 100,
                                        height: 150,
                                        child: Center(
                                          child: CircularProgressIndicator(),
                                        ),
                                      );
                                    } else if (snapshot.hasError ||
                                        !snapshot.hasData) {
                                      return Image.asset(
                                        'assets/placeholder.jpg',
                                        width: 100,
                                        height: 150,
                                        fit: BoxFit.cover,
                                      );
                                    } else {
                                      final coverUrl =
                                          '${GetData().Url}${snapshot.data!}';
                                      return ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: Image.network(
                                          coverUrl,
                                          width: 100,
                                          height: 150,
                                          fit: BoxFit.cover,
                                        ),
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
                                  icon: const Icon(
                                    Icons.more_vert,
                                    color: Colors.blueAccent,
                                  ),
                                  onPressed: () {
                                    showModalBottomSheet(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return Wrap(
                                          children: <Widget>[
                                            ListTile(
                                              leading: const Icon(
                                                Icons.image,
                                                color: Colors.teal,
                                              ),
                                              title: const Text('Add Cover'),
                                              onTap: () {
                                                Navigator.pop(context);
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder:
                                                        (context) =>
                                                            CoverScanner(
                                                              id: book.id,
                                                            ),
                                                  ),
                                                ).then((result) {
                                                  if (result == true) {
                                                    setState(() {
                                                      _onSearch(
                                                        _searchController.text,
                                                      );
                                                    });
                                                  }
                                                });
                                              },
                                            ),
                                            ListTile(
                                              leading: const Icon(
                                                Icons.delete,
                                                color: Colors.red,
                                              ),
                                              title: const Text('Delete'),
                                              onTap: () async {
                                                Navigator.pop(context);
                                                await _deleteBook(
                                                  context,
                                                  book.id,
                                                );
                                                setState(() {
                                                  _onSearch(
                                                    _searchController.text,
                                                  );
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
