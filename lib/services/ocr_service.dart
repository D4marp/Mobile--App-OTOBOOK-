import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class OCRService {
  static final _textRecognizer = TextRecognizer();

  // Ekstrak teks dari gambar
  static Future<String> extractTextFromImage(String imagePath) async {
    if (imagePath.isEmpty) {
      print('Invalid image path.');
      return '';
    }

    final inputImage = InputImage.fromFilePath(imagePath);
    try {
      final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);

      // Ekstraksi teks dari teks yang dikenali
      return recognizedText.text;
    } catch (e) {
      print('Error processing image: $e');
      return 'Error: Failed to extract text from image';
    }
  }

  // Dispose text recognizer ketika tidak lagi dibutuhkan
  static void dispose() {
    _textRecognizer.close();
  }
}
