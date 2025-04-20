import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:otobook/services/api.dart';
import 'package:otobook/services/login_register_service.dart';


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
  // final TextEditingController confirmPasswordController =
  //     TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _obscureText = true;
  String? _errorMessage;

  Future<void> register() async {
    final response = await http.post(
      Uri.parse(GetData().registerUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'username': usernameController.text,
        'email': emailController.text,
        'password': passwordController.text,
      }),
    );

    if (response.statusCode == 201) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const LoginOrRegister(),
        ),
      );
    } else {
      // Tangani error, misalnya tampilkan pesan error
      print('Login gagal: ${response.body}');
      setState(() {
        _errorMessage = json.decode(response.body)['message'];
      });
    }
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
            color: Colors.grey.withOpacity(0.2),
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
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back,
              color: Color.fromARGB(255, 176, 176, 176)),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Sign Up',
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
                    'Sign up now and enjoy OTOBOOK privileges never existed before.',
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
                Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildTextFormField(
                      controller: usernameController,
                      label: 'Username',
                      keyboardType: TextInputType.text,
                      validator: (value) => value == null || value.isEmpty
                          ? 'Please enter your username'
                          : null,
                    ),
                    const SizedBox(height: 16.0),
                    _buildTextFormField(
                      controller: emailController,
                      label: 'Email',
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) => value == null || value.isEmpty
                          ? 'Please enter your email'
                          : null,
                    ),
                    const SizedBox(height: 16.0),
                    _buildTextFormField(
                      controller: passwordController,
                      label: 'Password',
                      obscureText: _obscureText,
                      suffixIcon: IconButton(
                        icon: Icon(_obscureText
                            ? Icons.visibility_off
                            : Icons.visibility),
                        onPressed: () {
                          setState(() {
                            _obscureText = !_obscureText;
                          });
                        },
                      ),
                      validator: (value) => value == null || value.isEmpty
                          ? 'Please enter a password'
                          : null,
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: () {
                        register();
                      },
                      child: Text('Sign Up',
                          style: const TextStyle(
                            color: Colors.white,
                          )),
                      
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3C83F5),
                        minimumSize: const Size(double.infinity, 50),
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Already have an account? Sign In ',
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
                            'Sign In',
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



// Fungsi login():
//     Mengirim permintaan POST dengan email dan password
//     Jika berhasil (status 200):
//         Simpan data token
//         Navigasi ke halaman utama
//     Jika gagal:
//         Tampilkan pesan error
// Fungsi register():
// Mengirim permintaan POST untuk mendaftarkan pengguna
// Jika berhasil (201), navigasi ke halaman login
// Jika gagal, tampilkan pesan error
