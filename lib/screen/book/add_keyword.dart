import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:otobook/models/user_response_model.dart';
import 'package:otobook/services/api.dart';
import 'package:otobook/widget/navigation_menu.dart';

class AddKeywordPages extends StatefulWidget {
  final Sinopsisbook sinopsisBookData;
  const AddKeywordPages({Key? key, required this.sinopsisBookData})
      : super(key: key);

  @override
  State<AddKeywordPages> createState() => _AddKeywordPagesState();
}

class _AddKeywordPagesState extends State<AddKeywordPages>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late Sinopsisbook _sinopsisBook;
  late TextEditingController _sinopsisController;
  late TextEditingController _masterBookIdController;
  final TextEditingController _keywordController = TextEditingController();
  final TextEditingController _noClassController = TextEditingController();

  bool _isLoadingKeyword = false;
  bool _isSaving = false;
  bool _hasGeneratedKeyword = false;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _sinopsisBook = widget.sinopsisBookData;
    _sinopsisController = TextEditingController(text: _sinopsisBook.sinopsis);
    _masterBookIdController = TextEditingController(
      text: _sinopsisBook.masterBookId.toString(),
    );
    _initializeAnimations();
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
    _sinopsisController.dispose();
    _masterBookIdController.dispose();
    _keywordController.dispose();
    _noClassController.dispose();
    super.dispose();
  }

  int get masterBookId => widget.sinopsisBookData.masterBookId;

  // Validation functions
  String? _validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName harus diisi';
    }
    if (value.trim().isEmpty) {
      return '$fieldName minimal 3 karakter';
    }
    return null;
  }

  Future<Map<String, dynamic>> _saveKeyword(int id) async {
    if (!_formKey.currentState!.validate()) {
      _showSnackBar(
        'Mohon lengkapi semua field dengan benar',
        Colors.orange[600]!,
        Icons.warning,
      );
      return {};
    }

    setState(() {
      _isSaving = true;
    });

    try {
      HapticFeedback.lightImpact();
      Uri url = Uri.parse(GetData().addSinopsisUrl + id.toString());
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(<String, String>{
          'sinopsis': _sinopsisController.text.trim(),
          'keyword': _keywordController.text.trim(),
          'no_class': _noClassController.text.trim(),
          'masterBookId': _masterBookIdController.text.trim(),
        }),
      ).timeout(const Duration(seconds: 30));

      final responseBody = jsonDecode(response.body);

      if (response.statusCode == 201) {
        HapticFeedback.mediumImpact();
        _showSnackBar(
          responseBody['message'] ?? 'Data buku berhasil disimpan!',
          Colors.green[600]!,
          Icons.check_circle,
        );
        
        await Future.delayed(const Duration(milliseconds: 1500));
        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const NavigationMenu()),
            (Route<dynamic> route) => false,
          );
        }
      } else {
        HapticFeedback.heavyImpact();
        _showSnackBar(
          responseBody['message'] ?? 'Gagal menyimpan data buku',
          Colors.red[600]!,
          Icons.error_outline,
        );
      }
      return responseBody;
    } catch (e) {
      HapticFeedback.heavyImpact();
      String errorMessage = 'Terjadi kesalahan saat menyimpan';
      if (e.toString().contains('TimeoutException')) {
        errorMessage = 'Koneksi timeout. Periksa jaringan Anda.';
      } else if (e.toString().contains('SocketException')) {
        errorMessage = 'Tidak dapat terhubung ke server';
      }
      
      _showSnackBar(errorMessage, Colors.red[600]!, Icons.wifi_off);
      return {};
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  Future<void> _keyword({required String sinopsis}) async {
    if (sinopsis.trim().isEmpty) {
      _showSnackBar(
        'Sinopsis harus diisi terlebih dahulu',
        Colors.orange[600]!,
        Icons.warning,
      );
      return;
    }

    setState(() {
      _isLoadingKeyword = true;
    });

    try {
      HapticFeedback.lightImpact();
      Uri url = Uri.parse(GetData().getKlasifikasiUrl);
      final result = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(<String, String>{'sinopsis': sinopsis.trim()}),
      ).timeout(const Duration(seconds: 30));

      final response = jsonDecode(result.body);

      if (result.statusCode == 200) {
        HapticFeedback.mediumImpact();
        setState(() {
          _noClassController.text = response['deweyNoClass'] ?? 
              'Dewey Decimal Classification tidak ada di database';
          _keywordController.text = response['subject'] ?? 
              'Subjek tidak ada di database';
          _hasGeneratedKeyword = true;
        });
        
        _showSnackBar(
          'Keyword dan klasifikasi berhasil dihasilkan!',
          Colors.green[600]!,
          Icons.auto_awesome,
        );
      } else {
        setState(() {
          _keywordController.text = 'Data tidak ditemukan';
          _noClassController.text = 'Data tidak ditemukan';
        });
        
        _showSnackBar(
          'Data klasifikasi tidak ditemukan',
          Colors.orange[600]!,
          Icons.info,
        );
      }
    } catch (e) {
      print('Error fetching keywords: $e');
      String errorMessage = 'Gagal mendapatkan klasifikasi';
      if (e.toString().contains('TimeoutException')) {
        errorMessage = 'Koneksi timeout. Periksa jaringan Anda.';
      } else if (e.toString().contains('SocketException')) {
        errorMessage = 'Tidak dapat terhubung ke server';
      }
      
      setState(() {
        _keywordController.text = 'Gagal mendapatkan kata kunci';
        _noClassController.text = 'Gagal mendapatkan klasifikasi Dewey';
      });
      
      _showSnackBar(errorMessage, Colors.red[600]!, Icons.wifi_off);
    } finally {
      setState(() {
        _isLoadingKeyword = false;
      });
    }
  }

  void _showSnackBar(String message, Color color, IconData icon) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
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
      appBar: AppBar(
        title: const Text(
          'Tambah Keyword & Klasifikasi',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 20,
            color: Color(0xFF1A1A1A),
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1A1A1A),
        elevation: 0,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        shadowColor: Colors.black.withOpacity(0.1),
        surfaceTintColor: Colors.white,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: Image.asset('assets/logo_oto.PNG', height: 32),
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeaderCard(),
                  const SizedBox(height: 24),
                  _buildSinopsisSection(),
                  const SizedBox(height: 24),
                  _buildGenerateSection(),
                  const SizedBox(height: 24),
                  _buildKeywordSection(),
                  const SizedBox(height: 24),
                  _buildClassificationSection(),
                  const SizedBox(height: 100), // Space for bottom button
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _isLoadingKeyword || _isSaving 
                    ? null 
                    : () => _keyword(sinopsis: _sinopsisController.text),
                icon: _isLoadingKeyword
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
                        ),
                      )
                    : const Icon(Icons.auto_awesome, size: 18),
                label: Text(
                  _isLoadingKeyword ? 'Memproses...' : 'Generate',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF6366F1),
                  side: const BorderSide(color: Color(0xFF6366F1), width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  disabledForegroundColor: Colors.grey[400],
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 2,
              child: ElevatedButton.icon(
                onPressed: _isSaving || _isLoadingKeyword
                    ? null
                    : () async {
                        if (_keywordController.text.trim().isEmpty) {
                          _showSnackBar(
                            'Subject harus diisi sebelum menyimpan!',
                            Colors.orange[600]!,
                            Icons.warning,
                          );
                        } else {
                          _saveKeyword(masterBookId);
                        }
                      },
                icon: _isSaving
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.save, size: 18),
                label: Text(
                  _isSaving ? 'Menyimpan...' : 'Simpan Data',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2196F3),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  elevation: 0,
                  disabledBackgroundColor: Colors.grey[400],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF2196F3).withOpacity(0.1),
            const Color(0xFF2196F3).withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2196F3).withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF2196F3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.auto_awesome,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'AI Keyword Generator',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Book ID: ${widget.sinopsisBookData.masterBookId}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          if (_hasGeneratedKeyword)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.check_circle,
                    color: Colors.green[600],
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Generated',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.green[600],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSinopsisSection() {
    return _buildSection(
      title: 'Sinopsis Buku',
      icon: Icons.description,
      color: const Color(0xFF10B981),
      child: _buildTextFormField(
        controller: _sinopsisController,
        label: 'Sinopsis',
        hint: 'Masukkan sinopsis buku yang telah dipindai',
        icon: Icons.description,
        maxLines: 5,
        validator: (value) => _validateRequired(value, 'Sinopsis'),
      ),
    );
  }

  Widget _buildGenerateSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF6366F1).withOpacity(0.2)),
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  color: Color(0xFF6366F1),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Generate Otomatis',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF6366F1).withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF6366F1).withOpacity(0.1)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  color: const Color(0xFF6366F1),
                  size: 20,
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Klik tombol "Generate" untuk menghasilkan keyword dan klasifikasi Dewey secara otomatis berdasarkan sinopsis',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6366F1),
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKeywordSection() {
    return _buildSection(
      title: 'Subject/Keyword',
      icon: Icons.label,
      color: const Color(0xFFEF4444),
      child: _buildTextFormField(
        controller: _keywordController,
        label: 'Subject',
        hint: _isLoadingKeyword 
            ? 'Menghasilkan keyword...' 
            : 'Subject akan dihasilkan otomatis atau masukkan manual',
        icon: Icons.label,
        maxLines: 3,
        validator: (value) => _validateRequired(value, 'Subject'),
        enabled: !_isLoadingKeyword,
      ),
    );
  }

  Widget _buildClassificationSection() {
    return _buildSection(
      title: 'Klasifikasi Dewey',
      icon: Icons.numbers,
      color: const Color(0xFFFF9800),
      child: _buildTextFormField(
        controller: _noClassController,
        label: 'Dewey No Class',
        hint: _isLoadingKeyword 
            ? 'Menghasilkan klasifikasi...' 
            : 'Klasifikasi Dewey akan dihasilkan otomatis',
        icon: Icons.numbers,
        maxLines: 2,
        validator: (value) => _validateRequired(value, 'Dewey No Class'),
        enabled: !_isLoadingKeyword,
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Color color,
    required Widget child,
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
                child: Icon(
                  icon,
                  color: color,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A1A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
    int maxLines = 1,
    bool enabled = true,
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
          validator: validator,
          maxLines: maxLines,
          enabled: enabled,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Container(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF2196F3).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: const Color(0xFF2196F3),
                size: 18,
              ),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF2196F3), width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[200]!),
            ),
            filled: true,
            fillColor: enabled ? Colors.grey[50] : Colors.grey[100],
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
          keyboardType: TextInputType.multiline,
        ),
      ],
    );
  }
}