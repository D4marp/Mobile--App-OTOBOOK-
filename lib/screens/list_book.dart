import 'dart:convert';
import 'package:Otobook/models/masterBook.dart';
import 'package:Otobook/screens/bookDetail_page.dart';
import 'package:Otobook/screens/cover_scan.dart';
import 'package:Otobook/services/api.dart';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;

class GetBooksPage extends StatefulWidget {
  const GetBooksPage({super.key});

  @override
  State<GetBooksPage> createState() => _GetBooksPageState();
}

class _GetBooksPageState extends State<GetBooksPage> {
  bool isLoading = false;
  List<masterBook> books = [];
  String noBooksMessage = '';

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
        noBooksMessage = 'Buku belum tersedia';
        isLoading = false;
      });
    }
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
        title: const Text('Book List'),
        automaticallyImplyLeading: false,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : books.isEmpty
              ? Center(
                  child: Text(noBooksMessage.isNotEmpty
                      ? noBooksMessage
                      : 'No books available'))
              : ListView.builder(
                  itemCount: books.length,
                  itemBuilder: (context, index) {
                    return BookItem(
                      book: books[index],
                      onDelete: () {
                        getBooks(); // Refresh the book list when a book is deleted
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

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BookdetailPage(
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
                                  builder: (context) =>
                                      CoverScanner(id: book.id),
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
                                  context); // Close the bottom sheet first
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
