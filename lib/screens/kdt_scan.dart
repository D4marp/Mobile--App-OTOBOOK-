import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:Otobook/services/ocr_service.dart';

class KDTScannerScreen extends StatefulWidget {
  @override
  _KDTScannerScreenState createState() => _KDTScannerScreenState();
}

class _KDTScannerScreenState extends State<KDTScannerScreen> {
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _authorController = TextEditingController();
  final TextEditingController _publisherController = TextEditingController();
  final TextEditingController _publicationYearController = TextEditingController();
  final TextEditingController _isbnController = TextEditingController();
  final TextEditingController _editionController = TextEditingController();
  final TextEditingController _physicalDescriptionController = TextEditingController();
  final TextEditingController _seriesController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

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
            _parseKDTText(extractedText);
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
        SnackBar(
            content:
                Text('Failed to scan and extract text. Please try again.')),
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
                  Navigator.pop(context,
                      await _picker.pickImage(source: ImageSource.camera));
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('Gallery'),
                onTap: () async {
                  Navigator.pop(context,
                      await _picker.pickImage(source: ImageSource.gallery));
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _parseKDTText(String text) {
    final lines = text.split('\n');
    String? title, author, publisher, isbn, edition, physicalDescription, series, notes;
    int? publicationYear;

    for (var line in lines) {
      line = line.trim();
      if (line.isEmpty) continue;

      // Parsing each line based on KDT format
      if (line.startsWith('ISBN')) {
        isbn = line.replaceAll(RegExp(r'[^0-9\-]'), ''); // Extract ISBN number
      } else if (line.startsWith('—')) {
        final parts = line.split('—');
        if (parts.length >= 3) {
          author = parts[0].trim();
          publisher = parts[1].trim();
          title = parts[2].trim();
        }
      } else if (RegExp(r'\d{4}').hasMatch(line)) {
        publicationYear = int.tryParse(RegExp(r'\d{4}').firstMatch(line)?.group(0) ?? '');
      } else if (line.startsWith('Edisi')) {
        edition = line.replaceFirst('Edisi', '').trim();
      } else if (line.startsWith('Deskripsi Fisik')) {
        physicalDescription = line.replaceFirst('Deskripsi Fisik', '').trim();
      } else if (line.startsWith('Seri')) {
        series = line.replaceFirst('Seri', '').trim();
      } else if (line.startsWith('Catatan')) {
        notes = line.replaceFirst('Catatan', '').trim();
      }
    }

    // Set parsed values to the text controllers
    _titleController.text = title ?? '';
    _authorController.text = author ?? '';
    _publisherController.text = publisher ?? '';
    _publicationYearController.text = publicationYear?.toString() ?? '';
    _isbnController.text = isbn ?? '';
    _editionController.text = edition ?? '';
    _physicalDescriptionController.text = physicalDescription ?? '';
    _seriesController.text = series ?? '';
    _notesController.text = notes ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('KDT Scan'),
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
                    child: Text('Scan and Extract KDT'),
                  ),
                  SizedBox(height: 20),
                  if (_extractedText.isNotEmpty) ...[
                    Text('Extracted Text:'),
                    SizedBox(height: 10),
                    _buildBookFields(),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        // Handle save or further action
                      },
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
        _buildField('Edition', _editionController),
        _buildField('Physical Description', _physicalDescriptionController),
        _buildField('Series', _seriesController),
        _buildField('Notes', _notesController),
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
