import 'package:flutter/material.dart';
// Import your actual page files
import 'package:Otobook/screens/verso_scan.dart';
import 'package:Otobook/screens/kdt_scan.dart';
import 'package:Otobook/screens/daftar_isi_scan.dart';
import 'package:Otobook/screens/tajuk_subject.dart';

class IconRowWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          buildIconColumn(
              context, 'Verso', Icons.library_books, Colors.blue, VersoScanner()),
          buildIconColumn(context, 'KDT', Icons.description, Colors.blue, KDTScannerScreen()),
         
          buildIconColumn(context, 'Tajuk Subjek', Icons.add_box, Colors.blue, TajukSubject()),
        ],
      ),
    );
  }

  Widget buildIconColumn(BuildContext context, String text, IconData icon, Color color, Widget page) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => page),
        );
      },
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color.withOpacity(0.8), color],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.4),
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              icon,
              size: 32,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            text,
            style: TextStyle(
              color: Colors.black87,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
