import 'dart:convert';
import 'dart:io';
import 'package:Otobook/services/api.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

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

      request.fields['username'] = _usernameController.text;
      request.fields['email'] = _emailController.text;

      if (_profileImageFile != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'file', 
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
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Colors.black87),
                title: const Text('Camera'),
                onTap: () async {
                  Navigator.pop(
                    context,
                    await _picker.pickImage(source: ImageSource.camera),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: Colors.black87),
                title: const Text('Gallery'),
                onTap: () async {
                  Navigator.pop(
                    context,
                    await _picker.pickImage(source: ImageSource.gallery),
                  );
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
        const SnackBar(content: Text('Failed to pick profile image.')),
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
        elevation: 1,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: GestureDetector(
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
                          backgroundColor: const Color(0xFFe0e0e0),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24.0),
                    Text(
                      'Username',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 8.0),
                    TextField(
                      controller: _usernameController,
                      decoration: InputDecoration(
                        hintText: 'Enter username',
                        filled: true,
                        fillColor: Colors.grey[100],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24.0),
                    Text(
                      'Email',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 8.0),
                    TextField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        hintText: 'Enter email',
                        filled: true,
                        fillColor: Colors.grey[100],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40.0),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          backgroundColor: Colors.black87,
                        ),
                        onPressed: _updateUser,
                        child: const Text(
                          'Update User',
                          style: TextStyle(fontSize: 16.0, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
