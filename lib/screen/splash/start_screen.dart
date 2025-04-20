
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:otobook/services/auth_service.dart';

class StartScreen extends StatelessWidget {
  const StartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                'assets/pic1.svg', // Path to the SVG image in assets
                height: 180,
              ),
              const SizedBox(height: 20),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/logo_oto.PNG', // Path to the PNG image in assets
                        height: 38,
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text(
                          'adalah aplikasi Pembaca otomatis metadata buku untuk koleksi buku di Perpustakaan',
                          textAlign: TextAlign.left,
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AuthGate(),
                      ),
                    );
                  },
                  style: ButtonStyle(
                    // ignore: deprecated_member_use
                    backgroundColor: MaterialStateProperty.all<Color>(
                      const Color.fromRGBO(0, 179, 255, 1),
                    ),
                    // ignore: deprecated_member_use
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30), // Tidak ada pembulatan, sudut lancip
                      ),
                    ),
                  ),
                  child: Container(
                    width: double.infinity,
                    height: 50,
                    alignment: Alignment.center,
                    child: const Text(
                      'Masuk',
                      style: TextStyle(color: Colors.white), // Warna teks putih
                    ),
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

