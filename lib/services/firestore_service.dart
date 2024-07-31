import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:Otobook/models/user.dart';
import 'package:Otobook/models/book.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;


  // Add a new user
  Future<void> addUser(User user) async {
    try {
      await _db.collection('users').doc(user.id).set(user.toMap());
    } catch (e) {
      print('Error adding user: $e');
    }
  }

  // Add a new book
  Future<void> addBook(Book book) async {
    try {
      await _db.collection('books').doc(book.id).set(book.toMap());
    } catch (e) {
      print('Error adding book: $e');
    }
  }

  // Get a user by ID
  Future<User?> getUser(String id) async {
    try {
      var doc = await _db.collection('users').doc(id).get();
      if (doc.exists) {
        return User.fromMap(doc.data()!);
      }
    } catch (e) {
      print('Error getting user: $e');
    }
    return null;
  }

  // Get all books
  Future<List<Book>> getAllBooks() async {
    try {
      var querySnapshot = await _db.collection('books').get();
      return querySnapshot.docs.map((doc) => Book.fromMap(doc.data() as Map<String, dynamic>)).toList();
    } catch (e) {
      print('Error getting books: $e');
      return [];
    }
  }

  // Get a book by ID
  Future<Book?> getBookById(String id) async {
    try {
      var doc = await _db.collection('books').doc(id).get();
      if (doc.exists) {
        return Book.fromMap(doc.data()!);
      }
    } catch (e) {
      print('Error getting book: $e');
    }
    return null;
  }

  // Update an existing book
  Future<void> updateBook(Book book) async {
    try {
      await _db.collection('books').doc(book.id).update(book.toMap());
    } catch (e) {
      print('Error updating book: $e');
    }
  }

  // Delete a book by ID
  Future<void> deleteBook(String id) async {
    try {
      await _db.collection('books').doc(id).delete();
    } catch (e) {
      print('Error deleting book: $e');
    }
  }

  // Update a user
  Future<void> updateUser(User user) async {
    try {
      await _db.collection('users').doc(user.id).update(user.toMap());
    } catch (e) {
      print('Error updating user: $e');
    }
  }

  // Delete a user
  Future<void> deleteUser(String id) async {
    try {
      await _db.collection('users').doc(id).delete();
    } catch (e) {
      print('Error deleting user: $e');
    }
  }
}
