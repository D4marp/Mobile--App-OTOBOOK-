import 'dart:convert';
import 'package:Otobook/models/masterBook.dart';
import 'package:Otobook/services/api.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class ISBNScanPage extends StatefulWidget {
  const ISBNScanPage({Key? key}) : super(key: key);

  @override
  State<ISBNScanPage> createState() => _ISBNScanPageState();
}

class _ISBNScanPageState extends State<ISBNScanPage> {
  final BarcodeScanner _barcodeScanner = BarcodeScanner();
  final ImagePicker _picker = ImagePicker();
  List<masterBook> _books = [];
  bool _isScanning = false;
  bool _isLoading = false;
  String _errorMessage = '';

  @override
  void dispose() {
    _barcodeScanner.close();
    super.dispose();
  }

  Future<void> _scanISBN() async {
    setState(() {
      _isScanning = true;
      _errorMessage = '';
    });

    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.camera);
      if (pickedFile != null) {
        final inputImage = InputImage.fromFilePath(pickedFile.path);
        final barcodes = await _barcodeScanner.processImage(inputImage);

        for (Barcode barcode in barcodes) {
          if (barcode.type == BarcodeType.isbn) {
            final isbn = barcode.rawValue ?? '';
            await _searchBookByISBN(isbn);
            break;
          }
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to scan ISBN: $e';
      });
    } finally {
      setState(() {
        _isScanning = false;
      });
    }
  }

  Future<void> _searchBookByISBN(String isbn) async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final Uri url = Uri.parse('${GetData().searchBookUrl}?isbn=$isbn');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        if (result['data'] != null) {
          setState(() {
            _books = List<masterBook>.from(
              result['data'].map((i) => masterBook.fromJson(i)),
            );
          });
        } else {
          setState(() {
            _errorMessage = 'No book found with ISBN: $isbn';
          });
        }
      } else {
        setState(() {
          _errorMessage = 'Failed to search book. Status code: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error searching book: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Book ISBN'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: _isScanning ? null : _scanISBN,
              child: _isScanning ? const CircularProgressIndicator() : const Text('Scan ISBN'),
            ),
            const SizedBox(height: 20),
            _isLoading
                ? const CircularProgressIndicator.adaptive()
                : _errorMessage.isNotEmpty
                    ? Text(_errorMessage, style: const TextStyle(color: Colors.red))
                    : _books.isEmpty
                        ? const Text('Scan ISBN to find book details.', style: TextStyle(fontSize: 16))
                        : Expanded(
                            child: ListView.builder(
                              itemCount: _books.length,
                              itemBuilder: (context, index) {
                                final book = _books[index];
                                return ListTile(
                                  title: Text(book.judul),
                                  subtitle: Text('Author: ${book.pengarang}'),
                                  onTap: () {
                                    // Navigate to book details or any other action
                                  },
                                );
                              },
                            ),
                          ),
          ],
        ),
      ),
    );
  }
}
