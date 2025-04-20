import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';

import '../../services/api.dart';

class EditUserPage extends StatefulWidget {
  final int id;
  const EditUserPage({super.key, required this.id});

  @override
  State<EditUserPage> createState() => _EditUserPageState();
}

class _EditUserPageState extends State<EditUserPage> {
  final ImagePicker _picker = ImagePicker();
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _usernameController;
  late TextEditingController _emailController;
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

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _fetchUserDetails() async {
    setState(() => _isLoading = true);
    try {
      final response = await http.get(Uri.parse('${GetData().getUserIdUrl}/${widget.id}'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _usernameController.text = data['username'] ?? '';
          _emailController.text = data['email'] ?? '';
          _profileImageUrl = data['path'] != null ? '${GetData().Url}${data['path']}' : null;
        });
      } else {
        throw Exception('Failed to load user data');
      }
    } catch (e) {
      _showSnackbar('Failed to load user details: ${e.toString()}', Colors.red);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _pickProfileImage() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery, maxWidth: 800, maxHeight: 800, imageQuality: 85);
      if (pickedFile != null) {
        setState(() => _profileImageFile = File(pickedFile.path));
      }
    } catch (e) {
      _showSnackbar('Failed to pick image: ${e.toString()}', Colors.red);
    }
  }

  Future<void> _updateUser() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final request = http.MultipartRequest('PUT', Uri.parse('${GetData().editUserByIdUrl}/${widget.id}'))
        ..fields['username'] = _usernameController.text.trim()
        ..fields['email'] = _emailController.text.trim();
      if (_profileImageFile != null) {
        request.files.add(await http.MultipartFile.fromPath('file', _profileImageFile!.path));
      }
      final response = await request.send();
      if (response.statusCode == 200) {
        _showSnackbar('Profile updated successfully', Colors.green);
        Navigator.pop(context, true);
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      _showSnackbar('Failed to update profile: ${e.toString()}', Colors.red);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackbar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color, behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(FeatherIcons.check),
            onPressed: _isLoading ? null : _updateUser,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildProfileImageSection(),
                    const SizedBox(height: 32),
                    _buildTextField(_usernameController, 'Username', FeatherIcons.user),
                    const SizedBox(height: 20),
                    _buildTextField(_emailController, 'Email', FeatherIcons.mail, isEmail: true),
                    const SizedBox(height: 40),
                    _buildUpdateButton(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildProfileImageSection() {
    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            CircleAvatar(
              radius: 60,
              backgroundImage: _profileImageFile != null
                  ? FileImage(_profileImageFile!)
                  : _profileImageUrl != null
                      ? NetworkImage(_profileImageUrl!) as ImageProvider
                      : null,
              child: _profileImageFile == null && _profileImageUrl == null
                  ? const Icon(FeatherIcons.user, size: 50, color: Colors.grey)
                  : null,
            ),
            IconButton(
              icon: const Icon(FeatherIcons.camera, size: 18, color: Colors.white),
              onPressed: _pickProfileImage,
            ),
          ],
        ),
        const SizedBox(height: 10),
        TextButton(onPressed: _pickProfileImage, child: const Text('Change Photo')),
      ],
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool isEmail = false}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon)),
      keyboardType: isEmail ? TextInputType.emailAddress : TextInputType.text,
      validator: (value) {
        if (value == null || value.isEmpty) return 'Please enter $label';
        if (isEmail && !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}\$').hasMatch(value)) return 'Invalid email format';
        return null;
      },
    );
  }

  Widget _buildUpdateButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(onPressed: _isLoading ? null : _updateUser, child: const Text('SAVE CHANGES')),
    );
  }
}
