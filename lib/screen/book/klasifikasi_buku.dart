import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:otobook/models/klasifikasi_response_model.dart';
import 'package:otobook/screen/book/edit_klasifikasi_buku.dart';
import 'package:otobook/services/api.dart';

import 'tajuk_subject.dart';

class Klasifikasibuku extends StatefulWidget {
  const Klasifikasibuku({super.key});

  @override
  State<Klasifikasibuku> createState() => _KlasifikasibukuState();
}

class _KlasifikasibukuState extends State<Klasifikasibuku>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  List<Klasifikasi> _books = [];
  bool _isLoading = false;
  String _errorMessage = '';
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
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
    _searchController.dispose();
    super.dispose();
  }

  // Keep the original logic exactly the same
  Future<void> _onSearch(String keyword) async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    try {
      Uri url = Uri.parse(GetData().searchKlasifikasiUrl);
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(<String, String>{'keyword': keyword}),
      );
      if (response.statusCode == 200) {
        final body = response.body;
        final result = jsonDecode(body);

        if (result['data'] != null) {
          setState(() {
            _books = List<Klasifikasi>.from(
              result['data'].map((i) => Klasifikasi.fromJson(i)),
            );
          });
        } else {
          setState(() {
            _errorMessage = 'Data tidak ditemukan.';
          });
        }
      } else {
        setState(() {
          _errorMessage =
              'Gagal mencari Klasifikasi. Status code: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error fetching books: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Helper method to get Dewey color
  Color _getDeweyColor(String deweyNo) {
    final number = int.tryParse(deweyNo.split('.').first) ?? 0;
    
    if (number >= 0 && number < 100) return const Color(0xFFEF4444); // Computer science - Red
    if (number >= 100 && number < 200) return const Color(0xFFF97316); // Philosophy - Orange
    if (number >= 200 && number < 300) return const Color(0xFFEAB308); // Religion - Yellow
    if (number >= 300 && number < 400) return const Color(0xFF22C55E); // Social sciences - Green
    if (number >= 400 && number < 500) return const Color(0xFF06B6D4); // Language - Cyan
    if (number >= 500 && number < 600) return const Color(0xFF3B82F6); // Science - Blue
    if (number >= 600 && number < 700) return const Color(0xFF6366F1); // Technology - Indigo
    if (number >= 700 && number < 800) return const Color(0xFF8B5CF6); // Arts - Purple
    if (number >= 800 && number < 900) return const Color(0xFFEC4899); // Literature - Pink
    if (number >= 900 && number < 1000) return const Color(0xFF10B981); // History - Emerald
    
    return const Color(0xFF6B7280); // Default - Gray
  }

  // Helper method to get Dewey category
  String _getDeweyCategory(String deweyNo) {
    final number = int.tryParse(deweyNo.split('.').first) ?? 0;
    
    if (number >= 0 && number < 100) return 'Ilmu Komputer';
    if (number >= 100 && number < 200) return 'Filsafat';
    if (number >= 200 && number < 300) return 'Agama';
    if (number >= 300 && number < 400) return 'Ilmu Sosial';
    if (number >= 400 && number < 500) return 'Bahasa';
    if (number >= 500 && number < 600) return 'Sains';
    if (number >= 600 && number < 700) return 'Teknologi';
    if (number >= 700 && number < 800) return 'Seni';
    if (number >= 800 && number < 900) return 'Sastra';
    if (number >= 900 && number < 1000) return 'Sejarah';
    
    return 'Umum';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Cari Klasifikasi Buku',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 20,
            color: Color(0xFF1A1A1A), // Dark text on white background
          ),
        ),
        backgroundColor: Colors.white, // White background
        foregroundColor: const Color(0xFF1A1A1A), // Dark foreground
        elevation: 0,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.dark, // Dark status bar content
        shadowColor: Colors.black.withOpacity(0.1),
        surfaceTintColor: Colors.white,
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Column(
            children: [
              _buildSearchSection(),
              Expanded(child: _buildContentArea()),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          HapticFeedback.lightImpact();
          // Keep original navigation logic
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const TajukSubject(),
            ),
          );
        },
        icon: const Icon(Icons.add, size: 20),
        label: const Text(
          'Tambah Tajuk',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: const Color(0xFF4F46E5),
        foregroundColor: Colors.white,
        elevation: 4,
        tooltip: 'Tambah Tajuk Subjek',
      ),
    );
  }

  Widget _buildSearchSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header info
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF4F46E5).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.search,
                  color: Color(0xFF4F46E5),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pencarian Klasifikasi',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    Text(
                      'Cari berdasarkan nomor Dewey, subjek, atau uraian',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              if (_books.isNotEmpty && !_isLoading)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4F46E5).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${_books.length} item',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF4F46E5),
                    ),
                  ),
                ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Search input - keep original functionality
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Cari Klasifikasi...',
              hintStyle: TextStyle(color: Colors.grey[500]),
              prefixIcon: Container(
                margin: const EdgeInsets.all(12),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF4F46E5).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.search,
                  color: Color(0xFF4F46E5),
                  size: 18,
                ),
              ),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: Colors.grey),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {});
                      },
                    )
                  : null,
              filled: true,
              fillColor: Colors.grey[50],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF4F46E5), width: 2),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
            onSubmitted: _onSearch, // Keep original onSubmitted logic
            onChanged: (value) {
              setState(() {}); // Update to show/hide clear button
            },
          ),
        ],
      ),
    );
  }

  Widget _buildContentArea() {
    // Keep original conditional logic exactly the same
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
          const CircularProgressIndicator.adaptive(), // Keep original adaptive indicator
          const SizedBox(height: 16),
          Text(
            'Mencari klasifikasi...',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Oops! Terjadi Kesalahan',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.red[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage, // Keep original error message
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _onSearch(_searchController.text), // Keep original retry logic
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Coba Lagi'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4F46E5),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.library_books_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            const Text(
              'Tidak ada buku ditemukan.', // Keep original text
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Coba gunakan kata kunci yang berbeda',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBooksList() {
    // Keep original ListView.builder structure
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _books.length,
      itemBuilder: (context, index) {
        final book = _books[index]; // Keep original variable name and logic
        return _buildClassificationCard(book, index);
      },
    );
  }

  Widget _buildClassificationCard(Klasifikasi book, int index) {
    final deweyColor = _getDeweyColor(book.deweyNoClass);
    final deweyCategory = _getDeweyCategory(book.deweyNoClass);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            // Keep original navigation logic exactly the same
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Editklasifikasibuku(
                  klasifikasiId: book.id,
                ),
              ),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with Dewey number and category
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: deweyColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: deweyColor.withOpacity(0.3)),
                      ),
                      child: Text(
                        'Dewey No: ${book.deweyNoClass}', // Keep original text format
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: deweyColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: deweyColor.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          deweyCategory,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: deweyColor,
                          ),
                        ),
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Colors.grey[400],
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Keep original data structure and logic
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Uraian Klasifikasi: ${book.narasiKlasifikasi}', // Keep original text format
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1A1A),
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Subject: ${book.subject ?? 'Tidak ada subject'}', // Keep original logic
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Footer
                Row(
                  children: [
                    Icon(
                      Icons.edit_outlined,
                      size: 16,
                      color: Colors.grey[500],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Tap untuk edit',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '#${index + 1}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[400],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}