import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:otobook/services/api.dart';


class RegisterPage extends StatefulWidget {
  final void Function()? ontap;
  const RegisterPage({super.key, this.ontap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _obscureText = true;
  bool _isLoading = false;
  String? _errorMessage;

  // Email validation
  bool _isValidEmail(String email) {
    return RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(email);
  }

  Future<void> register() async {
    // Clear previous error message
    setState(() {
      _errorMessage = null;
    });

    // Validate form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Additional validation
    if (usernameController.text.trim().isEmpty) {
      setState(() {
        _errorMessage = 'Please enter your username';
      });
      return;
    }

    if (usernameController.text.trim().length < 3) {
      setState(() {
        _errorMessage = 'Username must be at least 3 characters';
      });
      return;
    }

    if (emailController.text.trim().isEmpty) {
      setState(() {
        _errorMessage = 'Please enter your email';
      });
      return;
    }

    if (!_isValidEmail(emailController.text.trim())) {
      setState(() {
        _errorMessage = 'Please enter a valid email address';
      });
      return;
    }

    if (passwordController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter your password';
      });
      return;
    }

    if (passwordController.text.length < 6) {
      setState(() {
        _errorMessage = 'Password must be at least 6 characters';
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse(GetData().registerUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': usernameController.text.trim(),
          'email': emailController.text.trim(),
          'password': passwordController.text,
        }),
      );

      if (response.statusCode == 201) {
        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Registration successful! Please sign in.'),
              backgroundColor: Colors.green,
            ),
          );
          
          // Navigate back to login
          widget.ontap?.call();
        }
      } else {
        // Tangani error dari server
        String errorMessage = 'Registration failed';
        try {
          final errorData = json.decode(response.body);
          errorMessage = errorData['message'] ?? 'Registration failed';
        } catch (e) {
          errorMessage = 'Registration failed with status code: ${response.statusCode}';
        }
        
        setState(() {
          _errorMessage = errorMessage;
        });
      }
    } catch (e) {
      // Tangani error jaringan atau lainnya
      setState(() {
        _errorMessage = 'Network error. Please check your connection and try again.';
      });
      // Debug print - should be removed in production
      debugPrint('Registration error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: InputBorder.none,
          suffixIcon: suffixIcon,
        ),
        keyboardType: keyboardType,
        obscureText: obscureText,
        validator: validator,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
       backgroundColor: Colors.white,
      appBar: AppBar(
          backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back,
              color: Color.fromARGB(255, 176, 176, 176)),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Daftar',
          style: TextStyle(
            color: Color(0xFF3C83F5),
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.10,
          ),
        ),
        centerTitle: true,
        toolbarHeight: 79,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(
                width: double.infinity,
                child: Opacity(
                  opacity: 0.50,
                  child: Text(
                    'Daftar sekarang dan nikmati keistimewaan OTOBOOK yang belum pernah ada sebelumnya.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF111827),
                      fontSize: 14,
                      fontFamily: 'Montserrat',
                      height: 1.5,
                      letterSpacing: 0.07,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              if (_errorMessage != null)
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red[600], size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(color: Colors.red[600], fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildTextFormField(
                      controller: usernameController,
                      label: 'Nama Pengguna',
                      keyboardType: TextInputType.text,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Silakan masukkan nama pengguna Anda';
                        }
                        if (value.trim().length < 3) {
                          return 'Nama pengguna minimal 3 karakter';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16.0),
                    _buildTextFormField(
                      controller: emailController,
                      label: 'Email',
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Silakan masukkan email Anda';
                        }
                        if (!_isValidEmail(value.trim())) {
                          return 'Silakan masukkan alamat email yang valid';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16.0),
                    _buildTextFormField(
                      controller: passwordController,
                      label: 'Kata Sandi',
                      obscureText: _obscureText,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureText ? Icons.visibility_off : Icons.visibility,
                          color: const Color.fromARGB(255, 172, 170, 170),
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureText = !_obscureText;
                          });
                        },
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Silakan masukkan kata sandi';
                        }
                        if (value.length < 6) {
                          return 'Kata sandi minimal 6 karakter';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: _isLoading ? null : register,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3C83F5),
                        minimumSize: const Size(double.infinity, 50),
                        disabledBackgroundColor: Colors.grey[300],
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text(
                              'Daftar',
                              style: TextStyle(color: Colors.white),
                            ),
                    ),
                    const SizedBox(height: 8.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Sudah punya akun? Masuk ',
                          style: TextStyle(
                            color: Color(0xFF111827),
                            fontSize: 12,
                            fontFamily: 'Montserrat',
                            letterSpacing: 0.07,
                          ),
                        ),
                        TextButton(
                          onPressed: widget.ontap,
                          child: const Text(
                            'Masuk',
                            style: TextStyle(
                              color: Color(0xFF3C83F5),
                              fontSize: 12,
                              fontFamily: 'Montserrat',
                              letterSpacing: 0.07,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
