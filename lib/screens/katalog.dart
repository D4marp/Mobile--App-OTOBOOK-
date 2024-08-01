import 'package:flutter/material.dart';
import 'package:Otobook/models/book.dart';
import 'package:Otobook/services/firestore_service.dart';
import 'package:Otobook/screens/start.dart';

class KatalogScreen extends StatefulWidget {
  const KatalogScreen({super.key});

  @override
  State<KatalogScreen> createState() => _KatalogScreenState();
}

class _KatalogScreenState extends State<KatalogScreen> {
  final _formKey = GlobalKey<FormState>(); // Key to manage form state

  // Controllers for form fields
  final TextEditingController _judulController = TextEditingController();
  final TextEditingController _pengarangController = TextEditingController();
  final TextEditingController _penerbitController = TextEditingController();
  final TextEditingController _tahunTerbitController = TextEditingController();
  final TextEditingController _isbnController = TextEditingController();
 

  @override
  void dispose() {
    // Dispose controllers when the widget is removed
    _judulController.dispose();
    _pengarangController.dispose();
    _penerbitController.dispose();
    _tahunTerbitController.dispose();
    _isbnController.dispose();
   
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(20.0),
              ),
            ),
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SizedBox(
                    width: 150,
                    child: ElevatedButton(
                      onPressed: () {
                        print('Add Books button pressed');
                      },
                      child: Text('Add Books'),
                    ),
                  ),
                ),
                Spacer(),
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => StartScreen()),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Image.asset(
                        'assets/logo_oto.PNG',
                        height: 40,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTextField(_judulController, 'Judul', 'Please enter the title'),
                    SizedBox(height: 16.0),
                    _buildTextField(_pengarangController, 'Pengarang', 'Please enter the author'),
                    SizedBox(height: 16.0),
                    _buildTextField(_penerbitController, 'Penerbit', 'Please enter the publisher'),
                    SizedBox(height: 16.0),
                    _buildTextField(_tahunTerbitController, 'Tahun Terbit', 'Please enter the year of publication'),
                    SizedBox(height: 16.0),
                    _buildTextField(_isbnController, 'ISBN', 'Please enter the ISBN'),
                    SizedBox(height: 16.0),
              
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton(
                        onPressed: _submitForm,
                        child: Text('Submit'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String labelText, String validationMessage) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        border: OutlineInputBorder(),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return validationMessage;
        }
        return null;
      },
    );
  }

  void _submitForm() {
    if (_formKey.currentState?.validate() ?? false) {
      final book = Book(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: _judulController.text,
        author: _pengarangController.text,
        publisher: _penerbitController.text,
        publicationYear: int.tryParse(_tahunTerbitController.text) ?? 0,
        ISBN: _isbnController.text,
    
      );

      FirestoreService().addBook(book);

      // Clear form
      _formKey.currentState?.reset();
    }
  }
}
