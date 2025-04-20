import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:otobook/models/master_book_response_model.dart';
import 'package:otobook/services/api.dart';

import 'package:shimmer/shimmer.dart';

class DaftarBukuWidget extends StatefulWidget {
  const DaftarBukuWidget({super.key});

  @override
  State<DaftarBukuWidget> createState() => _DaftarBukuWidgetState();
}

class _DaftarBukuWidgetState extends State<DaftarBukuWidget> {
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Text(
            'Daftar Buku',
            style: TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(
          height: 220,
          child: isLoading
              ? _buildShimmerEffect()
              : books.isEmpty
                  ? Center(
                      child: Text(
                        noBooksMessage,
                        style: const TextStyle(fontSize: 16),
                      ),
                    )
                  : ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: books.length,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemBuilder: (context, index) {
                        return BookCard(book: books[index]);
                      },
                    ),
        ),
      ],
    );
  }

  Widget _buildShimmerEffect() {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: 5,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Container(
            width: 120,
            margin: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      },
    );
  }
}

class BookCard extends StatelessWidget {
  final masterBook book;
  const BookCard({required this.book, Key? key}) : super(key: key);

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
    return Container(
      width: 120,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FutureBuilder<String>(
            future: fetchCoverPath(book.id),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Shimmer.fromColors(
                  baseColor: Colors.grey.shade300,
                  highlightColor: Colors.grey.shade100,
                  child: Container(
                    width: 120,
                    height: 150,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                );
              } else if (snapshot.hasError || !snapshot.hasData) {
                return Container(
                  width: 120,
                  height: 150,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.broken_image, color: Colors.grey.shade400),
                );
              } else {
                final coverUrl = '${GetData().Url}${snapshot.data}';
                return ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    coverUrl,
                    width: 120,
                    height: 150,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 120,
                      height: 150,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.broken_image, color: Colors.grey.shade400),
                    ),
                  ),
                );
              }
            },
          ),
          const SizedBox(height: 8),
          Text(
            book.judul,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}