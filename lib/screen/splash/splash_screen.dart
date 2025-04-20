import 'package:flutter/material.dart';
import 'dart:async';

import 'package:otobook/screen/splash/start_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Menambahkan delay 3 detik untuk tampilan splash screen
    Timer(Duration(seconds: 3), () {
      // Ganti layar ke StartScreen setelah splash screen
      Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => StartScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Latar belakang splash screen putih
      body: Center(
        child: Image.asset('assets/Splash_oto.png'), // Gambar splash screen
      ),
    );
  }
}
