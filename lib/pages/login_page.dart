import 'package:flutter/material.dart';
import 'package:otobook/models/api.dart';
import 'package:otobook/navigation.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class LoginPage extends StatefulWidget {
  final void Function()? ontap;

  const LoginPage({super.key, this.ontap});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _obscureText = true;
  String? _errorMessage;

  Future<void> login() async {
    final response = await http.post(
      Uri.parse(GetData().loginUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'email': emailController.text,
        'password': passwordController.text,
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      String token = data['access_token'];

      // Simpan token menggunakan SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);

      // Arahkan ke halaman home atau yang sesuai
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const NavigationMenu(),
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
          'Sign In',
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
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(
              width: double.infinity,
              child: Opacity(
                opacity: 0.50,
                child: Text(
                  'Sign in now and enjoy OTOBOOK privileges never existed before.',
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
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildTextField(
                    controller: emailController,
                    label: 'Email',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      return null;
                    },
                  ),
                  _buildTextField(
                    controller: passwordController,
                    label: 'Password',
                    obscureText: _obscureText,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      return null;
                    },
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
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        // Navigate to forget password page
                      },
                      child: const Text(
                        'Forget Password?',
                        style: TextStyle(
                          color: Color(0xFF3C83F5),
                          fontSize: 12,
                          fontFamily: 'Montserrat',
                          letterSpacing: 0.07,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    child: const Text(
                      'Sign In',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3C83F5),
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    onPressed: login,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Don\'t have an account? ',
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
                          'Sign Up',
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
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    bool obscureText = false,
    String? Function(String?)? validator,
    Widget? suffixIcon,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
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
        obscureText: obscureText,
        validator: validator,
      ),
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
