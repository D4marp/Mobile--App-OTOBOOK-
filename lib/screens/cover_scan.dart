import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cunning_document_scanner/cunning_document_scanner.dart'; // Hapus 'image_picker' karena tidak diperlukan lagi
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:Otobook/services/api.dart'; // Pastikan path ini benar

class CoverScanner extends StatefulWidget {
  final int id;
  const CoverScanner({super.key, required this.id});

  @override
  State<CoverScanner> createState() => _CoverScannerState();
}

class _CoverScannerState extends State<CoverScanner> {
  bool _isLoading = false;
  File? _scannedFile;

  Future<void> _scanCoverImage() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final scannedImagePaths = await CunningDocumentScanner.getPictures(); // Memindai dokumen

      if (scannedImagePaths != null && scannedImagePaths.isNotEmpty) {
        _scannedFile = File(scannedImagePaths[0]); // Ambil gambar pertama (cover buku)
        setState(() {});
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No document scanned.')),
        );
      }
    } catch (e) {
      print('Error scanning document: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to scan document. Please try again.')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _uploadCoverImage(File scannedFile) async {
    setState(() {
      _isLoading = true;
    });

    try {
      var uri = Uri.parse('${GetData().addCoverUrl}/${widget.id}');
      var request = http.MultipartRequest('POST', uri)
        ..files.add(await http.MultipartFile.fromPath(
          'file',
          scannedFile.path,
          contentType: MediaType('image', 'png'), // Pastikan format file sesuai
        ));

      var response = await request.send();

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Cover image uploaded successfully.')),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to upload cover image.')),
        );
      }
    } catch (e) {
      print('Error uploading cover image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload cover image. Please try again.')),
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
        title: Text('Scan Book Cover'),
        backgroundColor: Color(0xFF95A2FF),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  ElevatedButton(
                    onPressed: _scanCoverImage, // Gunakan scanner untuk mengambil gambar cover
                    child: Text('Scan Cover Image'),
                  ),
                  SizedBox(height: 20),
                  if (_scannedFile != null) ...[
                    Image.file(_scannedFile!), // Menampilkan hasil gambar yang dipindai
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () => _uploadCoverImage(_scannedFile!), // Mengupload gambar
                      child: Text('Upload Cover Image'),
                    ),
                  ],
                ],
              ),
            ),
    );
  }
}
