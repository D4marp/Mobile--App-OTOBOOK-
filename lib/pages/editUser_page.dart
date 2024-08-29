import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:otobook/models/api.dart';

class EdituserPage extends StatefulWidget {
  final int id;
  const EdituserPage({super.key, required this.id});

  @override
  State<EdituserPage> createState() => _EdituserPageState();
}

class _EdituserPageState extends State<EdituserPage> {
  final ImagePicker _picker = ImagePicker();
  late TextEditingController _usernameController;
  late TextEditingController _emailController;
  XFile? _profileImage;
  File? _profileImageFile;
  bool _isLoading = false;
  String? _profileImageUrl;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController();
    _emailController = TextEditingController();

    _fetchUserDetails();
  }

  Future<void> _fetchUserDetails() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final response =
          await http.get(Uri.parse('${GetData().getUserIdUrl}/${widget.id}'));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        _usernameController.text = data['username'];
        _emailController.text = data['email'];
        _profileImageUrl = '${GetData().Url}${data['path']}';
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to fetch user details')),
        );
      }
    } catch (e) {
      print('Error fetching user details: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updateUser() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final uri = Uri.parse('${GetData().editUserByIdUrl}/${widget.id}');
      final request = http.MultipartRequest('PUT', uri);

      // Add text fields
      request.fields['username'] = _usernameController.text;
      request.fields['email'] = _emailController.text;

      // Add the profile image if it exists
      if (_profileImageFile != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'file', // The field name expected by the server
          _profileImageFile!.path,
        ));
      }

      final response = await request.send();
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User updated successfully')),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update User')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
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

  Future<void> _pickProfileImage() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final pickedFile = await _showImageSourceSelector();
      if (pickedFile != null) {
        setState(() {
          _profileImage = pickedFile;
          _profileImageFile = File(pickedFile.path);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No image selected.')),
        );
      }
    } catch (e) {
      print('Error picking profile image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Failed to pick profile image. Please try again.')),
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
        title: const Text('Edit User'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Profile Image Display
                    GestureDetector(
                      onTap: _pickProfileImage,
                      child: CircleAvatar(
                        radius: 60,
                        backgroundImage: _profileImageFile != null
                            ? FileImage(_profileImageFile!)
                            : _profileImageUrl != null
                                ? NetworkImage(_profileImageUrl!)
                                : const AssetImage(
                                        'assets/profile_placeholder.jpg')
                                    as ImageProvider,
                        backgroundColor: const Color.fromARGB(255, 82, 64, 64),
                      ),
                    ),
                    const SizedBox(height: 20.0),

                    // Username Input
                    TextField(
                      controller: _usernameController,
                      decoration: const InputDecoration(
                        labelText: 'Username',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 20.0),

                    // Email Input
                    TextField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 20.0),

                    // Update Button
                    ElevatedButton(
                      onPressed: _updateUser,
                      child: const Text('Update User'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
