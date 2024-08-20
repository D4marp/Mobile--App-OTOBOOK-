import 'package:flutter/material.dart';
import 'package:Otobook/models/book.dart';

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

      // Replace Firestore operation with local state update or any other operation
      // For now, just pop the screen
      Navigator.pop(context, updatedBook);
    }
  }

  void _addNewBook() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final _newTitleController = TextEditingController();
        final _newAuthorController = TextEditingController();
        final _newPublisherController = TextEditingController();
        final _newYearController = TextEditingController();
        final _newIsbnController = TextEditingController();

        return AlertDialog(
          title: Text('Add New Book'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                _buildTextField(_newTitleController, 'Title', 'Please enter the title'),
                SizedBox(height: 16.0),
                _buildTextField(_newAuthorController, 'Author', 'Please enter the author'),
                SizedBox(height: 16.0),
                _buildTextField(_newPublisherController, 'Publisher', 'Please enter the publisher'),
                SizedBox(height: 16.0),
                _buildTextField(_newYearController, 'Publication Year', 'Please enter the year of publication', keyboardType: TextInputType.number),
                SizedBox(height: 16.0),
                _buildTextField(_newIsbnController, 'ISBN', 'Please enter the ISBN'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final newBook = Book(
                  id: '', // You can handle ID creation locally or leave it for other purposes
                  title: _newTitleController.text,
                  author: _newAuthorController.text,
                  publisher: _newPublisherController.text,
                  publicationYear: int.parse(_newYearController.text),
                  ISBN: _newIsbnController.text,
                );

                // Replace Firestore operation with local state update or any other operation
                // For now, just close the dialog
                Navigator.pop(context, newBook);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('New book added successfully')),
                );
              },
              child: Text('Add Book'),
            ),
          ],
        );
      },
    );
  }

  void _deleteBook() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Deletion'),
          content: Text('Are you sure you want to delete this book?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                // Replace Firestore operation with local state update or any other operation
                // For now, just pop the screen
                Navigator.pop(context);
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
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
                style: ElevatedButton.styleFrom(),
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _addNewBook,
                child: Text('Add New Book'),
                style: ElevatedButton.styleFrom(),
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
