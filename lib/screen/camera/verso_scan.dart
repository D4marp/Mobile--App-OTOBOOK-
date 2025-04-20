import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:otobook/models/master_book_response_model.dart';
import 'package:otobook/screen/book/add_book.dart';
import 'package:otobook/services/ocr_service.dart';

class VersoScanner extends StatefulWidget {
  const VersoScanner({super.key, this.autoPress = false});
 final bool autoPress;

  
  @override
  State<VersoScanner> createState() => _VersoScannerState();
}

class _VersoScannerState extends State<VersoScanner> {
    void initState() {
    super.initState();
    if (widget.autoPress) {
      Future.delayed(Duration(milliseconds: 500), () {
        _scanAndExtract(); // Langsung jalankan scanning
      });
    }
  }
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

  String formatAsTitle(String text) {
    // Memastikan teks tidak kosong
    if (text.isEmpty) return '';

    // Mengubah huruf pertama dari teks menjadi huruf besar, dan sisanya huruf kecil
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
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
                      // Mengubah teks hasil ekstraksi menggunakan formatAsTitle
                      String formattedText = formatAsTitle(selectedText);

                      // Gabungkan teks yang sudah ada dengan yang baru
                      _judulController.text = _judulController.text.isEmpty
                          ? formattedText
                          : '${_judulController.text}, $formattedText';

                      FocusScope.of(context).requestFocus(_judulFocusNode);
                    });
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  title: const Text('Pengarang'),
                  onTap: () {
                    setState(() {
                      _pengarangController.text =
                          _pengarangController.text.isEmpty
                              ? selectedText
                              : '${_pengarangController.text}, $selectedText';
                      FocusScope.of(context).requestFocus(_pengarangFocusNode);
                    });
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  title: const Text('Penerbitan'),
                  onTap: () {
                    setState(() {
                      _penerbitanController.text =
                          _penerbitanController.text.isEmpty
                              ? selectedText
                              : '${_penerbitanController.text}, $selectedText';
                      FocusScope.of(context).requestFocus(_penerbitanFocusNode);
                    });
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  title: const Text('Deskripsi'),
                  onTap: () {
                    setState(() {
                      _deskripsiController.text =
                          _deskripsiController.text.isEmpty
                              ? selectedText
                              : '${_deskripsiController.text}, $selectedText';
                      FocusScope.of(context).requestFocus(_deskripsiFocusNode);
                    });
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  title: const Text('ISBN'),
                  onTap: () {
                    setState(() {
                      // Menghapus teks "ISBN" atau "ISBN :" dan hanya mengambil angka dan tanda hubung
                      String formattedText = selectedText
                          .replaceAll(RegExp(r'ISBN\s*:?'), '')
                          .replaceAll(RegExp(r'[^0-9-]'), '');

                      _isbnController.text = _isbnController.text.isEmpty
                          ? formattedText
                          : '${_isbnController.text}, $formattedText';
                      FocusScope.of(context).requestFocus(_isbnFocusNode);
                    });
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  title: const Text('Kota'),
                  onTap: () {
                    setState(() {
                      // Regex untuk mendeteksi pola nama kota (kata dengan huruf kapital di awal)
                      final cityPattern =
                          RegExp(r'\b[A-Z][a-z]+(?:\s[A-Z][a-z]+)?\b');

                      // Cari kecocokan pertama yang dianggap sebagai kota
                      final match = cityPattern.firstMatch(selectedText);

                      // Jika ada kecocokan, ambil nama kotanya
                      final cityName = match?.group(0) ?? 'Tidak ditemukan';

                      // Isi ke dalam field kota, mengganti teks sebelumnya
                      _kotaController.text = cityName;

                      // Pindahkan fokus ke field kota
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
                      // Regex untuk mendeteksi nama (dua kata dengan huruf kapital di awal)
                      final namePattern =
                          RegExp(r'\b[A-Z][a-z]+\s[A-Z][a-z]+\b');

                      // Ambil semua nama yang cocok dalam teks
                      final matches = namePattern.allMatches(selectedText);

                      // Gabungkan semua nama menjadi satu string, dipisahkan oleh koma
                      final extractedNames =
                          matches.map((m) => m.group(0)).join(', ');

                      // Tambahkan ke dalam field editor, gabungkan jika sudah ada teks
                      _editorController.text = _editorController.text.isEmpty
                          ? extractedNames
                          : '${_editorController.text}, $extractedNames';

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

  Widget _buildTextArea(
      String labelText, TextEditingController controller, FocusNode focusNode) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      decoration: InputDecoration(
        labelText: labelText,
        border: OutlineInputBorder(),
        labelStyle: const TextStyle(fontSize: 18),
      ),
      maxLines: null,
      keyboardType: TextInputType.multiline,
    );
  }

  Widget _buildFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextArea('Judul', _judulController, _judulFocusNode),
        const SizedBox(height: 10),
        _buildTextArea('Pengarang', _pengarangController, _pengarangFocusNode),
        const SizedBox(height: 10),
        _buildTextArea(
            'Penerbitan', _penerbitanController, _penerbitanFocusNode),
        const SizedBox(height: 10),
        _buildTextArea('Deskripsi', _deskripsiController, _deskripsiFocusNode),
        const SizedBox(height: 10),
        _buildTextArea('ISBN', _isbnController, _isbnFocusNode),
        const SizedBox(height: 10),
        _buildTextArea('Kota', _kotaController, _kotaFocusNode),
        const SizedBox(height: 10),
        _buildTextArea('Tahun Terbit', _tahunController, _tahunFocusNode),
        const SizedBox(height: 10),
        _buildTextArea('Editor', _editorController, _editorFocusNode),
        const SizedBox(height: 10),
        _buildTextArea(
            'Ilustrator', _ilustratorController, _ilustratorFocusNode),
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
                    onPressed: () async {
                      await _scanAndExtract();
                    },
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