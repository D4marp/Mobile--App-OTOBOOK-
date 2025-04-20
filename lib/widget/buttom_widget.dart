
import 'package:flutter/material.dart';
import 'package:otobook/screen/book/klasifikasi_buku.dart';
import 'package:otobook/screen/camera/isbn_scan.dart';
import 'package:otobook/screen/camera/kdt_scan.dart';

import 'package:otobook/screen/camera/verso_scan.dart';

class IconRowWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Fitur Utama',
            style: TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildActionButton(
                context,
                icon: Icons.library_books,
                label: 'Verso',
                color: Color(0xFF6A11CB),
                page: VersoScanner(autoPress: true),
              ),
              _buildActionButton(
                context,
                icon: Icons.description,
                label: 'KDT',
                color: Color(0xFF2575FC),
                page: KDTScannerScreen(autoPress: true),
              ),
              _buildActionButton(
                context,
                icon: Icons.search,
                label: 'ISBN',
                color: Color(0xFF00C6FF),
                page: ISBNScanPage(),
              ),
              _buildActionButton(
                context,
                icon: Icons.category,
                label: 'Subjek',
                color: Color(0xFF00BFA5),
                page: Klasifikasibuku(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required Widget page,
  }) {
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
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 10,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Icon(
              icon,
              size: 32,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: Colors.black87,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}