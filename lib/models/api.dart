import 'package:http/http.dart' as http;
import 'package:otobook/models/masterBook.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

String apiUrl = 'http://192.168.9.63:5000';

class API {
  Future<http.Response> postRequest({
    required String route,
    required Map<String, dynamic> data,
  }) async {
    String url = apiUrl + route;
    try {
      final headers = await _header();
      return await http.post(
        Uri.parse(url),
        body: jsonEncode(data),
        headers: headers,
      );
    } catch (e) {
      print(e.toString());
      // Mengembalikan response dengan status gagal
      return http.Response(jsonEncode({'error': e.toString()}), 500);
    }
  }

  Future<Map<String, String>> _header() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }
}

class GetData {
  static const String baseUrl = 'http://192.168.9.63:5000/api/getBuku';
  static const String sinopsisUrl = 'http://192.168.9.63:5000/api/getSinopsis';

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
