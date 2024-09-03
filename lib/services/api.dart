import 'package:http/http.dart' as http;
import 'package:Otobook/models/masterBook.dart';
import 'dart:convert';

class GetData {
  final String _apiUrl = 'http://192.168.9.54:5000/api/';

  String get Url => 'http://192.168.9.54:5000';

  // login user
  String get loginUrl => '${_apiUrl}login';

  // logout user
  String get logoutUrl => '${_apiUrl}logout';

  // get user Id
  String get getUserIdUrl => '${_apiUrl}getUser';

  // register user
  String get registerUrl => '${_apiUrl}register';

  // edit user by id
  String get editUserByIdUrl => '${_apiUrl}editUser';

  // add new book
  String get addBookUrl => '${_apiUrl}addBuku';

  // get book by id
  String get getBookUrl => '${_apiUrl}getBuku';

  // update book
  String get updateBookUrl => '${_apiUrl}editBuku';

  // delete book
  String get deleteBookUrl => '${_apiUrl}deleteBuku';

  // add cover book
  String get addCoverUrl => '${_apiUrl}uploadCover';

  // get cover book
  String get getCoverUrl => '${_apiUrl}getCover';

  // get sinopsis book
  String get getSinopsisUrl => '${_apiUrl}getSinopsis';

  // add sinopsis book
  String get addSinopsisUrl => '${_apiUrl}addSinopsis/';

  // get klassifikasi book
  String get getKlasifikasiUrl => '${_apiUrl}getklasifikasi';

  // get book and sinopsis
  String get getBookWithSinopsisUrl => '${_apiUrl}getBookSinopsis/';

  // edit sinopsis and book
  String get editBookSinopsisUrl => '${_apiUrl}editBookSinopsis/';

  // search book
  String get searchBookUrl => '${_apiUrl}searchBuku';

  static const String baseUrl = 'http://192.168.9.54:5000/api/getBuku';
  static const String sinopsisUrl = 'http://192.168.9.54:5000/api/getSinopsis';

  // Fetch data buku
  static Future<List<masterBook>> getBooks() async {
    try {
      final response = await http.get(Uri.parse(baseUrl));

      if (response.statusCode == 200) {
        final body = response.body;
        final result = jsonDecode(body);

        if (result['data'] != null) {
          List<masterBook> books = List<masterBook>.from(
              result['data'].map((i) => masterBook.fromJson(i)));
          return books;
        } else {
          throw Exception('Data not found in the response.');
        }
      } else {
        throw Exception(
            'Failed to load books. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching books: ${e.toString()}');
    }
  }

  // Fetch data sinopsis by ID
  static Future<masterBook> getBookWithSinopsis(int id) async {
    try {
      // Fetch book data
      final bookResponse = await http.get(Uri.parse('$baseUrl/$id'));

      if (bookResponse.statusCode == 200) {
        final bookData = jsonDecode(bookResponse.body);

        // Fetch sinopsis data
        final sinopsisResponse = await http.get(Uri.parse('$sinopsisUrl/$id'));

        if (sinopsisResponse.statusCode == 200) {
          final sinopsisData = jsonDecode(sinopsisResponse.body);

          return masterBook.fromJson({
            ...bookData,
            'sinopsis': sinopsisData['sinopsis'],
            'keyword': sinopsisData['keyword'],
          });
        } else {
          // If sinopsis is not found, return book data only
          return masterBook.fromJson(bookData);
        }
      } else {
        throw Exception(
            'Failed to load book data. Status code: ${bookResponse.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching book and sinopsis: ${e.toString()}');
    }
  }
}
