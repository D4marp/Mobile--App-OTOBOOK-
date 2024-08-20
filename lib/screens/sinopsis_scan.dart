import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:Otobook/services/gpt4_service.dart';
import 'package:Otobook/services/ocr_service.dart';
import 'package:Otobook/models/book.dart';

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
      final pickedFile = await _showImageSourceSelector();
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

      // Only perform keyword classification, without extracting book details from GPT-4
      List<String> keywords = await GPT4Service.classifyKeywords(extractedText);

      // You need to implement a way to get other book details like title, author, etc.
      Book newBook = Book(
        id: '', // ID should be set or determined if needed
        title: 'Unknown Title', // Set default or allow user input
        author: 'Unknown Author',
        publisher: 'Unknown Publisher',
        publicationYear: 0,
        ISBN: 'Unknown ISBN',
        synopsis: extractedText,
        keywords: keywords,
      );

      // Replace this with code to save the book to your chosen storage or database
      // Example: await YourDatabaseService.addBook(newBook);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Synopsis scanned and book added successfully.')),
      );

      Navigator.pop(context); // Return to the previous screen
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

  Future<XFile?> _showImageSourceSelector() async {
    return showModalBottomSheet<XFile?>(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 150,
          child: Column(
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.camera_alt),
                title: Text('Camera'),
                onTap: () async {
                  Navigator.pop(context, await _picker.pickImage(source: ImageSource.camera));
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('Gallery'),
                onTap: () async {
                  Navigator.pop(context, await _picker.pickImage(source: ImageSource.gallery));
                },
              ),
            ],
          ),
        );
      },
    );
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
