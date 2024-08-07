import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:Otobook/models/user.dart';
import 'package:Otobook/models/book.dart';
import 'package:retry/retry.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final RetryOptions _retryOptions = RetryOptions(maxAttempts: 5);

  // Add a new user
  Future<void> addUser(User user) async {
    try {
      await _retryOptions.retry(
        () => _db.collection('users').doc(user.id).set(user.toMap(), SetOptions(merge: true)),
        retryIf: (e) => e is FirebaseException && e.code == 'unavailable',
      );
    } catch (e) {
      print('Error adding user: $e');
    }
  }

  // Get a user by ID
  Future<User?> getUser(String id) async {
    try {
      var doc = await _retryOptions.retry(
        () => _db.collection('users').doc(id).get(GetOptions(source: Source.server)),
        retryIf: (e) => e is FirebaseException && e.code == 'unavailable',
      );
      if (doc.exists) {
        return User.fromMap(doc.data()!);
      }
    } catch (e) {
      print('Error getting user: $e');
    }
    return null;
  }

  // Update a user
  Future<void> updateUser(User user) async {
    try {
      await _retryOptions.retry(
        () => _db.collection('users').doc(user.id).update(user.toMap()),
        retryIf: (e) => e is FirebaseException && e.code == 'unavailable',
      );
    } catch (e) {
      print('Error updating user: $e');
    }
  }

  // Delete a user
  Future<void> deleteUser(String id) async {
    try {
      await _retryOptions.retry(
        () => _db.collection('users').doc(id).delete(),
        retryIf: (e) => e is FirebaseException && e.code == 'unavailable',
      );
    } catch (e) {
      print('Error deleting user: $e');
    }
  }

  // Add a new book
  Future<void> addBook(Book book) async {
    try {
      await _retryOptions.retry(
        () => _db.collection('books').doc(book.id).set(book.toMap(), SetOptions(merge: true)),
        retryIf: (e) => e is FirebaseException && e.code == 'unavailable',
      );
    } catch (e) {
      print('Error adding book: $e');
    }
  }

  // Get all books
  Future<List<Book>> getAllBooks() async {
    try {
      var querySnapshot = await _retryOptions.retry(
        () => _db.collection('books').get(GetOptions(source: Source.server)),
        retryIf: (e) => e is FirebaseException && e.code == 'unavailable',
      );
      return querySnapshot.docs.map((doc) => Book.fromMap(doc.data() as Map<String, dynamic>)).toList();
    } catch (e) {
      print('Error getting books: $e');
      return [];
    }
  }

  // Get a book by ID
  Future<Book?> getBookById(String id) async {
    try {
      var doc = await _retryOptions.retry(
        () => _db.collection('books').doc(id).get(GetOptions(source: Source.server)),
        retryIf: (e) => e is FirebaseException && e.code == 'unavailable',
      );
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
      await _retryOptions.retry(
        () => _db.collection('books').doc(book.id).update(book.toMap()),
        retryIf: (e) => e is FirebaseException && e.code == 'unavailable',
      );
    } catch (e) {
      print('Error updating book: $e');
    }
  }

  // Delete a book by ID
  Future<void> deleteBook(String id) async {
    try {
      await _retryOptions.retry(
        () => _db.collection('books').doc(id).delete(),
        retryIf: (e) => e is FirebaseException && e.code == 'unavailable',
      );
    } catch (e) {
      print('Error deleting book: $e');
    }
  }
}
