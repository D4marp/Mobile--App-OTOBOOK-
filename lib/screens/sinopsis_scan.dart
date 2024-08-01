import 'package:Otobook/models/book.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:Otobook/services/gpt4_service.dart';
import 'package:Otobook/services/firestore_service.dart';
import 'package:Otobook/services/ocr_service.dart';

class OCRSynopsisScannerScreen extends StatefulWidget {
  @override
  _OCRSynopsisScannerScreenState createState() => _OCRSynopsisScannerScreenState();
}

class _OCRSynopsisScannerScreenState extends State<OCRSynopsisScannerScreen> {
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  Future<void> _scanAndExtractSynopsis() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.camera);
      if (pickedFile == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No image selected.')),
        );
        return;
      }

      String extractedText = await OCRService.extractTextFromImage(pickedFile.path);

      if (extractedText.isEmpty) {
        throw Exception('OCR extraction returned empty text');
      }

      List<String> keywords = await GPT4Service.classifyKeywords(extractedText);
      Map<String, dynamic> bookData = await GPT4Service.extractBookDetails(extractedText);

      if (bookData == null || bookData.isEmpty) {
        throw Exception('Failed to extract book details');
      }

      Book newBook = Book(
        id: bookData['id'] ?? '',
        title: bookData['title'] ?? 'Unknown Title',
        author: bookData['author'] ?? 'Unknown Author',
        publisher: bookData['publisher'] ?? 'Unknown Publisher',
        publicationYear: bookData['publicationYear'] ?? 0,
        ISBN: bookData['ISBN'] ?? 'Unknown ISBN',
        synopsis: extractedText,
        keywords: keywords,
      );

      if (newBook.id.isNotEmpty) {
        await FirestoreService().updateBook(newBook);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Synopsis scanned and updated successfully.')),
        );
      } else {
        await FirestoreService().addBook(newBook);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Book added successfully.')),
        );
      }

      Navigator.pop(context); // Kembali ke layar sebelumnya
    } catch (e) {
      print('Error scanning and extracting synopsis: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to scan and add synopsis. Please try again.')),
      );
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
        title: Text('Scan Synopsis'),
        backgroundColor: Color(0xFF95A2FF),
      ),
      body: Center(
        child: _isLoading
            ? CircularProgressIndicator()
            : ElevatedButton(
                onPressed: _scanAndExtractSynopsis,
                child: Text('Scan and Add Synopsis'),
              ),
      ),
    );
  }
}
