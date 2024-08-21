import 'package:flutter/material.dart';
import 'package:otobook/models/api.dart';
import 'package:otobook/models/masterBook.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:otobook/pages/getBooks.dart';

class AddPageBook extends StatefulWidget {
  final masterBook masterBookData;
  const AddPageBook({Key? key, required this.masterBookData}) : super(key: key);

  @override
  State<AddPageBook> createState() => _AddPageBookState();
}

class _AddPageBookState extends State<AddPageBook> {
  final _formKey = GlobalKey<FormState>();
  late masterBook _masterBook;
  late TextEditingController _judulController;
  late TextEditingController _pengarangController;
  late TextEditingController _penerbitanController;
  late TextEditingController _deskripsiController;
  late TextEditingController _isbnController;

  @override
  void initState() {
    _masterBook = widget.masterBookData;
    _judulController = TextEditingController(text: _masterBook.judul);
    _pengarangController = TextEditingController(text: _masterBook.pengarang);
    _penerbitanController = TextEditingController(text: _masterBook.penerbitan);
    _deskripsiController = TextEditingController(text: _masterBook.deskripsi);
    _isbnController = TextEditingController(text: _masterBook.isbn);
    super.initState();
  }

  @override
  void dispose() {
    _judulController.dispose();
    _pengarangController.dispose();
    _penerbitanController.dispose();
    _deskripsiController.dispose();
    _isbnController.dispose();
    super.dispose();
  }

  void _saveBook() async {
    Uri url = Uri.parse(GetData().addBookUrl);
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(<String, String>{
        'judul': _judulController.text,
        'isbn': _isbnController.text,
        'pengarang': _pengarangController.text,
        'penerbitan': _penerbitanController.text,
        'deskripsi': _deskripsiController.text,
      }),
    );

    final responseBody = jsonDecode(response.body);

    if (response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(responseBody['message'] ?? 'Book saved successfully'),
        ),
      );
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const GetBooksPage(),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(responseBody['message'] ?? 'Failed to save book'),
        ),
      );
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(251, 255, 255, 255),
      body: Column(
        children: [
          Container(
            decoration: const BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(20.0),
              ),
            ),
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SizedBox(
                    width: 150,
                    child: ElevatedButton(
                      onPressed: () {
                        // print('Add Books button pressed');
                      },
                      child: const Text('Add Books'),
                    ),
                  ),
                ),
                const Spacer(),
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () {
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(builder: (context) => StartScreen()),
                      // );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Image.asset(
                        'assets/logo_oto.PNG',
                        height: 40,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTextArea(_judulController, 'Judul'),
                    const SizedBox(height: 16.0),
                    _buildTextArea(_pengarangController, 'Pengarang'),
                    const SizedBox(height: 16.0),
                    _buildTextArea(_penerbitanController, 'Penerbit'),
                    const SizedBox(height: 16.0),
                    _buildTextArea(_deskripsiController, 'Deskripsi'),
                    const SizedBox(height: 16.0),
                    _buildTextArea(_isbnController, 'ISBN'),
                    const SizedBox(height: 16.0),
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton(
                        onPressed: _saveBook,
                        child: const Text('Submit'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
