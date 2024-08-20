import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:otobook/models/masterBook.dart'; // Ensure this import is correct

class EditbookPage extends StatefulWidget {
  final int id;

  const EditbookPage({super.key, required this.id});

  @override
  State<EditbookPage> createState() => _EditbookPageState();
}

class _EditbookPageState extends State<EditbookPage> {
  late TextEditingController _judulController;
  late TextEditingController _pengarangController;
  late TextEditingController _penerbitanController;
  late TextEditingController _deskripsiController;
  late TextEditingController _isbnController;
  late TextEditingController _sinopsisController;
  late TextEditingController _keywordController;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _judulController = TextEditingController();
    _pengarangController = TextEditingController();
    _penerbitanController = TextEditingController();
    _deskripsiController = TextEditingController();
    _isbnController = TextEditingController();
    _sinopsisController = TextEditingController();
    _keywordController = TextEditingController();

    _fetchBookDetails();
  }

  Future<void> _fetchBookDetails() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final response = await http.get(Uri.parse(
          'http://192.168.9.63:5000/api/getBookSinopsis/${widget.id}'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final book =
            masterBook.fromJson(data); // Ensure this is the correct class
        _judulController.text = book.judul;
        _pengarangController.text = book.pengarang;
        _penerbitanController.text = book.penerbitan;
        _deskripsiController.text = book.deskripsi;
        _isbnController.text = book.isbn;
        _sinopsisController.text = book.sinopsis ?? '';
        _keywordController.text = book.keyword ?? '';
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to fetch book details')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updateBook() async {
    setState(() {
      _isLoading = true;
    });

    final updatedBook = {
      'judul': _judulController.text,
      'pengarang': _pengarangController.text,
      'penerbitan': _penerbitanController.text,
      'deskripsi': _deskripsiController.text,
      'isbn': _isbnController.text,
      'sinopsis': _sinopsisController.text,
      'keyword': _keywordController.text,
    };

    try {
      final response = await http.put(
        Uri.parse('http://192.168.9.63:5000/api/editBookSinopsis/${widget.id}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(updatedBook),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Book updated successfully')),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update book')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _judulController.dispose();
    _pengarangController.dispose();
    _penerbitanController.dispose();
    _deskripsiController.dispose();
    _isbnController.dispose();
    _sinopsisController.dispose();
    _keywordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Book'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            _buildTextArea(_judulController, 'Judul'),
                            const SizedBox(height: 16),
                            _buildTextField(_pengarangController, 'Pengarang'),
                            const SizedBox(height: 16),
                            _buildTextField(
                                _penerbitanController, 'Penerbitan'),
                            const SizedBox(height: 16),
                            _buildTextField(_deskripsiController, 'Deskripsi'),
                            const SizedBox(height: 16),
                            _buildTextField(_isbnController, 'ISBN'),
                            const SizedBox(height: 16),
                            _buildTextArea(_sinopsisController, 'Sinopsis'),
                            const SizedBox(height: 16),
                            _buildTextArea(_keywordController, 'Keyword'),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 40, vertical: 15),
                          backgroundColor: Colors.blueAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: _updateBook,
                        child: const Text(
                          'Update Book',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String labelText) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        border: OutlineInputBorder(),
        labelStyle: const TextStyle(fontSize: 18),
      ),
    );
  }

  Widget _buildTextArea(TextEditingController controller, String labelText) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        border: OutlineInputBorder(),
        labelStyle: const TextStyle(fontSize: 18),
      ),
      maxLines: null,
      keyboardType: TextInputType.multiline,
    );
  }
}
