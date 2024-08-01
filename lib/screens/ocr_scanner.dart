import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:Otobook/services/gpt4_service.dart';
import 'package:Otobook/services/firestore_service.dart';
import 'package:Otobook/models/book.dart';
import 'package:Otobook/services/ocr_service.dart';

class OCRScannerScreen extends StatefulWidget {
  @override
  _OCRScannerScreenState createState() => _OCRScannerScreenState();
}

class _OCRScannerScreenState extends State<OCRScannerScreen> {
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  Future<void> _scanAndExtract() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Pilih gambar dari kamera
      final pickedFile = await _picker.pickImage(source: ImageSource.camera);
      if (pickedFile != null) {
        // Ekstrak teks dari gambar menggunakan OCR
        String extractedText = await OCRService.extractTextFromImage(pickedFile.path);

        if (extractedText.isEmpty) {
          throw Exception('OCR extraction returned empty text');
        }

        // Ekstrak detail buku menggunakan GPT-4
        Map<String, dynamic> bookData = await GPT4Service.extractBookDetails(extractedText);

        if (bookData == null || bookData.isEmpty) {
          throw Exception('Failed to extract book details');
        }

        // Validasi dan penyimpanan buku
        _validateAndSaveBook(bookData);
      } else {
        // Tangani kasus di mana tidak ada gambar yang dipilih
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No image selected.')),
        );
      }
    } catch (e) {
      // Tangani kesalahan
      print('Error scanning and extracting: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to scan and add book. Please try again.')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _validateAndSaveBook(Map<String, dynamic> bookData) async {
    try {
      // Buat objek buku baru
      Book newBook = Book(
        id: bookData['id'] ?? '', // Berikan nilai default atau tangani data yang hilang
        title: bookData['title'] ?? 'Unknown Title',
        author: bookData['author'] ?? 'Unknown Author',
        publisher: bookData['publisher'] ?? 'Unknown Publisher',
        publicationYear: bookData['publicationYear'] ?? 0,
        ISBN: bookData['ISBN'] ?? 'Unknown ISBN',
      );

      // Validasi data buku sebelum disimpan
      if (newBook.title.isEmpty || newBook.author.isEmpty || newBook.ISBN.isEmpty) {
        throw Exception('Incomplete book data. Please provide all necessary details.');
      }

      // Tambahkan buku baru ke Firestore
      await FirestoreService().addBook(newBook);

      // Berikan umpan balik kepada pengguna
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Book added successfully.')),
      );

      // Kembali ke layar sebelumnya atau tindakan lain
      Navigator.pop(context);
    } catch (e) {
      // Tangani kesalahan
      print('Error saving book: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save book. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _isLoading
          ? CircularProgressIndicator() // Tampilkan indikator pemuatan saat memproses
          : ElevatedButton(
              onPressed: _scanAndExtract,
              child: Text('Scan and Add Book'),
            ),
      ),
    );
  }
}
