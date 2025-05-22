import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:otobook/models/master_book_response_model.dart';
import 'package:otobook/services/api.dart';

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
  late TextEditingController _kotaController;
  late TextEditingController _tahunController;
  late TextEditingController _editorController;
  late TextEditingController _ilustratorController;
  late TextEditingController _sinopsisController;
  late TextEditingController _keywordController;
  late TextEditingController _noClassController;
  late String? selectedValue; // Pilihan awal
  List<String> items = ['Diolah', 'Disumbangkan'];

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _judulController = TextEditingController();
    _pengarangController = TextEditingController();
    _penerbitanController = TextEditingController();
    _deskripsiController = TextEditingController();
    _isbnController = TextEditingController();
    _kotaController = TextEditingController();
    _tahunController = TextEditingController();
    _editorController = TextEditingController();
    _ilustratorController = TextEditingController();
    _sinopsisController = TextEditingController();
    _keywordController = TextEditingController();
    _noClassController = TextEditingController();
    _fetchBookDetails();
  }

  Future<void> _fetchBookDetails() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final response = await http
          .get(Uri.parse('${GetData().getBookWithSinopsisUrl}${widget.id}'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final book =
            masterBook.fromJson(data); // Ensure this is the correct class
        _judulController.text = book.judul;
        _pengarangController.text = book.pengarang;
        _penerbitanController.text = book.penerbitan;
        _deskripsiController.text = book.deskripsi;
        _isbnController.text = book.isbn;
        _kotaController.text = book.kota;
        _tahunController.text = book.tahun;
        _editorController.text = book.editor;
        _ilustratorController.text = book.ilustrator ?? '';
        selectedValue = book.kategori ?? 'Diolah';
        _sinopsisController.text = book.sinopsis ?? '';
        _keywordController.text = book.keyword ?? '';
        _noClassController.text = book.noClass ?? '';
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
      'kota': _kotaController.text,
      'tahun_terbit': _tahunController.text,
      'editor': _editorController.text,
      'ilustrator': _ilustratorController.text,
      'kategori': selectedValue,
      'sinopsis': _sinopsisController.text,
      'keyword': _keywordController.text,
      'no_class': _noClassController.text,
    };

    try {
      // print(updatedBook);
      final response = await http.put(
        Uri.parse('${GetData().editBookSinopsisUrl}/${widget.id}'),
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
      if (response.statusCode != 200) {
        // print('Error: ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${response.body}')),
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
    _kotaController.dispose();
    _tahunController.dispose();
    _editorController.dispose();
    _ilustratorController.dispose();
    _sinopsisController.dispose();
    _keywordController.dispose();
    _noClassController.dispose();
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
                            _buildTextField(_kotaController, 'Kota'),
                            const SizedBox(height: 16),
                            _buildTextField(_tahunController, 'Tahun Terbit'),
                            const SizedBox(height: 16),
                            _buildTextField(_editorController, 'Editor'),
                            const SizedBox(height: 16),
                            _buildTextField(
                                _ilustratorController, 'Ilustrator'),
                            const SizedBox(height: 16),
                            DropdownButtonFormField<String>(
                              value: selectedValue,
                              items: items
                                  .map((item) => DropdownMenuItem<String>(
                                        value: item,
                                        child: Text(item),
                                      ))
                                  .toList(),
                              onChanged: (value) {
                                setState(() {
                                  selectedValue = value;
                                });
                              },
                              decoration: InputDecoration(
                                labelText: 'Kategori',
                                border: OutlineInputBorder(),
                                labelStyle: const TextStyle(fontSize: 18),
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildTextArea(_sinopsisController, 'Sinopsis'),
                            const SizedBox(height: 16),
                            _buildTextArea(_keywordController, 'Keyword'),
                            const SizedBox(height: 16),
                            _buildTextArea(_noClassController, 'DeweyNoClass'),
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