import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:otobook/models/master_book_response_model.dart';
import 'package:otobook/screen/book/book_detail.dart';
import 'package:otobook/screen/camera/cover_scan.dart';
import 'package:otobook/services/api.dart';
import 'package:shimmer/shimmer.dart'; // Import shimmer package

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
    setState(() => isLoading = true);
    try {
      final result = await GetData.getBooks();
      setState(() {
        books = result;
        noBooksMessage = books.isEmpty ? 'No books available yet.' : '';
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        noBooksMessage = 'Buku Belum di tambahkan.';
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getBooks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Book List', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
        automaticallyImplyLeading: false,
      ),
      body: isLoading
          ? _buildShimmerEffect() // Tampilkan shimmer saat loading
          : books.isEmpty
              ? Center(child: Text(noBooksMessage, style: const TextStyle(fontSize: 18)))
              : ListView.builder(
                  itemCount: books.length,
                  padding: const EdgeInsets.all(10),
                  itemBuilder: (context, index) {
                    return BookItem(book: books[index], onDelete: getBooks);
                  },
                ),
    );
  }

  Widget _buildShimmerEffect() {
    return ListView.builder(
      itemCount: 5, // Jumlah placeholder shimmer
      padding: const EdgeInsets.all(10),
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey.shade300, // Warna dasar shimmer
          highlightColor: Colors.grey.shade100, // Warna highlight shimmer
          child: Card(
            elevation: 5,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
            child: ListTile(
              contentPadding: const EdgeInsets.all(10),
              leading: Container(
                width: 70,
                height: 100,
                color: Colors.grey.shade300, // Placeholder untuk gambar
              ),
              title: Container(
                width: double.infinity,
                height: 20,
                color: Colors.grey.shade300, // Placeholder untuk judul
              ),
              subtitle: Container(
                width: double.infinity,
                height: 16,
                color: Colors.grey.shade300, // Placeholder untuk pengarang
              ),
              trailing: Container(
                width: 24,
                height: 24,
                color: Colors.grey.shade300, // Placeholder untuk ikon more_vert
              ),
            ),
          ),
        );
      },
    );
  }
}

class BookItem extends StatelessWidget {
  final masterBook book;
  final VoidCallback onDelete;

  const BookItem({required this.book, required this.onDelete});

  Future<String> fetchCoverPath(int masterBukuId) async {
    final response = await http.get(Uri.parse('${GetData().getCoverUrl}/$masterBukuId'));
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return data['path'] ?? '';
    } else {
      throw Exception('Failed to load cover');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      child: ListTile(
        contentPadding: const EdgeInsets.all(10),
        leading: FutureBuilder<String>(
          future: fetchCoverPath(book.id),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Shimmer.fromColors(
                baseColor: Colors.grey.shade300,
                highlightColor: Colors.grey.shade100,
                child: Container(
                  width: 70,
                  height: 100,
                  color: Colors.grey.shade300, // Placeholder untuk gambar
                ),
              );
            } else if (snapshot.hasError || !snapshot.hasData) {
              return Image.asset('assets/placeholder.jpg', width: 70, height: 100, fit: BoxFit.cover);
            } else {
              final coverUrl = '${GetData().Url}${snapshot.data}';
              return ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  coverUrl,
                  width: 70,
                  height: 100,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Image.asset('assets/placeholder.jpg', width: 70, height: 100, fit: BoxFit.cover),
                ),
              );
            }
          },
        ),
        title: Text(book.judul, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        subtitle: Text('Author: ${book.pengarang}', style: const TextStyle(color: Colors.grey)),
        trailing: PopupMenuButton(
          icon: const Icon(Icons.more_vert),
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'cover',
              child: const Text('Add Cover'),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CoverScanner(id: book.id))).then((_) => onDelete()),
            ),
            PopupMenuItem(
              value: 'delete',
              child: const Text('Delete'),
              onTap: () async => await _deleteBook(context, book.id),
            ),
          ],
        ),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => BookdetailPage(bookId: book.id)),
      ),
      ),
    );
    
  }

  Future<void> _deleteBook(BuildContext context, int id) async {
    try {
      final response = await http.delete(Uri.parse("${GetData().deleteBookUrl}/$id"), headers: {'Content-Type': 'application/json'});
      final responseBody = jsonDecode(response.body);
      final message = response.statusCode == 200 ? 'Book deleted successfully' : 'Failed to delete: ${responseBody['message']}';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
      onDelete();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }
}