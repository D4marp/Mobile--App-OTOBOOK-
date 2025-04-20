import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:http/http.dart' as http;
import 'package:otobook/services/api.dart';

import '../../models/master_book_response_model.dart';

class ISBNScanPage extends StatefulWidget {
  const ISBNScanPage({super.key});

  @override
  State<ISBNScanPage> createState() => _ISBNScanPageState();
}

class _ISBNScanPageState extends State<ISBNScanPage> {
  final MobileScannerController _scannerController = MobileScannerController();
  List<masterBook> _books = [];
  bool _isScanning = false;
  bool _isLoading = false;
  String _errorMessage = '';

  bool _isValidISBN(String isbn) {
    return RegExp(r'^(97(8|9))?\d{9}(\d|X)$').hasMatch(isbn);
  }

  Future<void> _searchBookByISBN(String isbn) async {
    if (!_isValidISBN(isbn)) {
      setState(() {
        _errorMessage = 'ISBN tidak valid: $isbn';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final Uri url = Uri.parse('${GetData().searchBookUrl}?isbn=$isbn');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        if (result['data'] != null && result['data'].isNotEmpty) {
          setState(() {
            _books = List<masterBook>.from(
              result['data'].map((i) => masterBook.fromJson(i)),
            );
          });
        } else {
          setState(() {
            _errorMessage = 'Tidak ada buku ditemukan dengan ISBN: $isbn';
          });
        }
      } else {
        setState(() {
          _errorMessage = 'Gagal mencari buku. Status code: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Terjadi kesalahan: ${e.toString()}';
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
        title: const Text('Pindai ISBN Buku'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: MobileScanner(
              controller: _scannerController,
              onDetect: (BarcodeCapture capture) {
                if (_isScanning || capture.barcodes.isEmpty) return;
                setState(() => _isScanning = true);

                final String? isbn = capture.barcodes.first.rawValue;
                if (isbn != null && isbn.trim().isNotEmpty) {
                  _scannerController.stop();
                  _searchBookByISBN(isbn.trim()).whenComplete(() {
                    setState(() => _isScanning = false);
                  });
                } else {
                  setState(() {
                    _isScanning = false;
                    _errorMessage = 'Barcode tidak terbaca';
                  });
                }
              },
            ),
          ),
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  if (_isLoading)
                    const CircularProgressIndicator.adaptive()
                  else if (_errorMessage.isNotEmpty)
                    Text(
                      _errorMessage,
                      style: const TextStyle(color: Colors.red, fontSize: 16),
                      textAlign: TextAlign.center,
                    )
                  else if (_books.isEmpty)
                    const Text(
                      'Pindai ISBN untuk mencari detail buku.',
                      style: TextStyle(fontSize: 16),
                    )
                  else
                    Expanded(
                      child: ListView.builder(
                        itemCount: _books.length,
                        itemBuilder: (context, index) {
                          final book = _books[index];
                          return ListTile(
                            title: Text(book.judul),
                            subtitle: Text('Pengarang: ${book.pengarang}'),
                            onTap: () {
                              // Aksi ketika buku dipilih
                            },
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
