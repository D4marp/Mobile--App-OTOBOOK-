import 'package:flutter/material.dart';
import 'package:Otobook/models/book.dart';
import 'package:Otobook/services/firestore_service.dart';

class EditBookScreen extends StatefulWidget {
  final Book book;

  const EditBookScreen({Key? key, required this.book}) : super(key: key);

  @override
  _EditBookScreenState createState() => _EditBookScreenState();
}

class _EditBookScreenState extends State<EditBookScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _judulController;
  late TextEditingController _pengarangController;
  late TextEditingController _penerbitController;
  late TextEditingController _tahunTerbitController;
  late TextEditingController _isbnController;
  late TextEditingController _sinopsisController;
  late TextEditingController _keywordController;

  @override
  void initState() {
    super.initState();
    _judulController = TextEditingController(text: widget.book.title);
    _pengarangController = TextEditingController(text: widget.book.author);
    _penerbitController = TextEditingController(text: widget.book.publisher);
    _tahunTerbitController = TextEditingController(text: widget.book.publicationYear.toString());
    _isbnController = TextEditingController(text: widget.book.ISBN);
  
  }

  @override
  void dispose() {
    _judulController.dispose();
    _pengarangController.dispose();
    _penerbitController.dispose();
    _tahunTerbitController.dispose();
    _isbnController.dispose();
 
    super.dispose();
  }

  void _updateBook() {
    if (_formKey.currentState?.validate() ?? false) {
      final updatedBook = Book(
        id: widget.book.id,
        title: _judulController.text,
        author: _pengarangController.text,
        publisher: _penerbitController.text,
        publicationYear: int.parse(_tahunTerbitController.text),
        ISBN: _isbnController.text,
      
      );

      FirestoreService().updateBook(updatedBook).then((_) {
        Navigator.pop(context); // Go back to the previous screen
      });
    }
  }

  void _deleteBook() {
    FirestoreService().deleteBook(widget.book.id).then((_) {
      Navigator.pop(context); // Go back to the previous screen
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Book'),
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: _deleteBook,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildTextField(_judulController, 'Judul', 'Please enter the title'),
              SizedBox(height: 16.0),
              _buildTextField(_pengarangController, 'Pengarang', 'Please enter the author'),
              SizedBox(height: 16.0),
              _buildTextField(_penerbitController, 'Penerbit', 'Please enter the publisher'),
              SizedBox(height: 16.0),
              _buildTextField(_tahunTerbitController, 'Tahun Terbit', 'Please enter the year of publication', keyboardType: TextInputType.number),
              SizedBox(height: 16.0),
              _buildTextField(_isbnController, 'ISBN', 'Please enter the ISBN'),
              SizedBox(height: 16.0),
             
              ElevatedButton(
                onPressed: _updateBook,
                child: Text('Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String labelText, String validationMessage, {TextInputType keyboardType = TextInputType.text}) {
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
      keyboardType: keyboardType,
    );
  }
}
