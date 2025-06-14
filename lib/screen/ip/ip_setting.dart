import 'dart:convert';
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
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

 void _runAutomation() async {
  setState(() {
    _isLoading = true;
  });

  try {
    final username = _usernameController.text;
    final password = _passwordController.text;
    final ipMatch = RegExp(r'(\d+\.\d+\.\d+\.\d+(?::\d+)?)')
        .firstMatch(_selectedIp ?? '');
    final extractedIp = ipMatch?.group(0) ?? '';
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
    );

    // ✅ PERBAIKAN: Decode JSON hanya sekali
    final responseData = json.decode(response.body);
    print('Response Status: ${response.statusCode}');
    print('Response Data: $responseData');

    if (response.statusCode == 200) {
      // ✅ PERBAIKAN: Gunakan responseData yang sudah di-decode
      final message = responseData['message'] ?? 'RPA berhasil dijalankan';
      print('Success Message: $message');

      // Simpan pesan ke SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('rpa_response_${widget.bookId}', message);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.green[600], // ✅ Tambah indikator sukses
        ),
      );
      Navigator.pop(context, message);
      
    } else {
      // ✅ PERBAIKAN: Error handling yang lebih spesifik
      String errorMessage = responseData['stdout'] ??
          responseData['error'] ??
          responseData['message'] ??
          "Terjadi kesalahan dalam eksekusi RPA (Status: ${response.statusCode})";

      print('Error Message: $errorMessage');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $errorMessage'),
          backgroundColor: Colors.red[600], // ✅ Tambah indikator error
        ),
      );
      Navigator.pop(context, 'Error: $errorMessage');
    }
  } catch (error) {
    // ✅ PERBAIKAN: Error handling yang lebih informatif
    print('Exception occurred: $error');
    final errorMessage = 'Failed to connect to the server: ${error.toString()}';
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(errorMessage),
        backgroundColor: Colors.red[600],
      ),
    );
    Navigator.pop(context, errorMessage);
  } finally {
    setState(() {
      _isLoading = false;
    });
  }
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
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
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
                  'Automatisasi RPA',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 4),
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
              const Text(
                'Kredensial Akses',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A1A),
                ),
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
              TextField(
                controller: _usernameController, // Keep original controller
                decoration: InputDecoration(
                  hintText: 'Masukkan username Anda',
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
              TextField(
                controller: _passwordController, // Keep original controller
                obscureText: !_isPasswordVisible, // Keep original obscureText logic
                decoration: InputDecoration(
                  hintText: 'Masukkan password Anda',
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
              const Text(
                'Wilayah Tujuan',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A1A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _selectedKodeWilayah, // Keep original value
            hint: const Text('Pilih Kode Wilayah'), // Keep original hint
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
            // Keep original items mapping logic EXACTLY the same
            items: _kodeWilayahList.map((kode) {
              final kodeWilayah = kode.split(' - ')[0]; // Ambil hanya kode
              return DropdownMenuItem(
                value: kodeWilayah, // Simpan kode saja sebagai value
                child: Text(kode), // Tampilkan kode + deskripsi
              );
            }).toList(),
            // Keep original onChanged logic EXACTLY the same
            onChanged: (value) {
              setState(() {
                _selectedKodeWilayah = value;
              });
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
              const Text(
                'Pilih IP Address',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A1A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // IP Address List - Keep original logic EXACTLY the same
          Container(
            height: 200,
            child: _ipAddressList.isNotEmpty
                ? Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListView.builder(
                      itemCount: _ipAddressList.length, // Keep original itemCount
                      itemBuilder: (context, index) {
                        final ip = _ipAddressList[index]; // Keep original ip variable
                        final isSelected = _selectedIp == ip;
                        return Container(
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFF9C27B0).withOpacity(0.1) : Colors.transparent,
                            border: index < _ipAddressList.length - 1
                                ? Border(bottom: BorderSide(color: Colors.grey[200]!))
                                : null,
                          ),
                          child: RadioListTile<String>(
                            title: Text(
                              ip, // Keep original ip display
                              style: TextStyle(
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                fontSize: 14,
                                color: isSelected ? const Color(0xFF9C27B0) : const Color(0xFF1A1A1A),
                              ),
                            ),
                            value: ip, // Keep original value
                            groupValue: _selectedIp, // Keep original groupValue
                            activeColor: const Color(0xFF9C27B0),
                            // Keep original onChanged logic EXACTLY the same
                            onChanged: (value) {
                              setState(() {
                                _selectedIp = value;
                              });
                            },
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                          'Belum ada IP Address yang ditambahkan.', // Keep original text
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
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
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        // Keep original onPressed logic EXACTLY the same
        onPressed: (_isLoading ||
                _selectedIp == null ||
                _selectedKodeWilayah == null)
            ? null
            : _runAutomation, // Keep original _runAutomation function
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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.play_arrow, size: 20),
            const SizedBox(width: 8),
            Flexible(
              // Keep original text EXACTLY the same
              child: Text(
                'Alih Data Elektronis untuk Book ID: ${widget.bookId}',
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
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Column(
          children: [
            CircularProgressIndicator( // Keep original CircularProgressIndicator
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2196F3)),
              strokeWidth: 3,
            ),
            SizedBox(height: 16),
            Text(
              'Memproses automasi RPA...',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Color(0xFF1A1A1A),
              ),
            ),
          ],
        ),
      ),
    );
  }
}