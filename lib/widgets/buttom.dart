import 'package:flutter/material.dart';

class IconRowWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 369,
      height: 103,
      padding: const EdgeInsets.symmetric(horizontal: 22), // Padding for spacing
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween, // Evenly spaces items
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildIconColumn('Cover', Icons.book, Color(0xFF4894FE)), // Using the color
          buildIconColumn('Verso', Icons.library_books, Color(0xFF4894FE)), // Using the color
          buildIconColumn('KDT', Icons.description, Color(0xFF4894FE)), // Using the color
          buildIconColumn('Daftar Isi', Icons.list, Color(0xFF4894FE)), // Using the color
        ],
      ),
    );
  }

  Widget buildIconColumn(String text, IconData icon, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: ShapeDecoration(
            color: Color(0xFFFAFAFA),
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
          style: TextStyle(
            color: Color(0xFF8696BB),
            fontSize: 15,
            fontFamily: 'Poppins',
            height: 1.2,
          ),
        ),
      ],
    );
  }
}
