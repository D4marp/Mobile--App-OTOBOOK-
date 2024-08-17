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
        automaticallyImplyLeading: false, // Hide the back arrow
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

          return LayoutBuilder(
            builder: (context, constraints) {
              // Adjust number of columns and aspect ratio based on screen width
              int crossAxisCount = 1;
              double aspectRatio = 2 / 3; // Default aspect ratio for mobile

              if (constraints.maxWidth >= 600) {
                crossAxisCount = 2; // Two columns for tablets and small screens
              }
              if (constraints.maxWidth >= 900) {
                crossAxisCount = 3; // Three columns for medium screens
              }
              if (constraints.maxWidth >= 1200) {
                crossAxisCount = 4; // Four columns for large screens
              }

              // Aspect ratio adjustments
              if (constraints.maxWidth >= 600) {
                aspectRatio = 1.5; // Adjust aspect ratio for larger screens
              }
              if (constraints.maxWidth >= 900) {
                aspectRatio = 1.4; // Further adjust aspect ratio
              }
              if (constraints.maxWidth >= 1200) {
                aspectRatio = 1.2; // Adjust aspect ratio for very large screens
              }

              return GridView.builder(
                padding: const EdgeInsets.all(10.0),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  childAspectRatio: aspectRatio,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  Book book = snapshot.data![index];
                  return Card(
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0), // Reduced padding
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            book.title,
                            style: TextStyle(
                              fontSize: 16, // Adjusted font size
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text('Author: ${book.author}', style: TextStyle(fontSize: 14)), // Adjusted font size
                          Spacer(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Adjusted alignment
                            children: [
                              ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => EditBookScreen(book: book),
                                    ),
                                  ).then((_) {
                                    _loadBooks(); // Refresh list after editing
                                  });
                                },
                                icon: Icon(Icons.edit),
                                label: Text('Edit', style: TextStyle(fontSize: 14)), // Adjusted font size
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  padding: EdgeInsets.symmetric(horizontal: 10), // Adjusted padding
                                ),
                              ),
                              ElevatedButton.icon(
                                onPressed: () {
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
                                icon: Icon(Icons.delete),
                                label: Text('Delete', style: TextStyle(fontSize: 14)), // Adjusted font size
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  padding: EdgeInsets.symmetric(horizontal: 10), // Adjusted padding
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
