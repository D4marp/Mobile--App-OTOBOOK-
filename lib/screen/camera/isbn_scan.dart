import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:http/http.dart' as http;
import 'package:otobook/services/api.dart';
import 'package:otobook/screen/book/add_book.dart';
import '../../models/master_book_response_model.dart';

class ISBNScanPage extends StatefulWidget {
  const ISBNScanPage({super.key});

  @override
  State<ISBNScanPage> createState() => _ISBNScanPageState();
}

class _ISBNScanPageState extends State<ISBNScanPage> with TickerProviderStateMixin {
  // Controllers and Animations
  late MobileScannerController _scannerController;
  late AnimationController _animationController;
  late AnimationController _scanAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scanAnimation;
  late Animation<Offset> _slideAnimation;

  // State Variables
  List<masterBook> _books = [];
  bool _isScanning = false;
  bool _isLoading = false;
  bool _flashOn = false;
  String _errorMessage = '';
  String _lastScannedISBN = '';
  int _scanAttempts = 0;

  // Scanner State
  bool _scannerActive = true;
  CameraFacing _cameraFacing = CameraFacing.back;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _initializeScanner();
  }

  void _initializeControllers() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scanAnimationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _scanAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _scanAnimationController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _animationController.forward();
    _scanAnimationController.repeat();
  }

  void _initializeScanner() {
    _scannerController = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
      facing: _cameraFacing,
      torchEnabled: _flashOn,
      useNewCameraSelector: true,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scanAnimationController.dispose();
    _scannerController.dispose();
    super.dispose();
  }

  // Enhanced ISBN validation with multiple formats
  bool _isValidISBN(String isbn) {
    // Remove all non-digit and non-X characters
    final cleanISBN = isbn.replaceAll(RegExp(r'[^0-9X]'), '').toUpperCase();
    
    // Check ISBN-10 format
    if (cleanISBN.length == 10) {
      return _validateISBN10(cleanISBN);
    }
    
    // Check ISBN-13 format
    if (cleanISBN.length == 13) {
      return _validateISBN13(cleanISBN);
    }
    
    return false;
  }

  bool _validateISBN10(String isbn) {
    int sum = 0;
    for (int i = 0; i < 9; i++) {
      sum += int.parse(isbn[i]) * (10 - i);
    }
    
    final checkDigit = isbn[9];
    final calculatedCheck = (11 - (sum % 11)) % 11;
    
    if (calculatedCheck == 10) {
      return checkDigit == 'X';
    } else {
      return checkDigit == calculatedCheck.toString();
    }
  }

  bool _validateISBN13(String isbn) {
    int sum = 0;
    for (int i = 0; i < 12; i++) {
      final digit = int.parse(isbn[i]);
      sum += (i % 2 == 0) ? digit : digit * 3;
    }
    
    final checkDigit = int.parse(isbn[12]);
    final calculatedCheck = (10 - (sum % 10)) % 10;
    
    return checkDigit == calculatedCheck;
  }

  String _formatISBN(String isbn) {
    final cleanISBN = isbn.replaceAll(RegExp(r'[^0-9X]'), '').toUpperCase();
    
    if (cleanISBN.length == 13) {
      // Format as 978-x-xxxx-xxxx-x
      return '${cleanISBN.substring(0, 3)}-${cleanISBN.substring(3, 4)}-${cleanISBN.substring(4, 8)}-${cleanISBN.substring(8, 12)}-${cleanISBN.substring(12)}';
    } else if (cleanISBN.length == 10) {
      // Format as x-xxxx-xxxx-x
      return '${cleanISBN.substring(0, 1)}-${cleanISBN.substring(1, 5)}-${cleanISBN.substring(5, 9)}-${cleanISBN.substring(9)}';
    }
    
    return cleanISBN;
  }

  Future<void> _searchBookByISBN(String isbn) async {
    final cleanISBN = isbn.replaceAll(RegExp(r'[^0-9X]'), '').toUpperCase();
    
    if (!_isValidISBN(cleanISBN)) {
      _showError('ISBN tidak valid: ${_formatISBN(isbn)}');
      _restartScanning();
      return;
    }

    // Prevent duplicate scans
    if (_lastScannedISBN == cleanISBN) {
      _restartScanning();
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
      _lastScannedISBN = cleanISBN;
      _scanAttempts++;
    });

    try {
      // Try multiple search approaches
      final results = await Future.wait([
        _searchInternalDatabase(cleanISBN),
        _searchExternalAPI(cleanISBN),
      ]);

      List<masterBook> allBooks = [];
      for (final result in results) {
        if (result.isNotEmpty) {
          allBooks.addAll(result);
        }
      }

      // Remove duplicates based on ISBN
      final uniqueBooks = <String, masterBook>{};
      for (final book in allBooks) {
        uniqueBooks[book.isbn] = book;
      }

      if (uniqueBooks.isNotEmpty) {
        setState(() {
          _books = uniqueBooks.values.toList();
        });
        
        HapticFeedback.lightImpact();
        _showSnackBar(
          'Ditemukan ${uniqueBooks.length} buku dengan ISBN: ${_formatISBN(cleanISBN)}',
          Colors.green[600]!,
        );
      } else {
        _showError('Tidak ada buku ditemukan dengan ISBN: ${_formatISBN(cleanISBN)}');
        _restartScanning();
      }
    } catch (e) {
      _showError('Terjadi kesalahan: ${e.toString()}');
      _restartScanning();
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<List<masterBook>> _searchInternalDatabase(String isbn) async {
    try {
      final Uri url = Uri.parse('${GetData().searchBookUrl}?isbn=$isbn');
      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        if (result['data'] != null && result['data'].isNotEmpty) {
          return List<masterBook>.from(
            result['data'].map((i) => masterBook.fromJson(i)),
          );
        }
      }
    } catch (e) {
      print('Internal search error: $e');
    }
    
    return [];
  }

  Future<List<masterBook>> _searchExternalAPI(String isbn) async {
    try {
      // Google Books API search
      final Uri googleUrl = Uri.parse(
        'https://www.googleapis.com/books/v1/volumes?q=isbn:$isbn'
      );
      
      final response = await http.get(googleUrl).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        if (result['items'] != null && result['items'].isNotEmpty) {
          return _parseGoogleBooksResponse(result['items'], isbn);
        }
      }
    } catch (e) {
      print('External API search error: $e');
    }
    
    return [];
  }

  List<masterBook> _parseGoogleBooksResponse(List items, String isbn) {
    List<masterBook> books = [];
    
    for (final item in items) {
      final volumeInfo = item['volumeInfo'];
      if (volumeInfo != null) {
        books.add(masterBook(
          id: 0,
          judul: volumeInfo['title'] ?? 'Judul tidak tersedia',
          pengarang: volumeInfo['authors']?.join(', ') ?? 'Pengarang tidak tersedia',
          penerbitan: volumeInfo['publisher'] ?? 'Penerbit tidak tersedia',
          deskripsi: volumeInfo['description'] ?? 'Deskripsi tidak tersedia',
          isbn: isbn,
          kota: 'Tidak tersedia',
          tahun: volumeInfo['publishedDate']?.split('-').first ?? 'Tahun tidak tersedia',
          editor: 'Tidak tersedia',
          ilustrator: 'Tidak tersedia',
        ));
      }
    }
    
    return books;
  }

  void _showError(String message) {
    setState(() {
      _errorMessage = message;
      _books.clear();
    });
    
    HapticFeedback.heavyImpact();
    _showSnackBar(message, Colors.red[600]!);
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              color == Colors.green[600] ? Icons.check_circle : Icons.error_outline,
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

  void _restartScanning() {
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted && _scannerActive) {
        _scannerController.start();
        setState(() {
          _isScanning = false;
        });
      }
    });
  }

  void _toggleFlash() {
    setState(() {
      _flashOn = !_flashOn;
    });
    _scannerController.toggleTorch();
    HapticFeedback.lightImpact();
  }

  void _switchCamera() {
    setState(() {
      _cameraFacing = _cameraFacing == CameraFacing.back 
          ? CameraFacing.front 
          : CameraFacing.back;
    });
    _scannerController.switchCamera();
    HapticFeedback.lightImpact();
  }

  void _navigateToAddBook(masterBook book) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddBookScreen(masterBookData: book),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
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
        'Scan ISBN Buku',
        style: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 20,
          color: Colors.white,
        ),
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.3),
          borderRadius: BorderRadius.circular(12),
        ),
        child: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: Icon(
              _flashOn ? Icons.flash_on : Icons.flash_off,
              color: _flashOn ? Colors.yellow : Colors.white,
            ),
            onPressed: _toggleFlash,
          ),
        ),
        Container(
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: const Icon(Icons.flip_camera_ios, color: Colors.white),
            onPressed: _switchCamera,
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildContent() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenHeight = constraints.maxHeight;
        final screenWidth = constraints.maxWidth;
        
        return Stack(
          children: [
            // Full-screen camera positioned perfectly
            Positioned.fill(
              child: ClipRect(
                child: OverflowBox(
                  alignment: Alignment.center,
                  child: FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: screenWidth,
                      height: screenHeight,
                      child: MobileScanner(
                        controller: _scannerController,
                        fit: BoxFit.cover,
                        onDetect: (BarcodeCapture capture) {
                          if (_isScanning || _isLoading || capture.barcodes.isEmpty) return;
                          
                          setState(() => _isScanning = true);
                          HapticFeedback.mediumImpact();

                          final String? isbn = capture.barcodes.first.rawValue;
                          if (isbn != null && isbn.trim().isNotEmpty) {
                            _scannerController.stop();
                            _searchBookByISBN(isbn.trim());
                          } else {
                            setState(() {
                              _isScanning = false;
                              _errorMessage = 'Barcode tidak terbaca dengan jelas';
                            });
                            _restartScanning();
                          }
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
            
            // Scanning overlay positioned over the camera
            Positioned.fill(
              child: _buildScanningOverlay(),
            ),
            
            // Loading overlay
            if (_isLoading) 
              Positioned.fill(
                child: _buildLoadingOverlay(),
              ),
            
            // Results section at the bottom
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: screenHeight * 0.4, // 40% of screen height
              child: _buildResultsSection(),
            ),
          ],
        );
      },
    );
  }

  Widget _buildScanningOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.5),
      child: CustomPaint(
        painter: ScanOverlayPainter(),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Scanning Frame - perfectly centered
              Container(
                width: 280,
                height: 180,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white.withOpacity(0.8), width: 2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Stack(
                  children: [
                    // Corner indicators
                    ...List.generate(4, (index) => _buildCornerIndicator(index)),
                    
                    // Scanning line animation
                    AnimatedBuilder(
                      animation: _scanAnimation,
                      builder: (context, child) {
                        return Positioned(
                          top: 20 + (_scanAnimation.value * 140),
                          left: 20,
                          right: 20,
                          child: Container(
                            height: 3,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.transparent,
                                  Colors.red.withOpacity(0.8),
                                  Colors.red,
                                  Colors.red.withOpacity(0.8),
                                  Colors.transparent,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(2),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.red.withOpacity(0.3),
                                  blurRadius: 8,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              
              // Instructions
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.qr_code_scanner,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Arahkan kamera ke barcode ISBN',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Posisikan barcode di dalam frame\nTunggu hingga terdeteksi otomatis',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (_scanAttempts > 0) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Percobaan: $_scanAttempts',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCornerIndicator(int index) {
    const double cornerSize = 24;
    const double cornerThickness = 4;
    
    final isTop = index < 2;
    final isLeft = index % 2 == 0;
    
    return Positioned(
      top: isTop ? -cornerThickness : null,
      bottom: !isTop ? -cornerThickness : null,
      left: isLeft ? -cornerThickness : null,
      right: !isLeft ? -cornerThickness : null,
      child: Container(
        width: cornerSize,
        height: cornerSize,
        decoration: BoxDecoration(
          border: Border(
            top: isTop ? BorderSide(color: Colors.red, width: cornerThickness) : BorderSide.none,
            bottom: !isTop ? BorderSide(color: Colors.red, width: cornerThickness) : BorderSide.none,
            left: isLeft ? BorderSide(color: Colors.red, width: cornerThickness) : BorderSide.none,
            right: !isLeft ? BorderSide(color: Colors.red, width: cornerThickness) : BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.8),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                strokeWidth: 3,
              ),
              const SizedBox(height: 16),
              const Text(
                'Mencari buku...',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (_lastScannedISBN.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  'ISBN: ${_formatISBN(_lastScannedISBN)}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultsSection() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Header
            Row(
              children: [
                Icon(
                  Icons.search_rounded,
                  color: const Color(0xFF4A90E2),
                  size: 24,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Hasil Pencarian',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Content
            Expanded(
              child: _buildResultContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultContent() {
    if (_isLoading) {
      return _buildLoadingState();
    } else if (_errorMessage.isNotEmpty) {
      return _buildErrorState();
    } else if (_books.isEmpty) {
      return _buildEmptyState();
    } else {
      return _buildBooksList();
    }
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(const Color(0xFF4A90E2)),
          ),
          const SizedBox(height: 16),
          const Text(
            'Mencari buku di database...',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 48,
            color: Colors.red[400],
          ),
          const SizedBox(height: 16),
          Text(
            _errorMessage,
            style: TextStyle(
              fontSize: 16,
              color: Colors.red[600],
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                _errorMessage = '';
                _books.clear();
              });
              _restartScanning();
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Scan Ulang'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4A90E2),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.qr_code_scanner,
            size: 48,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Pindai ISBN untuk mencari detail buku',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Arahkan kamera ke barcode ISBN pada buku',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBooksList() {
    return ListView.builder(
      itemCount: _books.length,
      itemBuilder: (context, index) {
        final book = _books[index];
        return _buildBookCard(book, index);
      },
    );
  }

  Widget _buildBookCard(masterBook book, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _navigateToAddBook(book),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4A90E2).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.book,
                        color: Color(0xFF4A90E2),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            book.judul,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1A1A1A),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'oleh ${book.pengarang}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.grey[400],
                      size: 16,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildBookDetails(book),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBookDetails(masterBook book) {
    final details = [
      {'label': 'Penerbit', 'value': book.penerbitan, 'icon': Icons.business},
      {'label': 'Tahun', 'value': book.tahun, 'icon': Icons.calendar_today},
      {'label': 'ISBN', 'value': _formatISBN(book.isbn), 'icon': Icons.tag},
    ];

    return Column(
      children: details.map((detail) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          children: [
            Icon(
              detail['icon'] as IconData,
              size: 16,
              color: Colors.grey[500],
            ),
            const SizedBox(width: 8),
            Text(
              '${detail['label']}: ',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            Expanded(
              child: Text(
                detail['value'] as String,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF1A1A1A),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      )).toList(),
    );
  }
}

// Custom painter for scan overlay
class ScanOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withOpacity(0.5)
      ..style = PaintingStyle.fill;

    final centerX = size.width / 2;
    final centerY = size.height / 2;
    
    final scanRect = Rect.fromCenter(
      center: Offset(centerX, centerY),
      width: 280,
      height: 180,
    );

    // Create path for the overlay with cutout
    final overlayPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRRect(RRect.fromRectAndRadius(scanRect, const Radius.circular(16)))
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(overlayPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}