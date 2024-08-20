import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class DaftarisiPage extends StatefulWidget {
  const DaftarisiPage({super.key});

  @override
  State<DaftarisiPage> createState() => _DaftarisiPageState();
}

class _DaftarisiPageState extends State<DaftarisiPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'Coming Soon',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.grey[700],
          ),
        ),
      ),
    );
  }
}
