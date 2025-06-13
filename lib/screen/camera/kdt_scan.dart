import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:otobook/services/ocr_service.dart';

class KDTScannerScreen extends StatefulWidget {
  final bool autoPress;

  const KDTScannerScreen({this.autoPress = false, super.key});

  @override
  _KDTScannerScreenState createState() => _KDTScannerScreenState();
}

class _KDTScannerScreenState extends State<KDTScannerScreen> 
    with SingleTickerProviderStateMixin {
  
  // Animation Controller
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    
    if (widget.autoPress) {
      Future.delayed(const Duration(milliseconds: 500), () {
        _scanAndExtract();
      });
    }
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _animationController.forward();
  }

  final ImagePicker _picker = ImagePicker();

  // Enhanced field controllers with better organization
  final Map<String, TextEditingController> _controllers = {
    'title': TextEditingController(),
    'author': TextEditingController(),
    'editor': TextEditingController(),
    'publisher': TextEditingController(),
    'publicationYear': TextEditingController(),
    'publicationPlace': TextEditingController(),
    'isbn': TextEditingController(),
    'edition': TextEditingController(),
    'physicalDescription': TextEditingController(),
    'series': TextEditingController(),
    'notes': TextEditingController(),
    'subjectHeadingI': TextEditingController(),
    'subjectHeadingII': TextEditingController(),
    'subjectHeadingIII': TextEditingController(),
    'bibliographyPage': TextEditingController(),
    'classification': TextEditingController(),
    'callNumber': TextEditingController(),
  };

  // Field information for better UI
  final Map<String, Map<String, dynamic>> _fieldInfo = {
    'title': {
      'label': 'Judul',
      'icon': Icons.title,
      'color': const Color(0xFF4A90E2),
      'section': 'basic',
    },
    'author': {
      'label': 'Pengarang',
      'icon': Icons.person,
      'color': const Color(0xFF26C6DA),
      'section': 'basic',
    },
    'editor': {
      'label': 'Editor',
      'icon': Icons.edit,
      'color': const Color(0xFF66BB6A),
      'section': 'basic',
    },
    'publisher': {
      'label': 'Penerbit',
      'icon': Icons.business,
      'color': const Color(0xFFFF7043),
      'section': 'publication',
    },
    'publicationYear': {
      'label': 'Tahun Terbit',
      'icon': Icons.calendar_today,
      'color': const Color(0xFF9C27B0),
      'section': 'publication',
    },
    'publicationPlace': {
      'label': 'Tempat Terbit',
      'icon': Icons.location_city,
      'color': const Color(0xFFFF5722),
      'section': 'publication',
    },
    'isbn': {
      'label': 'ISBN',
      'icon': Icons.tag,
      'color': const Color(0xFF795548),
      'section': 'identification',
    },
    'edition': {
      'label': 'Edisi',
      'icon': Icons.layers,
      'color': const Color(0xFF607D8B),
      'section': 'identification',
    },
    'physicalDescription': {
      'label': 'Deskripsi Fisik',
      'icon': Icons.description,
      'color': const Color(0xFFE91E63),
      'section': 'physical',
    },
    'series': {
      'label': 'Seri',
      'icon': Icons.collections_bookmark,
      'color': const Color(0xFF8BC34A),
      'section': 'classification',
    },
    'notes': {
      'label': 'Catatan',
      'icon': Icons.note,
      'color': const Color(0xFFFFB74D),
      'section': 'additional',
    },
    'subjectHeadingI': {
      'label': 'Tajuk Subjek I',
      'icon': Icons.subject,
      'color': const Color(0xFF81C784),
      'section': 'subjects',
    },
    'subjectHeadingII': {
      'label': 'Tajuk Subjek II',
      'icon': Icons.subject,
      'color': const Color(0xFF64B5F6),
      'section': 'subjects',
    },
    'subjectHeadingIII': {
      'label': 'Tajuk Subjek III',
      'icon': Icons.subject,
      'color': const Color(0xFFFFB74D),
      'section': 'subjects',
    },
    'bibliographyPage': {
      'label': 'Halaman Bibliografi',
      'icon': Icons.menu_book,
      'color': const Color(0xFFA1887F),
      'section': 'reference',
    },
    'classification': {
      'label': 'Klasifikasi',
      'icon': Icons.category,
      'color': const Color(0xFF90A4AE),
      'section': 'classification',
    },
    'callNumber': {
      'label': 'Nomor Panggil',
      'icon': Icons.confirmation_number,
      'color': const Color(0xFFCE93D8),
      'section': 'classification',
    },
  };

  bool _isLoading = false;
  bool _isProcessing = false;
  String _extractedText = '';
  XFile? _selectedImage;
  Map<String, double> _confidenceScores = {};

  @override
  void dispose() {
    _animationController.dispose();
    _controllers.values.forEach((controller) => controller.dispose());
    super.dispose();
  }

  Future<void> _scanAndExtract() async {
    await _showImageSourceSelector();
  }

  Future<XFile?> _showImageSourceSelector() async {
    return await showModalBottomSheet<XFile?>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 50,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Pilih Sumber Gambar KDT',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _buildSourceOption(
                      icon: Icons.camera_alt,
                      label: 'Kamera',
                      onTap: () async {
                        Navigator.pop(context);
                        final image = await _picker.pickImage(
                          source: ImageSource.camera,
                          imageQuality: 90,
                          maxWidth: 1024,
                          maxHeight: 1024,
                        );
                        if (image != null) {
                          await _processImage(image);
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildSourceOption(
                      icon: Icons.photo_library,
                      label: 'Galeri',
                      onTap: () async {
                        Navigator.pop(context);
                        final image = await _picker.pickImage(
                          source: ImageSource.gallery,
                          imageQuality: 90,
                          maxWidth: 1024,
                          maxHeight: 1024,
                        );
                        if (image != null) {
                          await _processImage(image);
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSourceOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            color: const Color(0xFF4A90E2).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF4A90E2).withOpacity(0.2)),
          ),
          child: Column(
            children: [
              Icon(icon, size: 32, color: const Color(0xFF4A90E2)),
              const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF4A90E2),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _processImage(XFile image) async {
    setState(() {
      _isLoading = true;
      _isProcessing = true;
      _selectedImage = image;
    });

    try {
      HapticFeedback.mediumImpact();
      
      final extractedText = await OCRService.extractTextFromImage(image.path);
      
      if (extractedText.isNotEmpty) {
        setState(() {
          _extractedText = extractedText;
        });
        
        await _parseKDTTextAdvanced(extractedText);
        
        HapticFeedback.lightImpact();
        _showSnackBar('KDT berhasil diekstrak dan diparse!', Colors.green[600]!);
      } else {
        _showSnackBar('Tidak ada teks KDT yang dapat diekstrak.', Colors.orange[600]!);
      }
    } catch (e) {
      HapticFeedback.heavyImpact();
      _showSnackBar('Gagal memproses gambar: ${e.toString()}', Colors.red[600]!);
    } finally {
      setState(() {
        _isLoading = false;
        _isProcessing = false;
      });
    }
  }

  Future<void> _parseKDTTextAdvanced(String text) async {
    // Clear previous data
    _controllers.values.forEach((controller) => controller.clear());
    _confidenceScores.clear();

    final lines = text.split('\n').map((line) => line.trim()).where((line) => line.isNotEmpty).toList();
    
    // Enhanced parsing with multiple patterns and confidence scoring
    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];
      final nextLine = i + 1 < lines.length ? lines[i + 1] : '';
      final prevLine = i > 0 ? lines[i - 1] : '';
      
      await _parseLineWithContext(line, nextLine, prevLine, i);
    }

    // Post-processing to improve accuracy
    await _postProcessKDTData();
    
    setState(() {});
  }

  Future<void> _parseLineWithContext(String line, String nextLine, String prevLine, int lineIndex) async {
    // ISBN Detection (Enhanced)
    if (_detectISBN(line)) return;
    
    // Author Detection (Enhanced with multiple patterns)
    if (_detectAuthor(line, nextLine, prevLine)) return;
    
    // Title Detection (Enhanced)
    if (_detectTitle(line, nextLine, prevLine, lineIndex)) return;
    
    // Publisher Detection (Enhanced)
    if (_detectPublisher(line, nextLine, prevLine)) return;
    
    // Year Detection (Enhanced)
    if (_detectYear(line)) return;
    
    // Place Detection
    if (_detectPlace(line)) return;
    
    // Edition Detection
    if (_detectEdition(line)) return;
    
    // Physical Description Detection
    if (_detectPhysicalDescription(line)) return;
    
    // Series Detection
    if (_detectSeries(line)) return;
    
    // Subject Headings Detection (Enhanced)
    if (_detectSubjectHeadings(line)) return;
    
    // Bibliography Detection
    if (_detectBibliography(line)) return;
    
    // Classification Detection
    if (_detectClassification(line)) return;
    
    // Call Number Detection
    if (_detectCallNumber(line)) return;
    
    // Notes Detection
    if (_detectNotes(line)) return;
  }

  bool _detectISBN(String line) {
    final patterns = [
      RegExp(r'ISBN\s*:?\s*([0-9\-X]{10,17})', caseSensitive: false),
      RegExp(r'([0-9]{3}\-[0-9]{1,5}\-[0-9]{1,7}\-[0-9]{1,6}\-[0-9X])', caseSensitive: false),
      RegExp(r'([0-9]{13})', caseSensitive: false),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(line);
      if (match != null) {
        final isbn = match.group(1) ?? match.group(0)!;
        _setFieldWithConfidence('isbn', _cleanISBN(isbn), 0.9);
        return true;
      }
    }
    return false;
  }

  bool _detectAuthor(String line, String nextLine, String prevLine) {
    final patterns = [
      RegExp(r'^([A-Z][a-z]+(?:\s[A-Z][a-z]+){1,3})\s*$'), // Simple name pattern
      RegExp(r'Pengarang\s*:?\s*(.+)', caseSensitive: false),
      RegExp(r'Author\s*:?\s*(.+)', caseSensitive: false),
      RegExp(r'^([A-Z][a-z]+,\s[A-Z][a-z]+(?:\s[A-Z][a-z]+)*)'), // Last, First format
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(line);
      if (match != null) {
        final author = match.group(1) ?? match.group(0)!;
        if (_isValidAuthorName(author)) {
          _setFieldWithConfidence('author', _formatAuthorName(author), 0.8);
          return true;
        }
      }
    }
    return false;
  }

  bool _detectTitle(String line, String nextLine, String prevLine, int lineIndex) {
    // Title is often the first or second meaningful line, longer than 10 characters
    if (lineIndex < 3 && line.length > 10 && _controllers['title']!.text.isEmpty) {
      if (!_containsMetadata(line) && _isValidTitle(line)) {
        _setFieldWithConfidence('title', _formatTitle(line), 0.7);
        return true;
      }
    }

    final patterns = [
      RegExp(r'Judul\s*:?\s*(.+)', caseSensitive: false),
      RegExp(r'Title\s*:?\s*(.+)', caseSensitive: false),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(line);
      if (match != null) {
        _setFieldWithConfidence('title', _formatTitle(match.group(1)!), 0.9);
        return true;
      }
    }
    return false;
  }

  bool _detectPublisher(String line, String nextLine, String prevLine) {
    final patterns = [
      RegExp(r'Penerbit\s*:?\s*(.+)', caseSensitive: false),
      RegExp(r'Publisher\s*:?\s*(.+)', caseSensitive: false),
      RegExp(r'^([A-Z][a-zA-Z\s]+(?:Press|Publishing|Publisher|Books|Media|Pustaka|Penerbit))', caseSensitive: false),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(line);
      if (match != null) {
        _setFieldWithConfidence('publisher', match.group(1)!.trim(), 0.8);
        return true;
      }
    }
    return false;
  }

  bool _detectYear(String line) {
    final yearPattern = RegExp(r'\b(19|20|21)\d{2}\b');
    final match = yearPattern.firstMatch(line);
    
    if (match != null) {
      final year = match.group(0)!;
      final currentYear = DateTime.now().year;
      final yearInt = int.parse(year);
      
      if (yearInt >= 1900 && yearInt <= currentYear + 2) {
        _setFieldWithConfidence('publicationYear', year, 0.9);
        return true;
      }
    }
    return false;
  }

  bool _detectPlace(String line) {
    final indonesianCities = [
      'Jakarta', 'Surabaya', 'Bandung', 'Medan', 'Bekasi', 'Tangerang', 
      'Depok', 'Semarang', 'Palembang', 'Makassar', 'Yogyakarta', 'Bogor',
      'Malang', 'Padang', 'Denpasar', 'Balikpapan', 'Banjarmasin', 'Solo',
      'Batam', 'Pekanbaru', 'Pontianak', 'Manado', 'Samarinda'
    ];

    for (final city in indonesianCities) {
      if (line.contains(city)) {
        _setFieldWithConfidence('publicationPlace', city, 0.8);
        return true;
      }
    }

    final placePattern = RegExp(r'\b([A-Z][a-z]+)\s*:?\s*$');
    final match = placePattern.firstMatch(line);
    if (match != null && _controllers['publicationPlace']!.text.isEmpty) {
      _setFieldWithConfidence('publicationPlace', match.group(1)!, 0.6);
      return true;
    }
    return false;
  }

  bool _detectEdition(String line) {
    final patterns = [
      RegExp(r'Edisi\s*:?\s*(.+)', caseSensitive: false),
      RegExp(r'Edition\s*:?\s*(.+)', caseSensitive: false),
      RegExp(r'Cet\.\s*(.+)', caseSensitive: false),
      RegExp(r'(\d+)\s*(?:ed|edition)', caseSensitive: false),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(line);
      if (match != null) {
        _setFieldWithConfidence('edition', match.group(1)!.trim(), 0.8);
        return true;
      }
    }
    return false;
  }

  bool _detectPhysicalDescription(String line) {
    final patterns = [
      RegExp(r'(\d+)\s*hal', caseSensitive: false),
      RegExp(r'(\d+)\s*p\.?', caseSensitive: false),
      RegExp(r'(\d+)\s*pages?', caseSensitive: false),
      RegExp(r'Deskripsi\s*[Ff]isik\s*:?\s*(.+)', caseSensitive: false),
      RegExp(r'Physical\s*Description\s*:?\s*(.+)', caseSensitive: false),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(line);
      if (match != null) {
        _setFieldWithConfidence('physicalDescription', match.group(1) ?? match.group(0)!, 0.7);
        return true;
      }
    }
    return false;
  }

  bool _detectSeries(String line) {
    final patterns = [
      RegExp(r'Seri\s*:?\s*(.+)', caseSensitive: false),
      RegExp(r'Series\s*:?\s*(.+)', caseSensitive: false),
      RegExp(r'\(([^)]+\s*series?[^)]*)\)', caseSensitive: false),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(line);
      if (match != null) {
        _setFieldWithConfidence('series', match.group(1)!.trim(), 0.8);
        return true;
      }
    }
    return false;
  }

  bool _detectSubjectHeadings(String line) {
    final patterns = [
      RegExp(r'^I\.\s*(.+)', caseSensitive: false),
      RegExp(r'^II\.\s*(.+)', caseSensitive: false),
      RegExp(r'^III\.\s*(.+)', caseSensitive: false),
      RegExp(r'^1\.\s*(.+)', caseSensitive: false),
      RegExp(r'^2\.\s*(.+)', caseSensitive: false),
      RegExp(r'^3\.\s*(.+)', caseSensitive: false),
    ];

    for (int i = 0; i < patterns.length; i++) {
      final match = patterns[i].firstMatch(line);
      if (match != null) {
        final fieldKey = i < 3 ? 
          ['subjectHeadingI', 'subjectHeadingII', 'subjectHeadingIII'][i] :
          ['subjectHeadingI', 'subjectHeadingII', 'subjectHeadingIII'][i - 3];
        
        if (_controllers[fieldKey]!.text.isEmpty) {
          _setFieldWithConfidence(fieldKey, match.group(1)!.trim(), 0.9);
          return true;
        }
      }
    }
    return false;
  }

  bool _detectBibliography(String line) {
    final patterns = [
      RegExp(r'Bibliografi\s*:?\s*hlm\.?\s*(\d+)', caseSensitive: false),
      RegExp(r'Bibliography\s*:?\s*p\.?\s*(\d+)', caseSensitive: false),
      RegExp(r'Indeks\s*:?\s*hlm\.?\s*(\d+)', caseSensitive: false),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(line);
      if (match != null) {
        _setFieldWithConfidence('bibliographyPage', match.group(1)!, 0.8);
        return true;
      }
    }
    return false;
  }

  bool _detectClassification(String line) {
    final patterns = [
      RegExp(r'Klasifikasi\s*:?\s*([0-9\.]+)', caseSensitive: false),
      RegExp(r'Classification\s*:?\s*([0-9\.]+)', caseSensitive: false),
      RegExp(r'^([0-9]{3}(?:\.[0-9]+)*)\s*$'),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(line);
      if (match != null) {
        _setFieldWithConfidence('classification', match.group(1)!, 0.8);
        return true;
      }
    }
    return false;
  }

  bool _detectCallNumber(String line) {
    final patterns = [
      RegExp(r'Call\s*Number\s*:?\s*(.+)', caseSensitive: false),
      RegExp(r'Nomor\s*Panggil\s*:?\s*(.+)', caseSensitive: false),
      RegExp(r'^([0-9]{3}(?:\.[0-9]+)*\s*[A-Z]{1,3})', caseSensitive: false),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(line);
      if (match != null) {
        _setFieldWithConfidence('callNumber', match.group(1)!.trim(), 0.8);
        return true;
      }
    }
    return false;
  }

  bool _detectNotes(String line) {
    final patterns = [
      RegExp(r'Catatan\s*:?\s*(.+)', caseSensitive: false),
      RegExp(r'Notes?\s*:?\s*(.+)', caseSensitive: false),
      RegExp(r'Keterangan\s*:?\s*(.+)', caseSensitive: false),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(line);
      if (match != null) {
        _setFieldWithConfidence('notes', match.group(1)!.trim(), 0.7);
        return true;
      }
    }
    return false;
  }

  // Helper methods for validation and formatting
  bool _containsMetadata(String line) {
    final metadataKeywords = ['ISBN', 'Edisi', 'hal', 'pages', 'Penerbit', 'Copyright', '©'];
    return metadataKeywords.any((keyword) => 
      line.toLowerCase().contains(keyword.toLowerCase()));
  }

  bool _isValidTitle(String line) {
    return line.length > 5 && line.length < 200 && 
           !RegExp(r'^\d+$').hasMatch(line) &&
           !line.toLowerCase().contains('isbn');
  }

  bool _isValidAuthorName(String name) {
    return name.length > 2 && name.length < 100 &&
           RegExp(r'^[A-Za-z\s\.,]+$').hasMatch(name) &&
           name.split(' ').length >= 2;
  }

  String _cleanISBN(String isbn) {
    return isbn.replaceAll(RegExp(r'[^\d\-X]'), '');
  }

  String _formatAuthorName(String author) {
    return author.trim().split(' ')
      .map((word) => word.isEmpty ? '' : 
           word[0].toUpperCase() + word.substring(1).toLowerCase())
      .join(' ');
  }

  String _formatTitle(String title) {
    return title.trim().split(' ')
      .map((word) => word.isEmpty ? '' : 
           word[0].toUpperCase() + word.substring(1).toLowerCase())
      .join(' ');
  }

  void _setFieldWithConfidence(String fieldKey, String value, double confidence) {
    if (_controllers[fieldKey]!.text.isEmpty || 
        (_confidenceScores[fieldKey] ?? 0.0) < confidence) {
      _controllers[fieldKey]!.text = value;
      _confidenceScores[fieldKey] = confidence;
    }
  }

  Future<void> _postProcessKDTData() async {
    // Cross-reference and validate data
    _validateAndCorrectData();
    
    // Fill missing editor if author exists
    if (_controllers['editor']!.text.isEmpty && _controllers['author']!.text.isNotEmpty) {
      _controllers['editor']!.text = _controllers['author']!.text;
    }
  }

  void _validateAndCorrectData() {
    // Validate year
    if (_controllers['publicationYear']!.text.isNotEmpty) {
      final year = int.tryParse(_controllers['publicationYear']!.text);
      if (year == null || year < 1900 || year > DateTime.now().year + 2) {
        _controllers['publicationYear']!.clear();
      }
    }

    // Validate ISBN
    if (_controllers['isbn']!.text.isNotEmpty) {
      final isbn = _controllers['isbn']!.text;
      if (!_isValidISBN(isbn)) {
        _controllers['isbn']!.text = _cleanISBN(isbn);
      }
    }
  }

  bool _isValidISBN(String isbn) {
    final cleaned = isbn.replaceAll(RegExp(r'[^\dX]'), '');
    return cleaned.length == 10 || cleaned.length == 13;
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              color == Colors.green[600] ? Icons.check_circle : 
              color == Colors.red[600] ? Icons.error : Icons.info,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildModernAppBar(),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: _buildContent(),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildModernAppBar() {
    return AppBar(
      title: const Text(
        'KDT Scanner',
        style: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 20,
          color: Colors.black,
        ),
      ),
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return _buildLoadingState();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          _buildScanSection(),
          if (_selectedImage != null) ...[
            const SizedBox(height: 24),
            _buildImagePreview(),
          ],
          if (_extractedText.isNotEmpty) ...[
            const SizedBox(height: 24),
            _buildResultsSection(),
            const SizedBox(height: 32),
            _buildActionButtons(),
          ],
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(const Color(0xFF4A90E2)),
            strokeWidth: 3,
          ),
          const SizedBox(height: 16),
          Text(
            _isProcessing ? 'Memproses KDT...' : 'Memuat...',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScanSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            Icons.qr_code_scanner,
            size: 48,
            color: const Color(0xFF4A90E2),
          ),
          const SizedBox(height: 16),
          const Text(
            'Scan KDT (Katalog Dalam Terbitan)',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Ambil foto halaman KDT untuk mengekstrak informasi bibliografi secara otomatis',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: _scanAndExtract,
              icon: const Icon(Icons.qr_code_scanner, size: 20),
              label: const Text(
                'Scan KDT',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4A90E2),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePreview() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Gambar KDT',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(
              File(_selectedImage!.path),
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsSection() {
    final groupedFields = _groupFieldsBySection();
    
    return Column(
      children: [
        _buildExtractedTextPreview(),
        const SizedBox(height: 24),
        ...groupedFields.entries.map((entry) => 
          _buildFieldSection(entry.key, entry.value)
        ).toList(),
      ],
    );
  }

  Widget _buildExtractedTextPreview() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.text_snippet, color: const Color(0xFF4A90E2)),
              const SizedBox(width: 8),
              const Text(
                'Teks Terekstrak',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A1A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            constraints: const BoxConstraints(maxHeight: 150),
            child: SingleChildScrollView(
              child: Text(
                _extractedText,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[700],
                  height: 1.4,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Map<String, List<String>> _groupFieldsBySection() {
    final grouped = <String, List<String>>{};
    
    for (final entry in _fieldInfo.entries) {
      final section = entry.value['section'] as String;
      if (!grouped.containsKey(section)) {
        grouped[section] = [];
      }
      grouped[section]!.add(entry.key);
    }
    
    return grouped;
  }

  Widget _buildFieldSection(String sectionName, List<String> fieldKeys) {
    final sectionTitles = {
      'basic': 'Informasi Dasar',
      'publication': 'Informasi Penerbitan',
      'identification': 'Identifikasi',
      'physical': 'Deskripsi Fisik',
      'classification': 'Klasifikasi',
      'subjects': 'Tajuk Subjek',
      'reference': 'Referensi',
      'additional': 'Informasi Tambahan',
    };

    final sectionIcons = {
      'basic': Icons.info,
      'publication': Icons.business,
      'identification': Icons.tag,
      'physical': Icons.description,
      'classification': Icons.category,
      'subjects': Icons.subject,
      'reference': Icons.menu_book,
      'additional': Icons.note_add,
    };

    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  sectionIcons[sectionName] ?? Icons.info,
                  color: const Color(0xFF4A90E2),
                ),
                const SizedBox(width: 8),
                Text(
                  sectionTitles[sectionName] ?? sectionName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...fieldKeys.map((fieldKey) => 
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _buildKDTField(fieldKey),
              ),
            ).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildKDTField(String fieldKey) {
    final fieldData = _fieldInfo[fieldKey]!;
    final confidence = _confidenceScores[fieldKey] ?? 0.0;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              fieldData['label'],
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            if (confidence > 0.0) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: _getConfidenceColor(confidence).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${(confidence * 100).round()}%',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: _getConfidenceColor(confidence),
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _controllers[fieldKey]!,
          maxLines: fieldKey == 'notes' || fieldKey == 'physicalDescription' ? 3 : 1,
          decoration: InputDecoration(
            hintText: 'Masukkan ${fieldData['label']}',
            prefixIcon: Container(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: (fieldData['color'] as Color).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                fieldData['icon'] as IconData,
                color: fieldData['color'] as Color,
                size: 18,
              ),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: fieldData['color'] as Color, width: 2),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            filled: true,
            fillColor: Colors.grey[50],
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
      ],
    );
  }

  Color _getConfidenceColor(double confidence) {
    if (confidence >= 0.8) return Colors.green;
    if (confidence >= 0.6) return Colors.orange;
    return Colors.red;
  }

  Widget _buildActionButtons() {
    final hasData = _controllers.values.any((controller) => controller.text.trim().isNotEmpty);
    
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton.icon(
            onPressed: hasData ? () {
              _showSnackBar('Data KDT siap untuk disimpan!', Colors.green[600]!);
              // Implement save functionality
            } : null,
            icon: const Icon(Icons.save, size: 20),
            label: const Text(
              'Simpan Data KDT',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4A90E2),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
              disabledBackgroundColor: Colors.grey[300],
              disabledForegroundColor: Colors.grey[600],
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: TextButton.icon(
            onPressed: () {
              _controllers.values.forEach((controller) => controller.clear());
              _confidenceScores.clear();
              setState(() {
                _extractedText = '';
                _selectedImage = null;
              });
            },
            icon: const Icon(Icons.refresh, size: 20),
            label: const Text(
              'Scan Ulang',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: TextButton.styleFrom(
              foregroundColor: Colors.grey[600],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey[300]!),
              ),
            ),
          ),
        ),
      ],
    );
  }
}