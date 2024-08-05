import 'dart:convert';
import 'package:http/http.dart' as http;

class GPT4Service {
  static Future<List<String>> classifyKeywords(String synopsis) async {
    final apiKey = 'sk-proj-fEw8eDsSI3HDEHXQjZXlT3BlbkFJIrutHzHNUdwkb91cHRE4';

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
