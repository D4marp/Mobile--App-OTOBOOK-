import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:Otobook/models/book.dart';
import 'package:Otobook/services/firestore_service.dart';

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
        // You can save the table of contents image path to the Book model or upload it to storage.
        final book = Book(
          id: '',
          daftarIsiImagePath: _daftarIsiImage!.path, // Save the table of contents image path
          title: '', // Other fields can be filled as needed
          author: '',
          publisher: '',
          publicationYear: 0,
          ISBN: '',
        );

        await FirestoreService().addBook(book);

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
