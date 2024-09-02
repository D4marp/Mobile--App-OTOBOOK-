import 'dart:convert';
import 'package:Otobook/screens/list_book.dart';
import 'package:http/http.dart' as http;
import 'package:Otobook/services/api.dart';
import 'package:flutter/material.dart';
import 'package:Otobook/models/masterBook.dart';
import 'package:Otobook/screens/start.dart';

class AddBookScreen extends StatefulWidget {
  final masterBook masterBookData;
  const AddBookScreen({super.key, required this.masterBookData});

  @override
  State<AddBookScreen> createState() => _AddBookScreenState();
}

class _AddBookScreenState extends State<AddBookScreen> {
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

  // Future<void> _runAutomation() async {
  //   Uri url = Uri.parse(GetData().runAutomationUrl);
  //   try {
  //     final response = await http.post(url);

  //     if (response.statusCode == 200) {
  //       final responseData = json.decode(response.body);
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //             content:
  //                 Text('Automation triggered: ${responseData['message']}')),
  //       );
  //     } else {
  //       final responseData = json.decode(response.body);
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text('Error: ${responseData['error']}')),
  //       );
  //     }
  //   } catch (error) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('Failed to connect to the server: $error')),
  //     );
  //   }
  // }

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
      backgroundColor: Color.fromARGB(255, 255, 255, 255),
      body: Column(
        children: [
          Container(
            decoration: BoxDecoration(
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
                        print('Add Books button pressed');
                      },
                      child: Text('Add Books'),
                    ),
                  ),
                ),
                Spacer(),
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => StartScreen()),
                      );
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
                        onPressed: () async {
                          _saveBook(); // Kirim data formulir
                          //await _runAutomation(); // Jalankan otomatisasi
                        },
                        child: const Text('Submit'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

}
