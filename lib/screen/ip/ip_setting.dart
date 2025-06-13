import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import 'package:otobook/services/api.dart';
import 'package:shared_preferences/shared_preferences.dart';

class IpSettingsPage extends StatefulWidget {
  final int bookId;

  const IpSettingsPage({super.key, required this.bookId});

  @override
  _IpSettingsPageState createState() => _IpSettingsPageState();
}

class _IpSettingsPageState extends State<IpSettingsPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  
  bool _isLoading = false;
  bool _isPasswordVisible = false;
  List<String> _ipAddressList = [];
  String? _selectedIp;
  String? _selectedKodeWilayah;
  
  final List<String> _kodeWilayahList = [
    'JIPDSUR - DISPERPUSIP Jawa Timur',
    'JIPKPBK - UPT Perpustakaan Kota Blitar',
    'JIPUBAN - DISPERPUSIP Bangkalan',
    'JIPUBAT - DISPERPUSIP Kota Batu',
    'JIPUBAY - DISPERPUSIP Banyuwangi'
  ];

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _ipAddressList = [
      '103.106.72.182:8772 (public server)',
      '127.0.0.1 (localhost)',
      '192.168.1.226 (ip jatim)',
      '10.0.0.1 (ip random)',
      '10.0.0.2 (ip random)'
    ];
    _initializeAnimations();
    _loadSavedCredentials();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController, 
        curve: const Interval(0.0, 0.6, curve: Curves.easeInOut),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 0.8, curve: Curves.easeOutCubic),
    ));

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.4, 1.0, curve: Curves.elasticOut),
      ),
    );

    _animationController.forward();
  }

  // Load saved credentials from SharedPreferences
  Future<void> _loadSavedCredentials() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final savedUsername = prefs.getString('rpa_username');
      final savedRegion = prefs.getString('rpa_region');
      final savedIp = prefs.getString('rpa_ip');
      
      if (savedUsername != null) {
        _usernameController.text = savedUsername;
      }
      if (savedRegion != null && _kodeWilayahList.any((item) => item.split(' - ')[0] == savedRegion)) {
        _selectedKodeWilayah = savedRegion;
      }
      if (savedIp != null && _ipAddressList.contains(savedIp)) {
        _selectedIp = savedIp;
      }
      
      if (mounted) setState(() {});
    } catch (e) {
      print('Error loading saved credentials: $e');
    }
  }

  // Save credentials to SharedPreferences
  Future<void> _saveCredentials() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('rpa_username', _usernameController.text.trim());
      if (_selectedKodeWilayah != null) {
        await prefs.setString('rpa_region', _selectedKodeWilayah!);
      }
      if (_selectedIp != null) {
        await prefs.setString('rpa_ip', _selectedIp!);
      }
    } catch (e) {
      print('Error saving credentials: $e');
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Form validation
  String? _validateUsername(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Username harus diisi';
    }
    if (value.trim().length < 3) {
      return 'Username minimal 3 karakter';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Password harus diisi';
    }
    if (value.length < 4) {
      return 'Password minimal 4 karakter';
    }
    return null;
  }

  bool _validateForm() {
    if (!_formKey.currentState!.validate()) {
      _showErrorSnackBar('Mohon lengkapi form dengan benar');
      return false;
    }
    if (_selectedKodeWilayah == null) {
      _showErrorSnackBar('Pilih wilayah tujuan');
      return false;
    }
    if (_selectedIp == null) {
      _showErrorSnackBar('Pilih IP Address');
      return false;
    }
    return true;
  }

  void _runAutomation() async {
    if (!_validateForm()) return;

    setState(() {
      _isLoading = true;
    });

    HapticFeedback.lightImpact();
    await _saveCredentials(); // Save credentials before running

    try {
      final username = _usernameController.text.trim();
      final password = _passwordController.text.trim();
      final ipMatch = RegExp(r'(\d+\.\d+\.\d+\.\d+(?::\d+)?)')
          .firstMatch(_selectedIp ?? '');
      final extractedIp = ipMatch?.group(0) ?? '';
      
      print('🚀 Starting RPA automation...');
      print('📍 Target IP: $extractedIp');
      print('🏢 Region: $_selectedKodeWilayah');
      print('📚 Book ID: ${widget.bookId}');
      
      Uri url = Uri.parse('${GetData().runAutomationUrl}/${widget.bookId}');
      final response = await http.post(
        url,
        body: json.encode({
          'bookId': widget.bookId,
          'kodeWilayah': _selectedKodeWilayah,
          'ipAddress': extractedIp,
          'username': username,
          'password': password,
        }),
        headers: {
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 90)); // Extended timeout for RPA

      // Decode JSON response
      final responseData = json.decode(response.body);
      print('📊 Response Status: ${response.statusCode}');
      print('📄 Response Data: $responseData');

      // Check if response is actually successful
      bool isActualSuccess = _isResponseSuccess(responseData, response.statusCode);
      
      if (isActualSuccess) {
        // ✅ TRUE SUCCESS
        final message = responseData['message'] ?? 'RPA berhasil dijalankan';
        print('✅ TRUE SUCCESS: $message');

        // Save response to SharedPreferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('rpa_response_${widget.bookId}', message);

        HapticFeedback.mediumImpact();
        _showSuccessSnackBar(message);
        
        // Delay before navigation for better UX
        await Future.delayed(const Duration(milliseconds: 1500));
        if (mounted) {
          Navigator.pop(context, message);
        }
        
      } else {
        // ✅ ERROR DETECTED
        String errorMessage = _extractErrorMessage(responseData, response.statusCode);
        print('❌ ACTUAL ERROR: $errorMessage');

        HapticFeedback.heavyImpact();
        _showErrorSnackBar(errorMessage);
        Navigator.pop(context, 'Error: $errorMessage');
      }
      
    } on TimeoutException {
      final errorMessage = 'RPA timeout - proses memakan waktu terlalu lama (>90 detik)';
      print('⏱️ TIMEOUT: $errorMessage');
      HapticFeedback.heavyImpact();
      _showErrorSnackBar(errorMessage);
      Navigator.pop(context, errorMessage);
      
    } on SocketException {
      final errorMessage = 'Tidak dapat terhubung ke server RPA';
      print('🌐 CONNECTION ERROR: $errorMessage');
      HapticFeedback.heavyImpact();
      _showErrorSnackBar(errorMessage);
      Navigator.pop(context, errorMessage);
      
    } on FormatException {
      final errorMessage = 'Server mengembalikan response yang tidak valid';
      print('📄 FORMAT ERROR: $errorMessage');
      HapticFeedback.heavyImpact();
      _showErrorSnackBar(errorMessage);
      // ignore: use_build_context_synchronously
      Navigator.pop(context, errorMessage);
      
    } catch (error) {
      final errorMessage = 'RPA Error: ${error.toString()}';
      HapticFeedback.heavyImpact();
      _showErrorSnackBar(errorMessage);
      // ignore: use_build_context_synchronously
      Navigator.pop(context, errorMessage);
      
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Enhanced success detection with more comprehensive checks
  bool _isResponseSuccess(Map<String, dynamic> responseData, int statusCode) {
    // Non-2xx status codes are definitely errors
    if (statusCode < 200 || statusCode >= 300) {
      return false;
    }
    
    // Check for explicit error indicators
    List<String> errorIndicators = [
      'error', 'stderr', 'stdout', 'exception', 'failed', 'gagal', 'fail'
    ];
    
    for (String indicator in errorIndicators) {
      if (responseData.containsKey(indicator)) {
        final errorValue = responseData[indicator];
        if (errorValue != null && 
            errorValue.toString().trim().isNotEmpty && 
            errorValue.toString().toLowerCase() != 'null' &&
            errorValue.toString().toLowerCase() != 'false') {
          print('🚨 Error detected in field "$indicator": $errorValue');
          return false;
        }
      }
    }
    
    // Check message content for error keywords
    final message = responseData['message']?.toString().toLowerCase() ?? '';
    List<String> errorWords = [
      'error', 'gagal', 'failed', 'timeout', 'connection', 'refused', 
      'not found', 'invalid', 'unauthorized', 'forbidden', 'bad request'
    ];
    
    for (String errorWord in errorWords) {
      if (message.contains(errorWord)) {
        print('🚨 Error detected in message: $message');
        return false;
      }
    }
    
    // Check for success indicators
    List<String> successWords = [
      'berhasil', 'success', 'completed', 'done', 'finished', 'ok', 'successful'
    ];
    
    for (String successWord in successWords) {
      if (message.contains(successWord)) {
        print('✅ Success confirmed in message: $message');
        return true;
      }
    }
    
    // If no clear indicators, trust the status code
    return statusCode == 200;
  }

  // Enhanced error message extraction
  String _extractErrorMessage(Map<String, dynamic> responseData, int statusCode) {
    // Priority 1: stderr (RPA process errors)
    if (responseData['stderr'] != null && 
        responseData['stderr'].toString().trim().isNotEmpty &&
        responseData['stderr'].toString().toLowerCase() != 'null') {
      return 'RPA Process Error: ${responseData['stderr']}';
    }
    
    // Priority 2: stdout (RPA output that might contain errors)
    if (responseData['stdout'] != null && 
        responseData['stdout'].toString().trim().isNotEmpty &&
        responseData['stdout'].toString().toLowerCase() != 'null') {
      final stdout = responseData['stdout'].toString();
      if (stdout.toLowerCase().contains('error') || 
          stdout.toLowerCase().contains('failed') ||
          stdout.toLowerCase().contains('exception')) {
        return 'RPA Output: $stdout';
      }
    }
    
    // Priority 3: explicit error field
    if (responseData['error'] != null && 
        responseData['error'].toString().trim().isNotEmpty &&
        responseData['error'].toString().toLowerCase() != 'null') {
      return responseData['error'].toString();
    }
    
    // Priority 4: message field (if contains error indicators)
    if (responseData['message'] != null) {
      final message = responseData['message'].toString();
      final lowerMessage = message.toLowerCase();
      if (lowerMessage.contains('error') || 
          lowerMessage.contains('gagal') ||
          lowerMessage.contains('failed') ||
          lowerMessage.contains('timeout')) {
        return message;
      }
    }
    
    // Priority 5: HTTP status-based message
    switch (statusCode) {
      case 400:
        return "Bad Request - Data yang dikirim tidak valid";
      case 401:
        return "Unauthorized - Kredensial tidak valid";
      case 403:
        return "Forbidden - Akses ditolak";
      case 404:
        return "Not Found - Endpoint RPA tidak ditemukan";
      case 500:
        return "Internal Server Error - Kesalahan server RPA";
      case 502:
        return "Bad Gateway - Server RPA tidak dapat diakses";
      case 503:
        return "Service Unavailable - Layanan RPA sedang tidak tersedia";
      default:
        return "RPA gagal dieksekusi (HTTP $statusCode)";
    }
  }

  // Enhanced success notification
  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.check_circle, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'RPA Berhasil Dijalankan! 🎉',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    message,
                    style: const TextStyle(fontSize: 12, color: Colors.white70),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green[600],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 5),
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  // Enhanced error notification
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.error_outline, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'RPA Gagal Dijalankan ❌',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    message,
                    style: const TextStyle(fontSize: 12, color: Colors.white70),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red[600],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 6),
        action: SnackBarAction(
          label: 'Tutup',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          "Kontrol Alih Data Elektronis",
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
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showInfoDialog(),
            tooltip: 'Informasi RPA',
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    _buildHeaderCard(),
                    const SizedBox(height: 24),
                    _buildCredentialsSection(),
                    const SizedBox(height: 24),
                    _buildRegionSection(),
                    const SizedBox(height: 24),
                    _buildIpAddressSection(),
                    const SizedBox(height: 32),
                    _buildActionButton(),
                    if (_isLoading) ...[
                      const SizedBox(height: 24),
                      _buildLoadingIndicator(),
                    ],
                    const SizedBox(height: 20),
                    _buildInfoCard(),
                  ],
                ),
              ),
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
            const Color(0xFF2196F3).withOpacity(0.15),
            const Color(0xFF2196F3).withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2196F3).withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2196F3).withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF2196F3),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF2196F3).withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
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
                  'Automatisasi RPA',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.book,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Book ID: ${widget.bookId}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
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
                  Icons.bolt,
                  size: 16,
                  color: Colors.green[600],
                ),
                const SizedBox(width: 4),
                Text(
                  'AI',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCredentialsSection() {
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
                  color: const Color(0xFF4CAF50).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.security,
                  color: Color(0xFF4CAF50),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Kredensial Akses',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
              ),
              Icon(
                Icons.verified_user,
                color: Colors.green[600],
                size: 20,
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Username Field
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Username',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _usernameController,
                validator: _validateUsername,
                decoration: InputDecoration(
                  hintText: 'Masukkan username RPA Anda',
                  prefixIcon: Container(
                    margin: const EdgeInsets.all(12),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4CAF50).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.person_outline,
                      color: Color(0xFF4CAF50),
                      size: 18,
                    ),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF4CAF50), width: 2),
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
          ),
          
          const SizedBox(height: 16),
          
          // Password Field
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Password',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _passwordController,
                validator: _validatePassword,
                obscureText: !_isPasswordVisible,
                decoration: InputDecoration(
                  hintText: 'Masukkan password RPA Anda',
                  prefixIcon: Container(
                    margin: const EdgeInsets.all(12),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4CAF50).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.lock_outline,
                      color: Color(0xFF4CAF50),
                      size: 18,
                    ),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                      color: Colors.grey[500],
                    ),
                    onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF4CAF50), width: 2),
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
          ),
        ],
      ),
    );
  }

  Widget _buildRegionSection() {
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
                  color: const Color(0xFFFF9800).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.location_on,
                  color: Color(0xFFFF9800),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Wilayah Tujuan',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
              ),
              if (_selectedKodeWilayah != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Terpilih',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange[600],
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _selectedKodeWilayah,
            hint: const Text('Pilih Kode Wilayah Target'),
            isExpanded: true,
            decoration: InputDecoration(
              prefixIcon: Container(
                margin: const EdgeInsets.all(12),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF9800).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.account_balance,
                  color: Color(0xFFFF9800),
                  size: 18,
                ),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFFF9800), width: 2),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              filled: true,
              fillColor: Colors.grey[50],
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
            items: _kodeWilayahList.map((kode) {
              final kodeWilayah = kode.split(' - ')[0];
              final namaWilayah = kode.split(' - ')[1];
              return DropdownMenuItem(
                value: kodeWilayah,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      kodeWilayah,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      namaWilayah,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedKodeWilayah = value;
              });
              HapticFeedback.selectionClick();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildIpAddressSection() {
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
                  color: const Color(0xFF9C27B0).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.dns,
                  color: Color(0xFF9C27B0),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Server IP Address',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.purple[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${_ipAddressList.length} Server',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple[600],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          Container(
            height: 220,
            child: _ipAddressList.isNotEmpty
                ? Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListView.builder(
                      itemCount: _ipAddressList.length,
                      itemBuilder: (context, index) {
                        final ip = _ipAddressList[index];
                        final isSelected = _selectedIp == ip;
                        final ipParts = ip.split(' ');
                        final ipAddress = ipParts[0];
                        final description = ipParts.length > 1 ? ipParts.sublist(1).join(' ') : '';
                        
                        return Container(
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFF9C27B0).withOpacity(0.1) : Colors.transparent,
                            border: index < _ipAddressList.length - 1
                                ? Border(bottom: BorderSide(color: Colors.grey[200]!))
                                : null,
                          ),
                          child: RadioListTile<String>(
                            title: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        ipAddress,
                                        style: TextStyle(
                                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                                          fontSize: 14,
                                          color: isSelected ? const Color(0xFF9C27B0) : const Color(0xFF1A1A1A),
                                        ),
                                      ),
                                      if (description.isNotEmpty)
                                        Text(
                                          description,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: isSelected ? const Color(0xFF9C27B0).withOpacity(0.7) : Colors.grey[600],
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                if (isSelected)
                                  Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF9C27B0),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(
                                      Icons.check,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ),
                              ],
                            ),
                            value: ip,
                            groupValue: _selectedIp,
                            activeColor: const Color(0xFF9C27B0),
                            onChanged: (value) {
                              setState(() {
                                _selectedIp = value;
                              });
                              HapticFeedback.selectionClick();
                            },
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                        );
                      },
                    ),
                  )
                : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.dns_outlined,
                          size: 48,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Belum ada IP Address yang tersedia',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Hubungi administrator untuk menambahkan server',
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton() {
    final isFormValid = _selectedIp != null && 
                       _selectedKodeWilayah != null &&
                       _usernameController.text.trim().isNotEmpty &&
                       _passwordController.text.trim().isNotEmpty;

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: (_isLoading || !isFormValid) ? null : _runAutomation,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2196F3),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
          disabledBackgroundColor: Colors.grey[300],
          disabledForegroundColor: Colors.grey[600],
        ),
        child: _isLoading
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Memproses RPA...',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.rocket_launch, size: 20),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      'Jalankan RPA untuk Book ID: ${widget.bookId}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 60,
                  height: 60,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2196F3)),
                    strokeWidth: 4,
                  ),
                ),
                const Icon(
                  Icons.auto_awesome,
                  color: Color(0xFF2196F3),
                  size: 24,
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              'Menjalankan Automasi RPA',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Proses mungkin memakan waktu hingga 90 detik',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2196F3)),
              backgroundColor: Colors.grey[200],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: Colors.blue[600],
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Informasi RPA',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue[700],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'RPA akan mengotomatisasi proses alih data elektronik ke sistem target berdasarkan kredensial dan server yang dipilih.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.blue[600],
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showInfoDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Icon(Icons.info, color: Colors.blue[600]),
              const SizedBox(width: 8),
              const Text('Informasi RPA'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoItem('🤖', 'Robotic Process Automation', 'Sistem otomatis untuk alih data elektronik'),
              _buildInfoItem('⏱️', 'Waktu Proses', 'Maksimal 90 detik per eksekusi'),
              _buildInfoItem('🔐', 'Keamanan', 'Kredensial disimpan lokal dan tidak dikirim ke server eksternal'),
              _buildInfoItem('📊', 'Status', 'Realtime monitoring dengan notifikasi hasil'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Tutup'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildInfoItem(String emoji, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}