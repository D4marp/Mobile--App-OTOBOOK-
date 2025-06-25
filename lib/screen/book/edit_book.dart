import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:otobook/models/master_book_response_model.dart';
import 'package:otobook/services/api.dart';

class EditbookPage extends StatefulWidget {
  final int id;

  const EditbookPage({super.key, required this.id});

  @override
  State<EditbookPage> createState() => _EditbookPageState();
}

class _EditbookPageState extends State<EditbookPage>
    with SingleTickerProviderStateMixin {
  late TextEditingController _judulController;
  late TextEditingController _pengarangController;
  late TextEditingController _penerbitanController;
  late TextEditingController _deskripsiController;
  late TextEditingController _isbnController;
  late TextEditingController _kotaController;
  late TextEditingController _tahunController;
  late TextEditingController _editorController;
  late TextEditingController _ilustratorController;
  late TextEditingController _sinopsisController;
  late TextEditingController _keywordController;
  late TextEditingController _noClassController;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String? selectedValue;
  List<String> items = ['Diolah', 'Disumbangkan'];
  bool _isLoading = false;
  bool _isUpdating = false;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _initializeAnimations();
    _fetchBookDetails();
  }

  void _initializeControllers() {
    _judulController = TextEditingController();
    _pengarangController = TextEditingController();
    _penerbitanController = TextEditingController();
    _deskripsiController = TextEditingController();
    _isbnController = TextEditingController();
    _kotaController = TextEditingController();
    _tahunController = TextEditingController();
    _editorController = TextEditingController();
    _ilustratorController = TextEditingController();
    _sinopsisController = TextEditingController();
    _keywordController = TextEditingController();
    _noClassController = TextEditingController();
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
    _judulController.dispose();
    _pengarangController.dispose();
    _penerbitanController.dispose();
    _deskripsiController.dispose();
    _isbnController.dispose();
    _kotaController.dispose();
    _tahunController.dispose();
    _editorController.dispose();
    _ilustratorController.dispose();
    _sinopsisController.dispose();
    _keywordController.dispose();
    _noClassController.dispose();
    super.dispose();
  }

  // Validation functions
  String? _validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName harus diisi';
    }
    return null;
  }

  String? _validateISBN(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'ISBN harus diisi';
    }
    final cleanISBN = value.replaceAll(RegExp(r'[^0-9X]'), '').toUpperCase();
    if (cleanISBN.length != 10 && cleanISBN.length != 13) {
      return 'Format ISBN tidak valid';
    }
    return null;
  }

  String? _validateYear(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Tahun terbit harus diisi';
    }
    final year = int.tryParse(value);
    if (year == null || year < 1000 || year > DateTime.now().year) {
      return 'Tahun tidak valid';
    }
    return null;
  }

  Future<void> _fetchBookDetails() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse('${GetData().getBookWithSinopsisUrl}${widget.id}'),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final book = masterBook.fromJson(data);
        
        _judulController.text = book.judul;
        _pengarangController.text = book.pengarang;
        _penerbitanController.text = book.penerbitan;
        _deskripsiController.text = book.deskripsi;
        _isbnController.text = book.isbn;
        _kotaController.text = book.kota;
        _tahunController.text = book.tahun;
        _editorController.text = book.editor;
        _ilustratorController.text = book.ilustrator ?? '';
        selectedValue = book.kategori ?? 'Diolah';
        _sinopsisController.text = book.sinopsis ?? '';
        _keywordController.text = book.keyword ?? '';
        _noClassController.text = book.noClass ?? '';
      } else {
        _showSnackBar(
          'Gagal memuat detail buku',
          Colors.red[600]!,
          Icons.error_outline,
        );
      }
    } catch (e) {
      String errorMessage = 'Terjadi kesalahan';
      if (e.toString().contains('TimeoutException')) {
        errorMessage = 'Koneksi timeout. Periksa jaringan Anda.';
      } else if (e.toString().contains('SocketException')) {
        errorMessage = 'Tidak dapat terhubung ke server';
      }
      
      _showSnackBar(errorMessage, Colors.red[600]!, Icons.wifi_off);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updateBook() async {
    if (!_formKey.currentState!.validate()) {
      _showSnackBar(
        'Mohon lengkapi semua field dengan benar',
        Colors.orange[600]!,
        Icons.warning,
      );
      return;
    }

    setState(() {
      _isUpdating = true;
    });

    HapticFeedback.lightImpact();

    final updatedBook = {
      'judul': _judulController.text.trim(),
      'pengarang': _pengarangController.text.trim(),
      'penerbitan': _penerbitanController.text.trim(),
      'deskripsi': _deskripsiController.text.trim(),
      'isbn': _isbnController.text.trim(),
      'kota': _kotaController.text.trim(),
      'tahun_terbit': _tahunController.text.trim(),
      'editor': _editorController.text.trim(),
      'ilustrator': _ilustratorController.text.trim(),
      'kategori': selectedValue,
      'sinopsis': _sinopsisController.text.trim(),
      'keyword': _keywordController.text.trim(),
      'no_class': _noClassController.text.trim(),
    };

    try {
      final response = await http.put(
        Uri.parse('${GetData().editBookSinopsisUrl}/${widget.id}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(updatedBook),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        HapticFeedback.mediumImpact();
        _showSnackBar(
          'Buku berhasil diperbarui!',
          Colors.green[600]!,
          Icons.check_circle,
        );
        
        // Delay before navigating back
        await Future.delayed(const Duration(milliseconds: 1500));
        if (mounted) {
          Navigator.pop(context, true);
        }
      } else {
        HapticFeedback.heavyImpact();
        _showSnackBar(
          'Gagal memperbarui buku. Kode: ${response.statusCode}',
          Colors.red[600]!,
          Icons.error_outline,
        );
      }
    } catch (e) {
      HapticFeedback.heavyImpact();
      String errorMessage = 'Terjadi kesalahan saat memperbarui';
      if (e.toString().contains('TimeoutException')) {
        errorMessage = 'Koneksi timeout. Periksa jaringan Anda.';
      } else if (e.toString().contains('SocketException')) {
        errorMessage = 'Tidak dapat terhubung ke server';
      }
      
      _showSnackBar(errorMessage, Colors.red[600]!, Icons.wifi_off);
    } finally {
      setState(() {
        _isUpdating = false;
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
          'Edit Buku',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF3B82F6),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        actions: [
          if (!_isLoading && !_isUpdating)
            TextButton.icon(
              onPressed: _updateBook,
              icon: const Icon(Icons.save, color: Colors.white, size: 18),
              label: const Text(
                'Simpan',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
      body: _isLoading ? _buildLoadingState() : _buildForm(),
      bottomNavigationBar: _isLoading || _isUpdating
          ? null
          : Container(
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
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, size: 18),
                      label: const Text(
                        'Batal',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.grey[600],
                        side: BorderSide(color: Colors.grey[300]!, width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: _isUpdating ? null : _updateBook,
                      icon: _isUpdating
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
                        _isUpdating ? 'Menyimpan...' : 'Simpan Perubahan',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3B82F6),
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

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3B82F6)),
            strokeWidth: 3,
          ),
          const SizedBox(height: 16),
          Text(
            'Memuat detail buku...',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return FadeTransition(
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
                _buildBasicInfoSection(),
                const SizedBox(height: 24),
                _buildPublishingInfoSection(),
                const SizedBox(height: 24),
                _buildContentSection(),
                const SizedBox(height: 100), // Space for bottom navigation
              ],
            ),
          ),
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
            const Color(0xFF3B82F6).withOpacity(0.1),
            const Color(0xFF3B82F6).withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF3B82F6).withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF3B82F6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.edit_note,
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
                  'Edit Detail Buku',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'ID Buku: ${widget.id}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return _buildSection(
      title: 'Informasi Dasar',
      icon: Icons.book,
      color: const Color(0xFF10B981),
      children: [
        _buildTextField(
          controller: _judulController,
          label: 'Judul Buku',
          hint: 'Masukkan judul buku',
          icon: Icons.title,
          validator: (value) => _validateRequired(value, 'Judul'),
          maxLines: 2,
        ),
        const SizedBox(height: 20),
        _buildTextField(
          controller: _pengarangController,
          label: 'Pengarang',
          hint: 'Masukkan nama pengarang',
          icon: Icons.person,
          validator: (value) => _validateRequired(value, 'Pengarang'),
        ),
        const SizedBox(height: 20),
        _buildTextField(
          controller: _isbnController,
          label: 'ISBN',
          hint: 'Masukkan nomor ISBN',
          icon: Icons.tag,
          validator: _validateISBN,
          keyboardType: TextInputType.text,
        ),
        const SizedBox(height: 20),
        _buildDropdownField(),
      ],
    );
  }

  Widget _buildPublishingInfoSection() {
    return _buildSection(
      title: 'Informasi Penerbitan',
      icon: Icons.business,
      color: const Color(0xFFEF4444),
      children: [
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller: _penerbitanController,
                label: 'Penerbit',
                hint: 'Masukkan nama penerbit',
                icon: Icons.business,
                validator: (value) => _validateRequired(value, 'Penerbit'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildTextField(
                controller: _tahunController,
                label: 'Tahun Terbit',
                hint: 'YYYY',
                icon: Icons.calendar_today,
                validator: _validateYear,
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        _buildTextField(
          controller: _kotaController,
          label: 'Kota Terbit',
          hint: 'Masukkan kota penerbitan',
          icon: Icons.location_city,
          validator: (value) => _validateRequired(value, 'Kota'),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller: _editorController,
                label: 'Editor',
                hint: 'Masukkan nama editor',
                icon: Icons.edit,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildTextField(
                controller: _ilustratorController,
                label: 'Ilustrator',
                hint: 'Masukkan nama ilustrator',
                icon: Icons.brush,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildContentSection() {
    return _buildSection(
      title: 'Konten & Klasifikasi',
      icon: Icons.description,
      color: const Color(0xFF8B5CF6),
      children: [
        _buildTextField(
          controller: _deskripsiController,
          label: 'Deskripsi',
          hint: 'Masukkan deskripsi buku',
          icon: Icons.description,
          validator: (value) => _validateRequired(value, 'Deskripsi'),
          maxLines: 3,
        ),
        const SizedBox(height: 20),
        _buildTextField(
          controller: _sinopsisController,
          label: 'Sinopsis',
          hint: 'Masukkan sinopsis buku',
          icon: Icons.article,
          maxLines: 4,
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller: _keywordController,
                label: 'Kata Kunci',
                hint: 'Masukkan kata kunci (pisahkan dengan koma)',
                icon: Icons.label,
                maxLines: 2,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildTextField(
                controller: _noClassController,
                label: 'Nomor Dewey',
                hint: 'Masukkan klasifikasi Dewey',
                icon: Icons.numbers,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Color color,
    required List<Widget> children,
  }) {
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
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A1A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
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
          validator: validator,
          keyboardType: keyboardType,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Container(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF3B82F6).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: const Color(0xFF3B82F6),
                size: 18,
              ),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 2),
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
            filled: true,
            fillColor: Colors.grey[50],
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Kategori',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: selectedValue,
          hint: const Text('Pilih kategori buku'),
          isExpanded: true,
          decoration: InputDecoration(
            prefixIcon: Container(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.category,
                color: Color(0xFF10B981),
                size: 18,
              ),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF10B981), width: 2),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            filled: true,
            fillColor: Colors.grey[50],
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
          items: items.map((item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              selectedValue = value;
            });
          },
          validator: (value) {
            if (value == null) {
              return 'Kategori harus dipilih';
            }
            return null;
          },
        ),
      ],
    );
  }
}