import "package:flutter/material.dart";
import "package:image_picker/image_picker.dart";
import "package:otobook/models/masterBook.dart";
import "package:otobook/services/ocr_service.dart";
import "package:otobook/pages/add_page.dart";

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
                      judul = selectedText;
                    });
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  title: const Text('Pengarang'),
                  onTap: () {
                    setState(() {
                      pengarang = selectedText;
                    });
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  title: const Text('Penerbitan'),
                  onTap: () {
                    setState(() {
                      penerbitan = selectedText;
                    });
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  title: const Text('Deskripsi'),
                  onTap: () {
                    setState(() {
                      deskripsi = selectedText;
                    });
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  title: const Text('ISBN'),
                  onTap: () {
                    setState(() {
                      isbn = selectedText;
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

  // Widget _buildExtractedTextWidget() {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: _extractedText.split('\n').map((line) {
  //       return GestureDetector(
  //         onTap: () => _showFieldSelectionDialog(line),
  //         child: Padding(
  //           padding: const EdgeInsets.symmetric(vertical: 4.0),
  //           child: Text(line),
  //         ),
  //       );
  //     }).toList(),
  //   );
  // }

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
                color: Colors.blue,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  void _navigateToAddPage() {
    print(
        'Judul: $judul, Pengarang: $pengarang, Penerbitan: $penerbitan, Deskripsi: $deskripsi, ISBN: $isbn');

    final masterBookData = masterBook(
      id: 0,
      judul: judul,
      pengarang: pengarang,
      penerbitan: penerbitan,
      deskripsi: deskripsi,
      isbn: isbn,
    );
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddPageBook(masterBookData: masterBookData),
      ),
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
        _buildField('Judul', judul),
        _buildField('Pengarang', pengarang),
        _buildField('Penerbitan', penerbitan),
        _buildField('Deskripsi', deskripsi),
        _buildField('ISBN', isbn),
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
