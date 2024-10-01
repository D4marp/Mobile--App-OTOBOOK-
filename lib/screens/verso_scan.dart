import 'package:Otobook/models/masterBook.dart';
import 'package:Otobook/screens/add_book.dart';
import 'package:Otobook/services/ocr_service.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class VersoScanner extends StatefulWidget {
  const VersoScanner({super.key});

  @override
  State<VersoScanner> createState() => _VersoScannerState();
}

class _VersoScannerState extends State<VersoScanner> {
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;
  String _extractedText = '';
  String judul = "";
  String pengarang = "";
  String penerbitan = "";
  String deskripsi = "";
  String isbn = "";
  String kota = "";
  String tahun = "";
  String editor = "";
  String ilustrator = "";

  final FocusNode _judulFocusNode = FocusNode();
  final FocusNode _pengarangFocusNode = FocusNode();
  final FocusNode _penerbitanFocusNode = FocusNode();
  final FocusNode _deskripsiFocusNode = FocusNode();
  final FocusNode _isbnFocusNode = FocusNode();
  final FocusNode _kotaFocusNode = FocusNode();
  final FocusNode _tahunFocusNode = FocusNode();
  final FocusNode _editorFocusNode = FocusNode();
  final FocusNode _ilustratorFocusNode = FocusNode();

  final TextEditingController _judulController = TextEditingController();
  final TextEditingController _pengarangController = TextEditingController();
  final TextEditingController _penerbitanController = TextEditingController();
  final TextEditingController _deskripsiController = TextEditingController();
  final TextEditingController _isbnController = TextEditingController();
  final TextEditingController _kotaController = TextEditingController();
  final TextEditingController _tahunController = TextEditingController();
  final TextEditingController _editorController = TextEditingController();
  final TextEditingController _ilustratorController = TextEditingController();

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

  void _showFieldSelectionDialog(String selectedText) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Field'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                ListTile(
                  title: const Text('Judul'),
                  onTap: () {
                    setState(() {
                      _judulController.text = selectedText;
                      FocusScope.of(context).requestFocus(_judulFocusNode);
                    });
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  title: const Text('Pengarang'),
                  onTap: () {
                    setState(() {
                      _pengarangController.text = selectedText;
                      FocusScope.of(context).requestFocus(_pengarangFocusNode);
                    });
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  title: const Text('Penerbitan'),
                  onTap: () {
                    setState(() {
                      _penerbitanController.text = selectedText;
                      FocusScope.of(context).requestFocus(_penerbitanFocusNode);
                    });
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  title: const Text('Deskripsi'),
                  onTap: () {
                    setState(() {
                      _deskripsiController.text = selectedText;
                      FocusScope.of(context).requestFocus(_deskripsiFocusNode);
                    });
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  title: const Text('ISBN'),
                  onTap: () {
                    setState(() {
                      _isbnController.text = selectedText;
                      FocusScope.of(context).requestFocus(_isbnFocusNode);
                    });
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  title: const Text('Kota'),
                  onTap: () {
                    setState(() {
                      _kotaController.text = selectedText;
                      FocusScope.of(context).requestFocus(_kotaFocusNode);
                    });
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  title: const Text('Tahun Terbit'),
                  onTap: () {
                    setState(() {
                      _tahunController.text = selectedText;
                      FocusScope.of(context).requestFocus(_tahunFocusNode);
                    });
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  title: const Text('Editor'),
                  onTap: () {
                    setState(() {
                      _editorController.text = selectedText;
                      FocusScope.of(context).requestFocus(_editorFocusNode);
                    });
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  title: const Text('Ilustrator'),
                  onTap: () {
                    setState(() {
                      _ilustratorController.text = selectedText;
                      FocusScope.of(context).requestFocus(_ilustratorFocusNode);
                    });
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
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
            onTap: () {
              _showFieldSelectionDialog(line);
            },
            child: Text(
              line,
              style: const TextStyle(
                  decoration:
                      TextDecoration.underline // Optionally change text color
                  ),
            ),
          ),
        );
      }).toList(),
    );
  }

  void _navigateToAddPage() {
    final masterBookData = masterBook(
      id: 0,
      judul: _judulController.text,
      pengarang: _pengarangController.text,
      penerbitan: _penerbitanController.text,
      deskripsi: _deskripsiController.text,
      isbn: _isbnController.text,
      kota: _kotaController.text,
      tahun: _tahunController.text,
      editor: _editorController.text,
      ilustrator: _ilustratorController.text,
    );
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddBookScreen(masterBookData: masterBookData),
      ),
    );
  }

  Widget _buildField(
      String label, TextEditingController controller, FocusNode focusNode) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: TextFormField(
        controller: controller,
        focusNode: focusNode,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _buildFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildField('Judul', _judulController, _judulFocusNode),
        _buildField('Pengarang', _pengarangController, _pengarangFocusNode),
        _buildField('Penerbitan', _penerbitanController, _penerbitanFocusNode),
        _buildField('Deskripsi', _deskripsiController, _deskripsiFocusNode),
        _buildField('ISBN', _isbnController, _isbnFocusNode),
        _buildField('Kota', _kotaController, _kotaFocusNode),
        _buildField('Tahun Terbit', _tahunController, _tahunFocusNode),
        _buildField('Editor', _editorController, _editorFocusNode),
        _buildField('Ilustrator', _ilustratorController, _ilustratorFocusNode),
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
