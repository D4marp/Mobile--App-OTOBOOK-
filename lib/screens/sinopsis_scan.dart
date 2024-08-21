import 'package:Otobook/models/sinopsisBook.dart';
import 'package:Otobook/screens/add_keyword.dart';
import 'package:Otobook/services/ocr_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';

class SinopsisScanner extends StatefulWidget {
  final int id;

  const SinopsisScanner({super.key, required this.id});

  @override
  State<SinopsisScanner> createState() => _SinopsisScannerState();
}

class _SinopsisScannerState extends State<SinopsisScanner> {
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;
  String _extractedText = '';
  String sinopsis = '';

  int get masterBookId => widget.id;

  Future<XFile?> _showImageSourceSelector() async {
    return showModalBottomSheet<XFile?>(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 150,
          child: Column(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Camera'),
                onTap: () async {
                  Navigator.pop(context,
                      await _picker.pickImage(source: ImageSource.camera));
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
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

  Future<void> _scanAndExtract() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final pickedFile = await _showImageSourceSelector();
      if (pickedFile != null) {
        String extractedText =
            await OCRService.extractTextFromImage(pickedFile.path);

        if (extractedText.isNotEmpty) {
          setState(() {
            _extractedText = extractedText;
          });
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No image selected.')),
        );
      }
    } catch (e) {
      print('Error scanning and extracting: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('Failed to scan and extract text. Please try again.')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _navigateToAddPage() {
    final sinopsisbookData = Sinopsisbook(
      id: 0,
      sinopsis: sinopsis,
      masterBookId: masterBookId,
    );
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            AddKeywordPages(sinopsisBookData: sinopsisbookData),
      ),
    );
  }

  Widget _buildExtractedTextWidget() {
    return SelectableText(
      _extractedText,
      style: const TextStyle(fontSize: 16.0),
      onSelectionChanged: (selection, cause) {
        // Get selected text
        final selectedText =
            _extractedText.substring(selection.start, selection.end);
        if (selectedText.isNotEmpty) {
          setState(() {
            sinopsis = selectedText;
          });
        }
      },
    );
  }

  Widget _buildField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildField('Sinopsis', sinopsis),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Book'),
        backgroundColor: const Color(0xFF95A2FF),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  ElevatedButton(
                    onPressed: _scanAndExtract,
                    child: const Text('Scan and Extract Text'),
                  ),
                  const SizedBox(height: 20),
                  if (_extractedText.isNotEmpty) ...[
                    const Text('Extracted Text:'),
                    const SizedBox(height: 10),
                    _buildExtractedTextWidget(),
                    const SizedBox(height: 20),
                    _buildFields(),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _navigateToAddPage,
                      child: const Text('Save and Edit Book'),
                    ),
                  ],
                ],
              ),
            ),
    );
  }
}
