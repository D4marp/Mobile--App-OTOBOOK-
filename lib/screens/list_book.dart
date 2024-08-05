import 'package:flutter/material.dart';
import 'package:Otobook/models/book.dart';
import 'package:Otobook/screens/edit_book.dart';
import 'package:Otobook/services/firestore_service.dart';

class ListBooksScreen extends StatefulWidget {
  @override
  _ListBooksScreenState createState() => _ListBooksScreenState();
}

class _ListBooksScreenState extends State<ListBooksScreen> {
  late Future<List<Book>> _books;

  @override
  void initState() {
    super.initState();
    _loadBooks();
  }

  void _loadBooks() {
    setState(() {
      _books = FirestoreService().getAllBooks();
    });
  }

  void _deleteBook(String bookId) async {
    try {
      await FirestoreService().deleteBook(bookId);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Book deleted successfully')),
      );
      _loadBooks(); // Refresh the list of books
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete book: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Books List'),
        automaticallyImplyLeading: false, // Menghilangkan arrow back
      ),
      body: FutureBuilder<List<Book>>(
        future: _books,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No books available'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              Book book = snapshot.data![index];
              return ListTile(
                title: Text(book.title),
                subtitle: Text(book.author),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditBookScreen(book: book),
                          ),
                        ).then((_) {
                          // Refresh the list when coming back from the edit screen
                          _loadBooks();
                        });
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        // Konfirmasi sebelum menghapus
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text('Delete Book'),
                            content: Text('Are you sure you want to delete this book?'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  _deleteBook(book.id);
                                },
                                child: Text('Delete'),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
