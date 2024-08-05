import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:Otobook/services/ocr_service.dart';
import 'package:Otobook/models/book.dart';
import 'package:Otobook/screens/edit_book.dart';

class OCRScannerScreen extends StatefulWidget {
  @override
  _OCRScannerScreenState createState() => _OCRScannerScreenState();
}

class _OCRScannerScreenState extends State<OCRScannerScreen> {
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;
  String _extractedText = '';
  String _title = '';
  String _author = '';
  String _publisher = '';
  String _publicationYear = '';
  String _isbn = '';

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
        return GestureDetector(
          onTap: () => _showFieldSelectionDialog(line),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Text(line),
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
                  setState(() {
                    _title = selectedText;
                  });
                  Navigator.pop(context);
                },
                child: Text('Set as Title'),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _author = selectedText;
                  });
                  Navigator.pop(context);
                },
                child: Text('Set as Author'),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _publisher = selectedText;
                  });
                  Navigator.pop(context);
                },
                child: Text('Set as Publisher'),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _publicationYear = selectedText;
                  });
                  Navigator.pop(context);
                },
                child: Text('Set as Publication Year'),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isbn = selectedText;
                  });
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

  void _navigateToEditBook() {
    final book = Book(
      id: '',
      title: _title,
      author: _author,
      publisher: _publisher,
      publicationYear: int.tryParse(_publicationYear) ?? 0,
      ISBN: _isbn,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditBookScreen(book: book),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Scan Book'),
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
        _buildField('Title', _title),
        _buildField('Author', _author),
        _buildField('Publisher', _publisher),
        _buildField('Publication Year', _publicationYear),
        _buildField('ISBN', _isbn),
      ],
    );
  }

  Widget _buildField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Text('$label: ', style: TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
