import 'dart:convert';

import 'package:Otobook/models/sinopsisBook.dart';
import 'package:Otobook/screens/list_book.dart';
import 'package:Otobook/services/api.dart';
// import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
// import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;


class AddKeywordPages extends StatefulWidget {
  final Sinopsisbook sinopsisBookData;
  const AddKeywordPages({Key? key, required this.sinopsisBookData})
      : super(key: key);

  @override
  State<AddKeywordPages> createState() => _AddKeywordPagesState();
}

class _AddKeywordPagesState extends State<AddKeywordPages> {
  final _formKey = GlobalKey<FormState>();
  late Sinopsisbook _sinopsisBook;
  late TextEditingController _sinopsisController;
  late TextEditingController _masterBookIdController;
  final TextEditingController _keywordController = TextEditingController();

  @override
  void initState() {
    _sinopsisBook = widget.sinopsisBookData;
    _sinopsisController = TextEditingController(text: _sinopsisBook.sinopsis);
    _masterBookIdController =
        TextEditingController(text: _sinopsisBook.masterBookId.toString());
    super.initState();
  }

  @override
  void dispose() {
    _sinopsisController.dispose();
    _masterBookIdController.dispose();
    super.dispose();
  }

  int get masterBookId => widget.sinopsisBookData.masterBookId;

  Future<Map<String, dynamic>> _saveKeyword(int id) async {
    Uri url = Uri.parse(GetData().addSinopsisUrl + id.toString());
    final response = await http.post(url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(<String, String>{
          'sinopsis': _sinopsisController.text,
          'keyword': _keywordController.text,
          'masterBookId': _masterBookIdController.text,
        }));

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
    return responseBody; // Kembalikan respons server
  }

  Future<void> _keyword({required String sinopsis}) async {
    Uri url = Uri.parse(GetData().getKlasifikasiUrl);
    try {
      final result = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(<String, String>{
          'sinopsis': sinopsis,
        }),
      );

      final response = jsonDecode(result.body);

      print('API Response: $response'); // Log API response

      if (result.statusCode == 200) {
        if (response.containsKey('keywords')) {
          setState(() {
            _keywordController.text = response['keywords'];
          });
        } else {
          print('Keywords not found in response'); // Debugging
          setState(() {
            _keywordController.text = 'No keywords found';
          });
        }
      } else {
        setState(() {
          _keywordController.text = 'Gagal mendapatkan kata kunci';
        });
      }
    } catch (e) {
      print('Error fetching keywords: $e'); // Handle errors
      setState(() {
        _keywordController.text = 'Gagal mendapatkan kata kunci';
      });
    }
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
                        _keyword(sinopsis: _sinopsisController.text);
                      },
                      child: const Text('Add Keyword'),
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
                    _buildTextArea(_sinopsisController, 'Sinopsis'),
                    const SizedBox(height: 16),
                    _buildTextArea(_keywordController, 'Keyword'),
                    const SizedBox(height: 16.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () {
                            _keyword(sinopsis: _sinopsisController.text);
                          },
                          icon: const Icon(Icons.get_app),
                          label: const Text('keyword'),
                        ),
                        ElevatedButton.icon(
                          onPressed: () async {
                            _saveKeyword(masterBookId);
                          },
                          icon: const Icon(Icons.save),
                          label: const Text('Save'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromARGB(
                                255, 26, 240, 3), // Warna tombol hapus
                          ),
                        ),
                      ],
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

  Widget _buildTextArea(TextEditingController controller, String labelText) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        border: const OutlineInputBorder(),
        labelStyle: const TextStyle(fontSize: 18),
      ),
      maxLines: null,
      keyboardType: TextInputType.multiline,
    );
  }
}
