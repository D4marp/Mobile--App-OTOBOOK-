import 'package:http/http.dart' as http;
import 'package:otobook/models/master_book_response_model.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class GetData {
  final String _apiUrl = 'http://118.97.240.83:5042/api/';
  Future<String?> _userId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('id');
  }

  String get Url => 'http://118.97.240.83:5042';

  Future<String?> _token() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<String?> _refreshToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('refresh_token');
  }

  String get downloadExcelUrl => '${_apiUrl}download';
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
  String get addBookUrl => '${_apiUrl}addBuku/';

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
  String get editBookSinopsisUrl => '${_apiUrl}editBookSinopsis';

  // add klasifikasi book
  String get addKlasifikasiUrl => '${_apiUrl}addKlasfikasi';

  // search book
  String get searchBookUrl => '${_apiUrl}searchBuku';

  // search klasifikasi
  String get searchKlasifikasiUrl => '${_apiUrl}searchKlasifikasi';

  // get klassifikasi by id
  String get getKlasifikasiByIdUrl => '${_apiUrl}getKlasifikasiBuku';

  // Update klasifikasi
  String get updateKlasifikasiUrl => '${_apiUrl}editKlasifikasi';

  // Delete klasifikasi
  String get deleteKlasifikasiUrl => '${_apiUrl}deleteKlasifikasi';

  // get all books
  static const String baseUrl = 'http://118.97.240.83:5042/api/getBuku';
  // get all books diproses
  static const String bookProses = 'http://118.97.240.83:5042/api/BukuDiolah';
  // get all books diproses
  static const String bookDisumbangkan =
      'http://118.97.240.83:5042/api/BukuDisumbangkan';
  // get all books sinopsis
  static const String sinopsisUrl = 'http://118.97.240.83:5042/api/getSinopsis';
  // mendapatkan access tokenbaru
  Future<String?> refreshAccessToken() async {
    final response = await http.post(
      Uri.parse('${Url}/refresh'),
      headers: {'Authorization': 'Bearer ${await _refreshToken()}'},
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final newAccessToken = data['access_token'];

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('access_token', newAccessToken);
    } else {
      throw Exception(
        'Failed to refresh token. Status code: ${response.statusCode}',
      );
    }
  }

  Future<String?> _accessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  // get all books
  static Future<List<masterBook>> getBooks() async {
    try {
      String? userId = await GetData()._userId();
      String? token = await GetData()._token();

      if (userId == null) {
        throw Exception('User ID not found.');
      }
      // print(GetData()._token());

      final response = await http.get(
        Uri.parse('$baseUrl?userId=$userId'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 401) {
        print(GetData()._accessToken());
        await GetData().refreshAccessToken();
        final newToken = await GetData()._accessToken();
        final newResponse = await http.get(
          Uri.parse('$baseUrl?userId=$userId'),
          headers: {'Authorization': 'Bearer $newToken'},
        );

        if (newResponse.statusCode == 200) {
          final body = newResponse.body;
          final result = jsonDecode(body);

          if (result['data'] != null) {
            List<masterBook> books = List<masterBook>.from(
              result['data'].map((i) => masterBook.fromJson(i)),
            );
            return books;
          } else {
            throw Exception('Data not found in the response.');
          }
        } else {
          throw Exception(
            'Failed to load books. Status code: ${newResponse.statusCode}',
          );
        }
      }

      if (response.statusCode == 200) {
        final body = response.body;
        final result = jsonDecode(body);

        if (result['data'] != null) {
          List<masterBook> books = List<masterBook>.from(
            result['data'].map((i) => masterBook.fromJson(i)),
          );
          return books;
        } else {
          throw Exception('Data not found in the response.');
        }
      } else {
        throw Exception(
          'Failed to load books. Status code: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error fetching books: ${e.toString()}');
    }
  }

  // get all books diperosos
  static Future<List<masterBook>> getBooksProses() async {
    try {
      String? userId = await GetData()._userId();
      String? token = await GetData()._token();

      if (userId == null) {
        throw Exception('User ID not found.');
      }
      // print(GetData()._token());

      final response = await http.get(
        Uri.parse('$bookProses?userId=$userId'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 401) {
        print(GetData()._accessToken());
        await GetData().refreshAccessToken();
        final newToken = await GetData()._accessToken();
        final newResponse = await http.get(
          Uri.parse('$bookProses?userId=$userId'),
          headers: {'Authorization': 'Bearer $newToken'},
        );

        if (newResponse.statusCode == 200) {
          final body = newResponse.body;
          final result = jsonDecode(body);

          if (result['data'] != null) {
            List<masterBook> books = List<masterBook>.from(
              result['data'].map((i) => masterBook.fromJson(i)),
            );
            return books;
          } else {
            throw Exception('Data not found in the response.');
          }
        } else {
          throw Exception(
            'Failed to load books. Status code: ${newResponse.statusCode}',
          );
        }
      }

      if (response.statusCode == 200) {
        final body = response.body;
        final result = jsonDecode(body);

        if (result['data'] != null) {
          List<masterBook> books = List<masterBook>.from(
            result['data'].map((i) => masterBook.fromJson(i)),
          );
          return books;
        } else {
          throw Exception('Data not found in the response.');
        }
      } else {
        throw Exception(
          'Failed to load books. Status code: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error fetching books: ${e.toString()}');
    }
  }

  // get all books disumbangkan
  static Future<List<masterBook>> getBooksDisumbangkan() async {
    try {
      String? userId = await GetData()._userId();
      String? token = await GetData()._token();

      if (userId == null) {
        throw Exception('User ID not found.');
      }
      // print(GetData()._token());

      final response = await http.get(
        Uri.parse('$bookDisumbangkan?userId=$userId'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 401) {
        print(GetData()._accessToken());
        await GetData().refreshAccessToken();
        final newToken = await GetData()._accessToken();
        final newResponse = await http.get(
          Uri.parse('$bookDisumbangkan?userId=$userId'),
          headers: {'Authorization': 'Bearer $newToken'},
        );

        if (newResponse.statusCode == 200) {
          final body = newResponse.body;
          final result = jsonDecode(body);

          if (result['data'] != null) {
            List<masterBook> books = List<masterBook>.from(
              result['data'].map((i) => masterBook.fromJson(i)),
            );
            return books;
          } else {
            throw Exception('Data not found in the response.');
          }
        } else {
          throw Exception(
            'Failed to load books. Status code: ${newResponse.statusCode}',
          );
        }
      }

      if (response.statusCode == 200) {
        final body = response.body;
        final result = jsonDecode(body);

        if (result['data'] != null) {
          List<masterBook> books = List<masterBook>.from(
            result['data'].map((i) => masterBook.fromJson(i)),
          );
          return books;
        } else {
          throw Exception('Data not found in the response.');
        }
      } else {
        throw Exception(
          'Failed to load books. Status code: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error fetching books: ${e.toString()}');
    }
  }

  // Fetch data sinopsis by ID
  static Future<masterBook> getBookWithSinopsis(int id) async {
    String? token = await GetData()._token();
    try {
      // print(token);
      // Fetch book data
      final bookResponse = await http.get(
        Uri.parse('$baseUrl/$id'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (bookResponse.statusCode == 200) {
        final bookData = jsonDecode(bookResponse.body);

        // Fetch sinopsis data
        final sinopsisResponse = await http.get(
          Uri.parse('$sinopsisUrl/$id'),
          headers: {'Authorization': 'Bearer $token'},
        );

        if (sinopsisResponse.statusCode == 200) {
          final sinopsisData = jsonDecode(sinopsisResponse.body);

          return masterBook.fromJson({
            ...bookData,
            'sinopsis': sinopsisData['sinopsis'],
            'keyword': sinopsisData['keyword'],
            'no_class': sinopsisData['no_class'],
          });
        } else {
          // If sinopsis is not found, return book data only
          return masterBook.fromJson(bookData);
        }
      } else {
        throw Exception(
          'Failed to load book data. Status code: ${bookResponse.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error fetching book and sinopsis: ${e.toString()}');
    }
  }

  //run-automation
  String get runAutomationUrl => '${_apiUrl}run-automation';
}
