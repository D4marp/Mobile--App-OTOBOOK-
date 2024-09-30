import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart'; // Import image_cropper
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart'; // Import MediaType class
import 'package:Otobook/services/api.dart'; // Pastikan path ini benar

class CropAspectRatioPresetCustom implements CropAspectRatioPresetData {
  @override
  (int, int)? get data => (2, 3);

  @override
  String get name => '2x3 (customized)';
}

class CoverScanner extends StatefulWidget {
  final int id;
  const CoverScanner({super.key, required this.id});

  @override
  State<CoverScanner> createState() => _CoverScannerState();
}

class _CoverScannerState extends State<CoverScanner> {
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;
  File? _imageFile; // Untuk menyimpan file gambar yang dipilih

  Future<XFile?> _showImageSourceSelector() async {
    return showModalBottomSheet<XFile?>(context: context, builder: (BuildContext context) {
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
    });
  }

  Future<void> _pickCoverImage() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final pickedFile = await _showImageSourceSelector();
      if (pickedFile != null) {
        _imageFile = File(pickedFile.path); // Simpan file gambar yang dipilih
        setState(() {}); // Update UI setelah gambar dipilih
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

  Future<void> _cropImage() async {
    if (_imageFile == null) return;

    // Menggunakan image_cropper untuk cropping dengan custom aspect ratio
    CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: _imageFile!.path, // Gunakan path file yang dipilih
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Cropper',
          toolbarColor: Colors.deepOrange,
          toolbarWidgetColor: Colors.white,
          aspectRatioPresets: [
            CropAspectRatioPreset.original,
            CropAspectRatioPreset.square,
            CropAspectRatioPresetCustom(),
          ],
        ),
        IOSUiSettings(
          title: 'Cropper',
          aspectRatioPresets: [
            CropAspectRatioPreset.original,
            CropAspectRatioPreset.square,
            CropAspectRatioPresetCustom(), // IMPORTANT: iOS supports only one custom aspect ratio in preset list
          ],
        ),
        WebUiSettings(
          context: context,
        ),
      ],
    );

    if (croppedFile != null) {
      await _uploadCoverImage(File(croppedFile.path)); // Mengupload gambar yang sudah di-crop
    }
  }

  Future<void> _uploadCoverImage(File croppedFile) async {
    setState(() {
      _isLoading = true;
    });

    try {
      var uri = Uri.parse('${GetData().addCoverUrl}/${widget.id}');
      var request = http.MultipartRequest('POST', uri)
        ..files.add(await http.MultipartFile.fromPath(
          'file', 
          croppedFile.path, 
          contentType: MediaType('image', 'png'), // Pastikan tipe file sesuai
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
                    onPressed: _pickCoverImage,
                    child: Text('Pick Cover Image'),
                  ),
                  SizedBox(height: 20),
                  if (_imageFile != null) ...[
                    Image.file(_imageFile!), // Menampilkan gambar yang dipilih
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _cropImage, // Memulai proses cropping
                      child: Text('Crop and Upload Cover Image'),
                    ),
                  ],
                ],
              ),
            ),
    );
  }
}
