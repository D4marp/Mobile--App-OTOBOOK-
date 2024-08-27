import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:Otobook/services/ocr_service.dart';
import 'package:Otobook/models/masterBook.dart';
import 'package:Otobook/screens/add_book.dart';

class VersoScanner extends StatefulWidget {
  const VersoScanner({super.key});

  @override
  _VersoScannerState createState() => _VersoScannerState();
}

class _VersoScannerState extends State<VersoScanner> {
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;
  String _rawText = '';
  Map<String, String> extractedData = {
    'Judul': '',
    'Pengarang': '',
    'Penerbitan': '',
    'Deskripsi': '',
    'ISBN': ''
  };

  Future<XFile?> _showImageSourceSelector() async {
    return showModalBottomSheet<XFile?>(
      context: context,
      builder: (BuildContext context) {
        return SizedBox(
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
        String rawText = await OCRService.extractTextFromImage(pickedFile.path);
        if (rawText.isNotEmpty) {
          setState(() {
            _rawText = rawText.trim();
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

  void _onTextSelection(TextSelection selection, SelectionChangedCause? cause) async {
    if (selection.isValid && selection.start != selection.end) {
      final String selectedText = _rawText.substring(selection.start, selection.end).trim();

      if (selectedText.isNotEmpty) {
        final String? selectedField = await showMenu<String>(
          context: context,
          position: RelativeRect.fromLTRB(
            selection.start.toDouble(),
            selection.end.toDouble(),
            0.0,
            0.0,
          ),
          items: extractedData.keys.map((String field) {
            return PopupMenuItem<String>(
              value: field,
              child: Text(field),
            );
          }).toList(),
        );

        if (selectedField != null) {
          setState(() {
            extractedData[selectedField] = extractedData[selectedField]! +
                (extractedData[selectedField]!.isEmpty ? '' : ' ') +
                selectedText;
          });
        }
      }
    }
  }

  void _navigateToAddPage() {
    final masterBookData = masterBook(
      id: 0,
      judul: extractedData['Judul']!,
      pengarang: extractedData['Pengarang']!,
      penerbitan: extractedData['Penerbitan']!,
      deskripsi: extractedData['Deskripsi']!,
      isbn: extractedData['ISBN']!,
    );
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddBookScreen(masterBookData: masterBookData),
      ),
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ElevatedButton(
                    onPressed: _scanAndExtract,
                    child: const Text('Scan and Extract Text'),
                  ),
                  const SizedBox(height: 20),
                  if (_rawText.isNotEmpty) ...[
                    const Text('Tap and drag to select text for a field:'),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.white,
                      ),
                      child: SingleChildScrollView(
                        child: SelectableText.rich(
                          TextSpan(
                            text: _rawText,
                            style: const TextStyle(fontSize: 16, color: Colors.black),
                          ),
                          onSelectionChanged: _onTextSelection,
                          showCursor: true,
                          cursorColor: Colors.blue,
                          cursorWidth: 2.0,
                          toolbarOptions: const ToolbarOptions(
                            copy: true,
                            selectAll: true,
                          ),
                          enableInteractiveSelection: true,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text('Extracted Data:'),
                    const SizedBox(height: 10),
                    ...extractedData.entries.map((entry) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${entry.key}: ',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                            Expanded(
                              child: Text(
                                entry.value.isEmpty
                                    ? 'No data selected'
                                    : entry.value,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
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
