import 'package:flutter/material.dart';
import 'package:otobook/helper/verso_scanner.dart';
import 'package:otobook/pages/addKDT_page.dart';
import 'package:otobook/pages/daftarIsi_page.dart';

class IconRowWidget extends StatelessWidget {
  const IconRowWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 369,
      height: 103,
      padding:
          const EdgeInsets.symmetric(horizontal: 22), // Padding for spacing
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment:
            MainAxisAlignment.spaceBetween, // Evenly spaces items
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // buildIconColumn(context, 'Cover', Icons.book, Color(0xFF4894FE),
          //     CoverScannerScreen()),
          buildIconColumn(context, 'Verso', Icons.library_books,
              const Color(0xFF4894FE), const VersoScanner()),
          buildIconColumn(context, 'KDT', Icons.description,
              const Color(0xFF4894FE), const AddkdtPage()),
          buildIconColumn(context, 'Daftar Isi', Icons.list,
              const Color(0xFF4894FE), const DaftarisiPage()),
        ],
      ),
    );
  }

  Widget buildIconColumn(BuildContext context, String text, IconData icon,
      Color color, Widget page) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => page),
        );
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: ShapeDecoration(
              color: const Color(0xFFFAFAFA),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(100),
              ),
              shadows: [
                BoxShadow(
                  color: Color(0x3F000000),
                  blurRadius: 4,
                  offset: Offset(0, 4),
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Icon(
              icon,
              size: 24,
              color: color, // Applying the color
            ),
          ),
          const SizedBox(height: 8),
          Text(
            text,
            style: const TextStyle(
              color: Color(0xFF8696BB),
              fontSize: 15,
              fontFamily: 'Poppins',
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}
