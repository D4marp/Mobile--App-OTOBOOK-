import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class CoverScanner extends StatefulWidget {
  final int id;
  const CoverScanner({super.key, required this.id});

  @override
  State<CoverScanner> createState() => _CoverScannerState();
}

class _CoverScannerState extends State<CoverScanner> {
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;
  XFile? _coverImage;
  File? _coverImageFile;

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
                title: Text('Camera'),
                onTap: () async {
                  Navigator.pop(context,
                      await _picker.pickImage(source: ImageSource.camera));
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: Text('Gallery'),
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

  Future<void> _pickCoverImage() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final pickedFile = await _showImageSourceSelector();
      if (pickedFile != null) {
        setState(() {
          _coverImage = pickedFile;
          _coverImageFile = File(pickedFile.path); // Convert to File
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No image selected.')),
        );
      }
    } catch (e) {
      print('Error picking cover image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Failed to pick cover image. Please try again.')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _uploadCoverImage() async {
    if (_coverImageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No image to upload.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      var uri =
          Uri.parse('http://192.168.9.63:5000/api/uploadCover/${widget.id}');
      var request = http.MultipartRequest('POST', uri)
        ..files.add(
            await http.MultipartFile.fromPath('file', _coverImageFile!.path));

      var response = await request.send();

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cover image uploaded successfully.')),
        );
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(
        //     builder: (context) => const GetBooksPage(),
        //   ),
        // );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to upload cover image.')),
        );
      }
    } catch (e) {
      print('Error uploading cover image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Failed to upload cover image. Please try again.')),
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
        title: const Text('Scan Book Cover'),
        backgroundColor: const Color(0xFF95A2FF),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  ElevatedButton(
                    onPressed: _pickCoverImage,
                    child: const Text('Pick Cover Image'),
                  ),
                  const SizedBox(height: 20),
                  if (_coverImage != null) ...[
                    Image.file(
                      _coverImageFile!,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _uploadCoverImage,
                      child: const Text('Upload Cover Image'),
                    ),
                  ],
                ],
              ),
            ),
    );
  }
}
