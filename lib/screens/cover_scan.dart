import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:Otobook/models/book.dart';
import 'package:Otobook/services/firestore_service.dart';

class CoverScannerScreen extends StatefulWidget {
  @override
  _CoverScannerScreenState createState() => _CoverScannerScreenState();
}

class _CoverScannerScreenState extends State<CoverScannerScreen> {
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;
  XFile? _coverImage;

  Future<void> _pickCoverImage() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final pickedFile = await _showImageSourceSelector();
      if (pickedFile != null) {
        setState(() {
          _coverImage = pickedFile;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No image selected.')),
        );
      }
    } catch (e) {
      print('Error picking cover image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick cover image. Please try again.')),
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

  Future<void> _saveCoverImage() async {
    if (_coverImage != null) {
      try {
        // You can save the cover image path to the Book model or upload it to storage.
        final book = Book(
          id: '',
          coverImagePath: _coverImage!.path, // Save the cover image path
          title: '', // Other fields can be filled as needed
          author: '',
          publisher: '',
          publicationYear: 0,
          ISBN: '',
        );

        await FirestoreService().addBook(book);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Cover image saved successfully.')),
        );
      } catch (e) {
        print('Error saving cover image: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save cover image. Please try again.')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No cover image selected.')),
      );
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
                    onPressed: _pickCoverImage,
                    child: Text('Pick Cover Image'),
                  ),
                  SizedBox(height: 20),
                  if (_coverImage != null)
                    Column(
                      children: [
                        Image.file(
                          File(_coverImage!.path),
                          height: 200,
                        ),
                        SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _saveCoverImage,
                          child: Text('Save Cover Image'),
                        ),
                      ],
                    ),
                ],
              ),
            ),
    );
  }
}
