import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GPT4Service {
  static Future<Map<String, dynamic>> extractBookDetails(String text) async {
    await dotenv.load(fileName: '.env');
    final response = await http.post(
      Uri.parse('https://api.openai.com/v1/completions'),
      headers: {
        'Authorization': 'Bearer ${dotenv.env['OPENAI_API_KEY']}',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'model': 'gpt-4',
        'prompt': 'Extract book details including title, author, publisher, publication year, ISBN, synopsis, and keywords from the following text: $text',
        'max_tokens': 500,
      }),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      if (data.containsKey('choices') && data['choices'].isNotEmpty) {
        // Assuming the model returns a structured JSON in the 'text' field of the first choice
        final String responseText = data['choices'][0]['text'];
        return json.decode(responseText);
      } else {
        throw Exception('Unexpected API response format');
      }
    } else {
      throw Exception('Failed to extract book details, status code: ${response.statusCode}');
    }
  }
}


