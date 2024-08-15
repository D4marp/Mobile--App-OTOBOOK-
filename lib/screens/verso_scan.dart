import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:Otobook/services/ocr_service.dart';
import 'package:Otobook/models/book.dart';
import 'package:Otobook/screens/edit_book.dart';
import 'package:Otobook/services/firestore_service.dart';

class OCRScannerScreen extends StatefulWidget {
  @override
  _OCRScannerScreenState createState() => _OCRScannerScreenState();
}

class _OCRScannerScreenState extends State<OCRScannerScreen> {
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _authorController = TextEditingController();
  final TextEditingController _publisherController = TextEditingController();
  final TextEditingController _publicationYearController = TextEditingController();
  final TextEditingController _isbnController = TextEditingController();

  bool _isLoading = false;
  String _extractedText = '';

  Future<void> _scanAndExtract() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final pickedFile = await _showImageSourceSelector();
      if (pickedFile != null) {
        String extractedText = await OCRService.extractTextFromImage(pickedFile.path);

        if (extractedText.isNotEmpty) {
          setState(() {
            _extractedText = extractedText;
          });
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No image selected.')),
        );
      }
    } catch (e) {
      print('Error scanning and extracting: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to scan and extract text. Please try again.')),
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

  Widget _buildExtractedTextWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _extractedText.split('\n').map((line) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: GestureDetector(
            child: SelectableText(
              line,
              onSelectionChanged: (selection, cause) {
                if (selection.baseOffset != -1 && selection.extentOffset != -1) {
                  final selectedText = line.substring(
                    selection.baseOffset,
                    selection.extentOffset,
                  );
                  if (cause == SelectionChangedCause.tap) {
                    _showFieldSelectionDialog(selectedText);
                  }
                }
              },
            ),
          ),
        );
      }).toList(),
    );
  }

  void _showFieldSelectionDialog(String selectedText) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select Field'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                onPressed: () {
                  _titleController.text = selectedText;
                  Navigator.pop(context);
                },
                child: Text('Set as Title'),
              ),
              ElevatedButton(
                onPressed: () {
                  _authorController.text = selectedText;
                  Navigator.pop(context);
                },
                child: Text('Set as Author'),
              ),
              ElevatedButton(
                onPressed: () {
                  _publisherController.text = selectedText;
                  Navigator.pop(context);
                },
                child: Text('Set as Publisher'),
              ),
              ElevatedButton(
                onPressed: () {
                  _publicationYearController.text = selectedText;
                  Navigator.pop(context);
                },
                child: Text('Set as Publication Year'),
              ),
              ElevatedButton(
                onPressed: () {
                  _isbnController.text = selectedText;
                  Navigator.pop(context);
                },
                child: Text('Set as ISBN'),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _navigateToEditBook() async {
    final book = Book(
      id: '', // Generate an ID if needed or leave it empty for Firestore auto-ID
      title: _titleController.text,
      author: _authorController.text,
      publisher: _publisherController.text,
      publicationYear: int.tryParse(_publicationYearController.text) ?? 0,
      ISBN: _isbnController.text,
    );

    try {
      // Save the book to Firestore
      await FirestoreService().addBook(book);

      // Navigate to EditBookScreen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EditBookScreen(book: book),
        ),
      );
    } catch (e) {
      print('Error saving book: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save book. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Scan Verso'),
        backgroundColor: Color(0xFF95A2FF),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  ElevatedButton(
                    onPressed: _scanAndExtract,
                    child: Text('Scan and Extract Text'),
                  ),
                  SizedBox(height: 20),
                  if (_extractedText.isNotEmpty) ...[
                    Text('Extracted Text:'),
                    SizedBox(height: 10),
                    _buildExtractedTextWidget(),
                    SizedBox(height: 20),
                    _buildBookFields(),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _navigateToEditBook,
                      child: Text('Save and Edit Book'),
                    ),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _buildBookFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildField('Title', _titleController),
        _buildField('Author', _authorController),
        _buildField('Publisher', _publisherController),
        _buildField('Publication Year', _publicationYearController),
        _buildField('ISBN', _isbnController),
      ],
    );
  }

  Widget _buildField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
      ),
    );
  }
}
