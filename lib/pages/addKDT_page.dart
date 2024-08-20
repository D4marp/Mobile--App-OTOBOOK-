import 'package:flutter/material.dart';

class AddkdtPage extends StatefulWidget {
  const AddkdtPage({super.key});

  @override
  State<AddkdtPage> createState() => _AddkdtPageState();
}

class _AddkdtPageState extends State<AddkdtPage> {
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
