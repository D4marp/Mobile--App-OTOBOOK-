import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:otobook/models/master_book_response_model.dart';
import 'package:otobook/screen/book/book_detail.dart';
import 'package:otobook/screen/camera/cover_scan.dart';
import 'package:otobook/services/api.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:shimmer/shimmer.dart'; // Import shimmer package

enum BookFilter { all, diproses, disumbangkan }

class GetBooksPage extends StatefulWidget {
  const GetBooksPage({super.key});

  @override
  State<GetBooksPage> createState() => _GetBooksPageState();
}

class _GetBooksPageState extends State<GetBooksPage> {
  bool isLoading = false;
  List<masterBook> books = [];
  String noBooksMessage = '';
  BookFilter _selectedFilter = BookFilter.all;

  void getBooks() async {
    setState(() {
      isLoading = true;
    });

    try {
      final result = await GetData.getBooks();
      setState(() {
        books = result;
        if (books.isEmpty) {
          noBooksMessage = 'You have not added any books yet.';
        } else {
          noBooksMessage = ''; // Reset the message if books are available
        }
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        books = [];
        noBooksMessage = 'Buku belum tersedia';
        isLoading = false;
      });
    }
  }

  // getBooks di proses
  void getBooksProses() async {
    setState(() {
      isLoading = true;
    });

    try {
      final result = await GetData.getBooksProses();
      setState(() {
        books = result;
        if (books.isEmpty) {
          noBooksMessage = 'You have not added any books yet.';
        } else {
          noBooksMessage = ''; // Reset the message if books are available
        }
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        books = [];
        noBooksMessage = 'Buku belum tersedia';
        isLoading = false;
      });
    }
  }

  // getBooks di disumbangkan
  void getBooksDisumbangkan() async {
    setState(() {
      isLoading = true;
    });

    try {
      final result = await GetData.getBooksDisumbangkan();
      setState(() {
        books = result;
        if (books.isEmpty) {
          noBooksMessage = 'You have not added any books yet.';
        } else {
          noBooksMessage = ''; // Reset the message if books are available
        }
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        books = [];
        noBooksMessage = 'Buku belum tersedia';
        isLoading = false;
      });
    }
  }

  Future<void> _downloadExcel() async {
    setState(() {
      isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('id');

      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User ID tidak ditemukan')),
        );
        return;
      }

      final url = Uri.parse("${GetData().downloadExcelUrl}?userId=$userId");

      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final bytes = response.bodyBytes;
        final directory =
            await getApplicationDocumentsDirectory(); // Untuk Android/iOS
        final filePath = '${directory.path}/books.xlsx';
        final file = File(filePath);

        await file.writeAsBytes(bytes);

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Excel berhasil diunduh')));

        await OpenFile.open(file.path); // Buka file setelah download
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal unduh Excel: ${response.body}')),
        );
      }
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Terjadi kesalahan: $e')));
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _onFilterChanged(BookFilter? value) {
    if (value == null) return;

    setState(() {
      _selectedFilter = value;
      if (_selectedFilter == BookFilter.all) {
        getBooks();
      } else if (_selectedFilter == BookFilter.diproses) {
        getBooksProses();
      } else if (_selectedFilter == BookFilter.disumbangkan) {
        getBooksDisumbangkan();
      }
    });
  }

  @override
  void initState() {
    getBooks();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text('Daftar Buku'),
            const SizedBox(width: 8),
            PopupMenuButton<BookFilter>(
              initialValue: _selectedFilter,
              onSelected: _onFilterChanged,
              icon: const Icon(Icons.filter_list),
              itemBuilder:
                  (context) => [
                    const PopupMenuItem(
                      value: BookFilter.all,
                      child: Text('Semua'),
                    ),
                    const PopupMenuItem(
                      value: BookFilter.diproses,
                      child: Text('Diolah'),
                    ),
                    const PopupMenuItem(
                      value: BookFilter.disumbangkan,
                      child: Text('Disumbangkan'),
                    ),
                  ],
            ),
          ],
        ),
        actions:
            _selectedFilter == BookFilter.disumbangkan
                ? [
                  IconButton(
                    icon: const Icon(Icons.download),
                    onPressed: _downloadExcel,
                    tooltip: 'Download Excel',
                  ),
                ]
                : null,
        automaticallyImplyLeading: false,
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : books.isEmpty
              ? Center(
                child: Text(
                  noBooksMessage.isNotEmpty
                      ? noBooksMessage
                      : 'No books available',
                ),
              )
              : ListView.builder(
                itemCount: books.length,
                itemBuilder: (context, index) {
                  return BookItem(
                    book: books[index],
                    onDelete: () {
                      getBooks();
                    },
                  );
                },
              ),
    );
  }
}

class BookItem extends StatelessWidget {
  final masterBook book;
  final VoidCallback onDelete;

  const BookItem({required this.book, required this.onDelete});

  Future<Map<String, dynamic>> _deleteBook(BuildContext context, int id) async {
    Uri url = Uri.parse("${GetData().deleteBookUrl}/$id");

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

  Future<String> fetchCoverPath(int masterBukuId) async {
    final response = await http.get(
      Uri.parse('${GetData().getCoverUrl}/$masterBukuId'),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return data['path']; // Ambil path dari respon
    } else {
      throw Exception('Failed to load cover');
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BookdetailPage(bookId: book.id),
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
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Image.asset(
                      'assets/placeholder.jpg', // Gambar placeholder dari assets
                      width: 100,
                      height: 150,
                      fit: BoxFit.cover,
                    );
                  } else if (!snapshot.hasData || snapshot.data == null) {
                    return Image.asset(
                      'assets/placeholder.jpg', // Gambar placeholder dari assets
                      width: 100,
                      height: 150,
                      fit: BoxFit.cover,
                    );
                  } else {
                    final coverPath = snapshot.data!;
                    final coverUrl = '${GetData().Url}$coverPath';
                    return Image.network(
                      coverUrl,
                      width: 100,
                      height: 150,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Image.asset(
                          'assets/placeholder.jpg', // Gambar placeholder dari assets
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
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                    builder: (BuildContext context) {
                      return Wrap(
                        children: <Widget>[
                          ListTile(
                            leading: const Icon(Icons.image),
                            title: const Text('Add Cover'),
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => CoverScanner(id: book.id),
                                ),
                              ).then((result) {
                                if (result == true) {
                                  onDelete(); // Refresh the book list when a cover is added
                                }
                              });
                            },
                          ),
                          ListTile(
                            leading: const Icon(Icons.delete),
                            title: const Text('Delete'),
                            onTap: () async {
                              Navigator.pop(
                                context,
                              ); // Close the bottom sheet first
                              await _deleteBook(context, book.id);
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
  }
}
