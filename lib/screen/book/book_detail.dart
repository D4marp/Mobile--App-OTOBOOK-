import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:otobook/screen/book/edit_book.dart';
import 'package:otobook/screen/camera/sinopsis_scan.dart';
import 'package:otobook/screen/ip/ip_setting.dart';
import 'package:otobook/services/api.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/master_book_response_model.dart';

class BookDetailPage extends StatefulWidget {
  final int bookId;
  const BookDetailPage({super.key, required this.bookId});

  @override
  State<BookDetailPage> createState() => _BookDetailPageState();
}

class _BookDetailPageState extends State<BookDetailPage> 
    with SingleTickerProviderStateMixin {
  
  // Animation Controllers
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  // State Variables
  int get bookId => widget.bookId;
  String? rpaResponse;
  bool _isLoading = false;
  String? _coverUrl;
  masterBook? _currentBook;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _getRpaResponse();
    _loadBookData();
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
    super.dispose();
  }

  Future<void> _loadBookData() async {
    setState(() => _isLoading = true);
    
    try {
      // Load book data and cover in parallel
      final results = await Future.wait([
        GetData.getBookWithSinopsis(widget.bookId),
        fetchCoverPath(widget.bookId),
      ]);
      
      _currentBook = results[0] as masterBook;
      _coverUrl = results[1] as String?;
      
      if (_coverUrl?.isNotEmpty == true) {
        _coverUrl = '${GetData().Url}$_coverUrl';
      }
    } catch (e) {
      _showSnackBar('Gagal memuat data buku: $e', Colors.red[600]!);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<String?> fetchCoverPath(int masterBukuId) async {
    try {
      final response = await http.get(
        Uri.parse('${GetData().getCoverUrl}/$masterBukuId'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return data['path'];
      }
    } catch (e) {
      print('Error fetching cover: $e');
    }
    return null;
  }

  Future<void> _getRpaResponse() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? response = prefs.getString('rpa_response_${widget.bookId}');
      if (mounted) {
        setState(() {
          rpaResponse = response;
        });
      }
    } catch (e) {
      print('Error getting RPA response: $e');
    }
  }

  bool _isRpaSuccessful() {
    if (rpaResponse == null || rpaResponse!.isEmpty) return false;
    
    final lowerResponse = rpaResponse!.toLowerCase();
    
    // Check for error keywords
    final errorKeywords = [
      'error', 'failed', 'gagal', 'timeout', 'connection',
      'tidak dapat', 'server not found', 'network error', 'exception'
    ];
    
    for (String keyword in errorKeywords) {
      if (lowerResponse.contains(keyword)) return false;
    }
    
    // Check for success keywords
    final successKeywords = [
      'berhasil', 'success', 'completed', 'selesai', 'sukses', 'done'
    ];
    
    for (String keyword in successKeywords) {
      if (lowerResponse.contains(keyword)) return true;
    }
    
    // If no error keywords found and response length > 10, consider it successful
    return rpaResponse!.length > 10;
  }

  void _showSnackBar(String message, Color color) {
    if (!mounted) return;
    
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

  void _shareBook() {
    HapticFeedback.lightImpact();
    
    final shareText = '''
📚 ${_currentBook!.judul}
✍️ Pengarang: ${_currentBook!.pengarang}
🏢 Penerbit: ${_currentBook!.penerbitan}
📅 Tahun: ${_currentBook!.tahun}
🏷️ ISBN: ${_currentBook!.isbn}

${_currentBook!.deskripsi}

#OtoBook #BookCatalog
    ''';

    // You can implement actual sharing here using share_plus package
    _showSnackBar('Fitur berbagi akan segera tersedia!', Colors.blue[600]!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: _isLoading ? _buildLoadingState() : _buildContent(),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4A90E2)),
            strokeWidth: 3,
          ),
          SizedBox(height: 16),
          Text(
            'Memuat detail buku...',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_currentBook == null) {
      return _buildErrorState();
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: CustomScrollView(
          slivers: [
            _buildSliverAppBar(),
            SliverToBoxAdapter(
              child: _buildBookDetails(),
            ),
          ],
        ),
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
            const Text(
              'Gagal Memuat Buku',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Terjadi kesalahan saat memuat detail buku',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _loadBookData(),
              icon: const Icon(Icons.refresh),
              label: const Text('Coba Lagi'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4A90E2),
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

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 350,
      pinned: true,
      stretch: true,
      backgroundColor: const Color(0xFF4A90E2),
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
        
      ],
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [
          StretchMode.zoomBackground,
          StretchMode.blurBackground,
        ],
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Book Cover Image
            _buildCoverImage(),
            
            // Gradient Overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.7),
                  ],
                  stops: const [0.6, 1.0],
                ),
              ),
            ),
            
            // Book Title and Author Overlay
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: _buildTitleOverlay(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCoverImage() {
    if (_coverUrl?.isNotEmpty == true) {
      return Hero(
        tag: 'book_cover_${widget.bookId}',
        child: Image.network(
          _coverUrl!,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              color: Colors.grey[200],
              child: Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                      : null,
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF4A90E2)),
                ),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return _buildPlaceholderCover();
          },
        ),
      );
    }
    return _buildPlaceholderCover();
  }

  Widget _buildPlaceholderCover() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF4A90E2),
            const Color(0xFF4A90E2).withOpacity(0.8),
          ],
        ),
      ),
      child: const Center(
        child: Icon(
          Icons.book,
          size: 80,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildTitleOverlay() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _currentBook!.judul,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            shadows: [
              Shadow(
                offset: Offset(0, 2),
                blurRadius: 4,
                color: Colors.black54,
              ),
            ],
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 8),
        Text(
          'oleh ${_currentBook!.pengarang}',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.white,
            shadows: [
              Shadow(
                offset: Offset(0, 1),
                blurRadius: 2,
                color: Colors.black54,
              ),
            ],
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildBookDetails() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          _buildQuickInfoSection(),
          const SizedBox(height: 24),
          _buildPublicationInfoSection(),
          const SizedBox(height: 24),
          _buildDescriptionSection(),
          if (_currentBook!.sinopsis != null && _currentBook!.sinopsis != "No synopsis available") ...[
            const SizedBox(height: 24),
            _buildSinopsisSection(),
          ],
          if (_currentBook!.keyword != null && _currentBook!.keyword!.isNotEmpty) ...[
            const SizedBox(height: 24),
            _buildSubjectSection(),
          ],
          if (_currentBook!.noClass != null && _currentBook!.noClass!.isNotEmpty) ...[
            const SizedBox(height: 24),
            _buildClassificationSection(),
          ],
          const SizedBox(height: 32),
          _buildActionButtons(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildQuickInfoSection() {
    final quickInfo = [
      {'label': 'ISBN', 'value': _currentBook!.isbn ?? 'N/A', 'icon': Icons.tag},
      {'label': 'Kategori', 'value': _currentBook!.kategori ?? 'N/A', 'icon': Icons.category},
      {'label': 'Tahun', 'value': _currentBook!.tahun ?? 'N/A', 'icon': Icons.calendar_today},
    ];

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
      child: Row(
        children: quickInfo.map((info) => Expanded(
          child: _buildQuickInfoItem(
            icon: info['icon'] as IconData,
            label: info['label'] as String,
            value: info['value'] as String,
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildQuickInfoItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF4A90E2).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: const Color(0xFF4A90E2),
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A1A1A),
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildPublicationInfoSection() {
    return _buildInfoSection(
      title: 'Informasi Penerbitan',
      icon: Icons.business,
      color: const Color(0xFF26C6DA),
      children: [
        _buildInfoRow('Penerbit', _currentBook!.penerbitan ?? 'Tidak tersedia', Icons.apartment),
        _buildInfoRow('Kota Terbit', _currentBook!.kota ?? 'Tidak tersedia', Icons.location_city),
        _buildInfoRow('Editor', _currentBook!.editor ?? 'Tidak tersedia', Icons.edit),
        _buildInfoRow('Ilustrator', _currentBook!.ilustrator ?? 'Tidak tersedia', Icons.brush),
      ],
    );
  }

  Widget _buildDescriptionSection() {
    return _buildInfoSection(
      title: 'Deskripsi',
      icon: Icons.description,
      color: const Color(0xFF66BB6A),
      children: [
        Text(
          _currentBook!.deskripsi ?? 'Deskripsi tidak tersedia',
          style: const TextStyle(
            fontSize: 16,
            color: Color(0xFF1A1A1A),
            height: 1.6,
          ),
        ),
      ],
    );
  }

  Widget _buildSinopsisSection() {
    return _buildInfoSection(
      title: 'Sinopsis',
      icon: Icons.menu_book,
      color: const Color(0xFFFF7043),
      children: [
        Text(
          _currentBook!.sinopsis!,
          style: const TextStyle(
            fontSize: 16,
            color: Color(0xFF1A1A1A),
            height: 1.6,
          ),
        ),
      ],
    );
  }

  Widget _buildSubjectSection() {
    return _buildInfoSection(
      title: 'Subjek',
      icon: Icons.subject,
      color: const Color(0xFF9C27B0),
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF9C27B0).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: const Color(0xFF9C27B0).withOpacity(0.2),
            ),
          ),
          child: Text(
            _currentBook!.keyword!,
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF9C27B0),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildClassificationSection() {
    return _buildInfoSection(
      title: 'Klasifikasi Dewey',
      icon: Icons.class_,
      color: const Color(0xFF795548),
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF795548).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: const Color(0xFF795548).withOpacity(0.2),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.confirmation_number,
                color: const Color(0xFF795548),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                _currentBook!.noClass!,
                style: const TextStyle(
                  fontSize: 18,
                  color: Color(0xFF795548),
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoSection({
    required String title,
    required IconData icon,
    required Color color,
    required List<Widget> children,
  }) {
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
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 16,
            color: Colors.grey[500],
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF1A1A1A),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        // Primary Action Button
        if (_currentBook!.sinopsis == "No synopsis available" || 
            _currentBook!.sinopsis == null || 
            _currentBook!.sinopsis!.isEmpty)
          _buildPrimaryButton(
            onPressed: () => _navigateToSinopsisScanner(),
            icon: Icons.add_a_photo,
            label: 'Tambah Sinopsis',
            color: Colors.green[600]!,
          )
        else
          _buildPrimaryButton(
            onPressed: () => _navigateToEditBook(),
            icon: Icons.edit,
            label: 'Edit Buku',
            color: const Color(0xFF4A90E2),
          ),
        
        // RPA Section for "Diolah" category books
        if (_currentBook!.kategori == "Diolah") ...[
          const SizedBox(height: 12),
          _buildRpaSection(),
        ],
      ],
    );
  }

  Widget _buildRpaSection() {
    final bool isRpaSuccessful = _isRpaSuccessful();
    
    if (isRpaSuccessful) {
      return _buildRpaStatusCard();
    } else {
      return _buildSecondaryButton(
        onPressed: () => _navigateToRpaSettings(),
        icon: Icons.auto_awesome,
        label: 'Kirim Ke INLISLITE',
      );
    }
  }

  Widget _buildRpaStatusCard() {
    final bool isSuccess = _isRpaSuccessful();
    final color = isSuccess ? Colors.green : Colors.orange;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  isSuccess ? Icons.check_circle : Icons.info,
                  color: color[600],
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  isSuccess ? 'RPA Berhasil Ditambahkan' : 'Status RPA',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: color[700],
                  ),
                ),
              ),
              IconButton(
                onPressed: () => _navigateToRpaSettings(),
                icon: Icon(
                  Icons.refresh,
                  color: color[600],
                  size: 18,
                ),
                tooltip: 'Jalankan Ulang RPA',
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: color[200]!),
            ),
            child: Text(
              rpaResponse ?? 'No response',
              style: TextStyle(
                fontSize: 12,
                color: color[700],
                fontFamily: 'monospace',
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrimaryButton({
    required VoidCallback onPressed,
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 20),
        label: Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
          shadowColor: color.withOpacity(0.3),
        ),
      ),
    );
  }

  Widget _buildSecondaryButton({
    required VoidCallback onPressed,
    required IconData icon,
    required String label,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 20),
        label: Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF4A90E2),
          side: const BorderSide(color: Color(0xFF4A90E2), width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  // Navigation Methods
  void _navigateToSinopsisScanner() {
    HapticFeedback.selectionClick();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SinopsisScanner(id: widget.bookId),
      ),
    ).then((result) {
      if (result == true) {
        _loadBookData();
        _showSnackBar('Sinopsis berhasil ditambahkan!', Colors.green[600]!);
      }
    });
  }

  void _navigateToEditBook() {
    HapticFeedback.selectionClick();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditbookPage(id: widget.bookId),
      ),
    ).then((result) {
      if (result == true) {
        _loadBookData();
        _showSnackBar('Buku berhasil diperbarui!', Colors.green[600]!);
      }
    });
  }

  void _navigateToRpaSettings() {
    HapticFeedback.selectionClick();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => IpSettingsPage(bookId: widget.bookId),
      ),
    ).then((result) {
      if (result != null) {
        setState(() {
          rpaResponse = result;
        });
        SharedPreferences.getInstance().then((prefs) {
          prefs.setString('rpa_response_${widget.bookId}', result);
        });
        
      }
    });
  }
}