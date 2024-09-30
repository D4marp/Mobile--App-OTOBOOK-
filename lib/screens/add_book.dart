import 'dart:convert';
import 'package:Otobook/navigation.dart';
import 'package:http/http.dart' as http;
import 'package:Otobook/services/api.dart';
import 'package:flutter/material.dart';
import 'package:Otobook/models/masterBook.dart';
import 'package:Otobook/screens/start.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  Future<String?> _userId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('id');
  }

  void _saveBook() async {
    String? userId = await _userId();
    Uri url = Uri.parse(GetData().addBookUrl + userId!);
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
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => const NavigationMenu(),
        ),
        (Route<dynamic> route) => false,
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
