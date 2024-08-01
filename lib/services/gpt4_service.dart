import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GPT4Service {
  static Future<Map<String, dynamic>> extractBookDetails(String text) async {
    await dotenv.load(fileName: '.env');
    final apiKey = dotenv.env['OPENAI_API_KEY'];
    
    if (apiKey == null) {
      throw Exception('API key is not available');
    }

    final response = await http.post(
      Uri.parse('https://api.openai.com/v1/completions'),
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'model': 'gpt-4',
        'prompt': 'Extract book details including title, author, publisher, publication year, and ISBN. Also, generate a list of relevant keywords from the synopsis: $text',
        'max_tokens': 500,
      }),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      if (data.containsKey('choices') && data['choices'].isNotEmpty) {
        final String responseText = data['choices'][0]['text'].trim();
        try {
          return json.decode(responseText);
        } catch (e) {
          throw Exception('Failed to parse response: $e');
        }
      } else {
        throw Exception('Unexpected API response format');
      }
    } else {
      throw Exception('Failed to extract book details, status code: ${response.statusCode}');
    }
  }

  static Future<List<String>> classifyKeywords(String synopsis) async {
    await dotenv.load(fileName: '.env');
    final apiKey = dotenv.env['OPENAI_API_KEY'];
    
    if (apiKey == null) {
      throw Exception('API key is not available');
    }

    final response = await http.post(
      Uri.parse('https://api.openai.com/v1/completions'),
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'model': 'gpt-4',
        'prompt': 'Given the following book synopsis, provide a list of relevant keywords: $synopsis',
        'max_tokens': 100,
      }),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      if (data.containsKey('choices') && data['choices'].isNotEmpty) {
        final String responseText = data['choices'][0]['text'].trim();
        try {
          return responseText.split(',').map((e) => e.trim()).toList();
        } catch (e) {
          throw Exception('Failed to parse response: $e');
        }
      } else {
        throw Exception('Unexpected API response format');
      }
    } else {
      throw Exception('Failed to classify keywords, status code: ${response.statusCode}');
    }
  }
}
