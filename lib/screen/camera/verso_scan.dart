// All Indonesian text changed to English

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:otobook/models/master_book_response_model.dart';
import 'package:otobook/screen/book/add_book.dart';
import 'package:otobook/services/ocr_service.dart';

class VersoScanner extends StatefulWidget {
  const VersoScanner({super.key, this.autoPress = false});
  final bool autoPress;

  @override
  State<VersoScanner> createState() => _VersoScannerState();
}

class _VersoScannerState extends State<VersoScanner> with SingleTickerProviderStateMixin {
  // Animation Controller
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Core Variables
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;
  bool _isProcessing = false;
  String _extractedText = '';
  XFile? _selectedImage;
  
  // Form Controllers
  final Map<String, TextEditingController> _controllers = {
    'judul': TextEditingController(),
    'pengarang': TextEditingController(),
    'penerbitan': TextEditingController(),
    'deskripsi': TextEditingController(),
    'isbn': TextEditingController(),
    'kota': TextEditingController(),
    'tahun': TextEditingController(),
    'editor': TextEditingController(),
    'ilustrator': TextEditingController(),
  };

  // Focus Nodes
  final Map<String, FocusNode> _focusNodes = {
    'judul': FocusNode(),
    'pengarang': FocusNode(),
    'penerbitan': FocusNode(),
    'deskripsi': FocusNode(),
    'isbn': FocusNode(),
    'kota': FocusNode(),
    'tahun': FocusNode(),
    'editor': FocusNode(),
    'ilustrator': FocusNode(),
  };
  // Field Information
  final Map<String, Map<String, dynamic>> _fieldInfo = {
    'judul': {
      'label': 'Book Title',
      'icon': Icons.title,
      'color': const Color(0xFF4A90E2),
      'hint': 'Enter book title',
    },
    'pengarang': {
      'label': 'Author',
      'icon': Icons.person,
      'color': const Color(0xFF26C6DA),
      'hint': 'Enter author name',
    },
    'penerbitan': {
      'label': 'Publisher',
      'icon': Icons.business,
      'color': const Color(0xFF66BB6A),
      'hint': 'Enter publisher name',
    },
    'deskripsi': {
      'label': 'Description',
      'icon': Icons.description,
      'color': const Color(0xFFFF7043),
      'hint': 'Enter book description',
    },
    'isbn': {
      'label': 'ISBN',
      'icon': Icons.tag,
      'color': const Color(0xFF9C27B0),
      'hint': 'Enter ISBN number',
    },
    'kota': {
      'label': 'City',
      'icon': Icons.location_city,
      'color': const Color(0xFFFF5722),
      'hint': 'Enter publication city',
    },
    'tahun': {
      'label': 'Year Published',
      'icon': Icons.calendar_today,
      'color': const Color(0xFF795548),
      'hint': 'Enter year published',
    },
    'editor': {
      'label': 'Editor',
      'icon': Icons.edit,
      'color': const Color(0xFF607D8B),
      'hint': 'Enter editor name',
    },
    'ilustrator': {
      'label': 'Illustrator',
      'icon': Icons.brush,
      'color': const Color(0xFFE91E63),
      'hint': 'Enter illustrator name',
    },
  };

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

  @override
  void dispose() {
    _animationController.dispose();
    _controllers.values.forEach((controller) => controller.dispose());
    _focusNodes.values.forEach((focusNode) => focusNode.dispose());
    super.dispose();
  }

  // Enhanced text formatting functions
  String _formatTitle(String text) {
    if (text.isEmpty) return '';
    
    // Remove common prefixes and clean the text
    String cleaned = text
        .replaceAll(RegExp(r'^(title|judul)\s*:?\s*', caseSensitive: false), '')
        .trim();
    
    // Convert to title case
    return cleaned.split(' ')
        .map((word) => word.isEmpty ? '' : 
             word[0].toUpperCase() + word.substring(1).toLowerCase())
        .join(' ');
  }

  String _formatISBN(String text) {
    // Extract only numbers and hyphens, remove ISBN prefix
    return text
        .replaceAll(RegExp(r'ISBN\s*:?', caseSensitive: false), '')
        .replaceAll(RegExp(r'[^0-9\-X]'), '')
        .trim();
  }

  String _extractCityName(String text) {
    // Enhanced city extraction with common Indonesian cities
    final cityPatterns = [
      RegExp(r'\b(Jakarta|Surabaya|Bandung|Medan|Bekasi|Tangerang|Depok|Semarang|Palembang|Makassar|Yogyakarta|Bogor|Malang|Padang|Denpasar|Balikpapan|Banjarmasin|Samarinda|Pekanbaru|Batam)\b', caseSensitive: false),
      RegExp(r'\b[A-Z][a-z]+(?:\s[A-Z][a-z]+)?\b'), // General city pattern
    ];

    for (final pattern in cityPatterns) {
      final match = pattern.firstMatch(text);
      if (match != null) {
        return match.group(0)!;
      }
    }
    
    return text.trim();
  }

  String _extractYear(String text) {
    // Extract 4-digit year (1900-2100)
    final yearMatch = RegExp(r'\b(19|20|21)\d{2}\b').firstMatch(text);
    return yearMatch?.group(0) ?? text.replaceAll(RegExp(r'[^0-9]'), '');
  }

  List<String> _extractNames(String text) {
    // Enhanced name extraction for Indonesian names
    final namePatterns = [
      RegExp(r'\b[A-Z][a-z]+(?:\s[A-Z][a-z]+){1,3}\b'), // 2-4 words names
      RegExp(r'\b[A-Z]\.\s?[A-Z][a-z]+\b'), // Abbreviated first name
    ];

    Set<String> names = {};
    for (final pattern in namePatterns) {
      final matches = pattern.allMatches(text);
      names.addAll(matches.map((m) => m.group(0)!));
    }

    return names.toList();
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
                'Choose Image Source',
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
                      label: 'Camera',
                      onTap: () async {
                        Navigator.pop(context);
                        final image = await _picker.pickImage(
                          source: ImageSource.camera,
                          imageQuality: 85,
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
                      label: 'Gallery',
                      onTap: () async {
                        Navigator.pop(context);
                        final image = await _picker.pickImage(
                          source: ImageSource.gallery,
                          imageQuality: 85,
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
  Future<void> _scanAndExtract() async {
    await _showImageSourceSelector();
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
        
        HapticFeedback.lightImpact();
        _showSnackBar('Text extracted successfully! Tap text to fill field.', Colors.green[600]!);
        
        // Auto-fill based on common patterns
        await _autoFillFields(extractedText);
      } else {
        _showSnackBar('No text could be extracted from the image.', Colors.orange[600]!);
      }
    } catch (e) {
      HapticFeedback.heavyImpact();
      _showSnackBar('Failed to process image: ${e.toString()}', Colors.red[600]!);
    } finally {
      setState(() {
        _isLoading = false;
        _isProcessing = false;
      });
    }
  } Future<void> _autoFillFields(String text) async {
    final lines = text.split('\n').where((line) => line.trim().isNotEmpty).toList();
    
    for (int i = 0; i < lines.length; i++) {
      final line = lines[i].trim();
      
      // Auto-detect ISBN
      if (RegExp(r'ISBN', caseSensitive: false).hasMatch(line) && _controllers['isbn']!.text.isEmpty) {
        _controllers['isbn']!.text = _formatISBN(line);
      }
      
      // Auto-detect year
      if (RegExp(r'\b(19|20|21)\d{2}\b').hasMatch(line) && _controllers['tahun']!.text.isEmpty) {
        _controllers['tahun']!.text = _extractYear(line);
      }
      
      // Auto-detect title (usually first or second line, longer text)
      if (i < 3 && line.length > 10 && _controllers['judul']!.text.isEmpty && 
          !RegExp(r'(ISBN|copyright|©)', caseSensitive: false).hasMatch(line)) {
        _controllers['judul']!.text = _formatTitle(line);
      }
    }
    
    setState(() {});
  } void _showFieldSelectionDialog(String selectedText) {
    HapticFeedback.selectionClick();
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Icon(Icons.edit_note, color: const Color(0xFF4A90E2)),
              const SizedBox(width: 12),
              const Text('Select Field'),
            ],
          ),
          content: Container(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: _fieldInfo.entries.map((entry) {
                  final fieldKey = entry.key;
                  final fieldData = entry.value;
                  
                  return ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: (fieldData['color'] as Color).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        fieldData['icon'] as IconData,
                        color: fieldData['color'] as Color,
                        size: 20,
                      ),
                    ),
                    title: Text(fieldData['label'] as String),
                    subtitle: _controllers[fieldKey]!.text.isNotEmpty 
                        ? Text('Current: ${_controllers[fieldKey]!.text.length > 30 ? 
                               _controllers[fieldKey]!.text.substring(0, 30) + '...' : 
                               _controllers[fieldKey]!.text}')
                        : null,
                    onTap: () {
                      _assignToField(fieldKey, selectedText);
                      Navigator.pop(context);
                    },
                  );
                }).toList(),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _assignToField(String fieldKey, String selectedText) {
    setState(() {
      String processedText = selectedText;
      
      switch (fieldKey) {
        case 'judul':
          processedText = _formatTitle(selectedText);
          break;
        case 'isbn':
          processedText = _formatISBN(selectedText);
          break;
        case 'kota':
          processedText = _extractCityName(selectedText);
          break;
        case 'tahun':
          processedText = _extractYear(selectedText);
          break;
        case 'editor':
        case 'ilustrator':
          final names = _extractNames(selectedText);
          processedText = names.join(', ');
          break;
      }
      
      // Append or replace text
      final controller = _controllers[fieldKey]!;
      if (controller.text.isEmpty) {
        controller.text = processedText;
      } else {
        controller.text = '${controller.text}, $processedText';
      }
      
      // Focus the field
      FocusScope.of(context).requestFocus(_focusNodes[fieldKey]!);
    });
    
    HapticFeedback.lightImpact();
    _showSnackBar('Text added to ${_fieldInfo[fieldKey]!['label']}', Colors.blue[600]!);
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

  void _navigateToAddPage() {
    if (_controllers.values.every((controller) => controller.text.trim().isEmpty)) {
      _showSnackBar('Please fill at least one field before continuing', Colors.orange[600]!);
      return;
    }

    final masterBookData = masterBook(
      id: 0,
      judul: _controllers['judul']!.text.trim(),
      pengarang: _controllers['pengarang']!.text.trim(),
      penerbitan: _controllers['penerbitan']!.text.trim(),
      deskripsi: _controllers['deskripsi']!.text.trim(),
      isbn: _controllers['isbn']!.text.trim(),
      kota: _controllers['kota']!.text.trim(),
      tahun: _controllers['tahun']!.text.trim(),
      editor: _controllers['editor']!.text.trim(),
      ilustrator: _controllers['ilustrator']!.text.trim(),
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddBookScreen(masterBookData: masterBookData),
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
        'Scan Book',
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
            _buildExtractedTextSection(),
            const SizedBox(height: 24),
            _buildFormSection(),
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
            _isProcessing ? 'Processing image...' : 'Loading...',
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
            Icons.document_scanner,
            size: 48,
            color: const Color(0xFF4A90E2),
          ),
          const SizedBox(height: 16),
          const Text(
            'Scan Book Page',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Take a photo of the copyright or verso page to automatically extract information',
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
              icon: const Icon(Icons.camera_alt, size: 20),
              label: const Text(
                'Start Scan',
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
            'Selected Image',
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

  Widget _buildExtractedTextSection() {
    return Container(
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
              Icon(Icons.text_fields, color: const Color(0xFF4A90E2)),
              const SizedBox(width: 8),
              const Text(
                'Extracted Text',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A1A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the text below to fill the appropriate field',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            constraints: const BoxConstraints(maxHeight: 200),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _extractedText.split('\n')
                    .where((line) => line.trim().isNotEmpty)
                    .map((line) => _buildSelectableTextLine(line.trim()))
                    .toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectableTextLine(String line) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showFieldSelectionDialog(line),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              line,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF4A90E2),
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormSection() {
    return Container(
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
              Icon(Icons.edit_note, color: const Color(0xFF4A90E2)),
              const SizedBox(width: 8),
              const Text(
                'Book Information',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A1A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ..._fieldInfo.entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _buildModernTextField(
                controller: _controllers[entry.key]!,
                focusNode: _focusNodes[entry.key]!,
                label: entry.value['label'],
                hint: entry.value['hint'],
                icon: entry.value['icon'],
                color: entry.value['color'],
                maxLines: entry.key == 'deskripsi' ? 3 : 1,
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
  Widget _buildModernTextField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    required String hint,
    required IconData icon,
    required Color color,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          focusNode: focusNode,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Container(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: color, width: 2),
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

  Widget _buildActionButtons() {
    final hasData = _controllers.values.any((controller) => controller.text.trim().isNotEmpty);
    
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton.icon(
            onPressed: hasData ? _navigateToAddPage : null,
            icon: const Icon(Icons.save, size: 20),
            label: const Text(
              'Continue to Full Form',
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
              // Clear all fields
              _controllers.values.forEach((controller) => controller.clear());
              setState(() {
                _extractedText = '';
                _selectedImage = null;
              });
            },
            icon: const Icon(Icons.refresh, size: 20),
            label: const Text(
              'Restart',
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