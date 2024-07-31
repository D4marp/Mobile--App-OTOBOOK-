import 'package:google_ml_kit/google_ml_kit.dart';

class OCRService {
  static final _textDetector = GoogleMlKit.vision.textDetector();

  // Extract text from the image
  static Future<String> extractTextFromImage(String imagePath) async {
    if (imagePath.isEmpty) {
      print('Invalid image path.');
      return '';
    }

    final inputImage = InputImage.fromFilePath(imagePath);
    try {
      final recognisedText = await _textDetector.processImage(inputImage);

      // Extracting text from the recognised text
      return recognisedText.text;
    } catch (e) {
      print('Error processing image: $e');
      return 'Error: Failed to extract text from image';
    }
  }

  // Dispose the text detector when no longer needed
  static void dispose() {
    _textDetector.close();
  }
}
