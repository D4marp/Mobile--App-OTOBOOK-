import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:Otobook/models/book.dart';

class DaftarIsiScanScreen extends StatefulWidget {
  @override
  _DaftarIsiScanScreenState createState() => _DaftarIsiScanScreenState();
}

class _DaftarIsiScanScreenState extends State<DaftarIsiScanScreen> {
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;
  XFile? _daftarIsiImage;

  Future<void> _pickDaftarIsiImage() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final pickedFile = await _showImageSourceSelector();
      if (pickedFile != null) {
        setState(() {
          _daftarIsiImage = pickedFile;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No image selected.')),
        );
      }
    } catch (e) {
      print('Error picking table of contents image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick image. Please try again.')),
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

  Future<void> _saveDaftarIsiImage() async {
    if (_daftarIsiImage != null) {
      try {
        // Anda dapat menyimpan path gambar daftar isi ke model Book atau menyimpannya di penyimpanan lokal
        final book = Book(
          id: '',
          daftarIsiImagePath: _daftarIsiImage!.path, // Simpan path gambar daftar isi
          title: '', // Field lain bisa diisi sesuai kebutuhan
          author: '',
          publisher: '',
          publicationYear: 0,
          ISBN: '',
        );

        // Lakukan sesuatu dengan objek 'book', misalnya simpan di list atau database lokal
        print('Table of contents image path saved: ${book.daftarIsiImagePath}');

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Table of contents image saved successfully.')),
        );
      } catch (e) {
        print('Error saving table of contents image: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save image. Please try again.')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No image selected.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Scan Daftar Isi'),
        backgroundColor: Color(0xFF95A2FF),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  ElevatedButton(
                    onPressed: _pickDaftarIsiImage,
                    child: Text('Pick Daftar Isi Image'),
                  ),
                  SizedBox(height: 20),
                  if (_daftarIsiImage != null)
                    Column(
                      children: [
                        Image.file(
                          File(_daftarIsiImage!.path),
                          height: 200,
                        ),
                        SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _saveDaftarIsiImage,
                          child: Text('Save Daftar Isi Image'),
                        ),
                      ],
                    ),
                ],
              ),
            ),
    );
  }
}
