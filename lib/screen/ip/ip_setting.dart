import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:otobook/services/api.dart';
import 'package:shared_preferences/shared_preferences.dart';

class IpSettingsPage extends StatefulWidget {
  final int bookId;

  const IpSettingsPage({super.key, required this.bookId});

  @override
  _IpSettingsPageState createState() => _IpSettingsPageState();
}

class _IpSettingsPageState extends State<IpSettingsPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
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

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        print(responseData['message']);

        // Simpan pesan ke SharedPreferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString(
            'rpa_response_${widget.bookId}', responseData['message']);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(responseData['message'])),
        );
        Navigator.pop(context, responseData['message']);
      } else {
        // Jika gagal, tampilkan stdout_log atau pesan error lainnya
        String errorMessage = responseData['stdout'] ??
            responseData['error'] ??
            "Terjadi kesalahan dalam eksekusi RPA";

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $errorMessage')),
        );
        Navigator.pop(context, 'Error: $errorMessage');
      }
    } catch (error) {
      Navigator.pop(
          context, 'Failed to connect to the server: server not found');
    } finally {
      setState(() {
        _isLoading = false; // Selesai pemuatan
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Halaman Kontrol Alih Data Elektronis"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Username',
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Password',
              ),
            ),
            SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: _selectedKodeWilayah,
              hint: Text('Pilih Kode Wilayah'),
              items: _kodeWilayahList.map((kode) {
                final kodeWilayah = kode.split(' - ')[0]; // Ambil hanya kode
                return DropdownMenuItem(
                  value: kodeWilayah, // Simpan kode saja sebagai value
                  child: Text(kode), // Tampilkan kode + deskripsi
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedKodeWilayah = value;
                });
              },
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Kode Wilayah',
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Pilih IP Address:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: _ipAddressList.isNotEmpty
                  ? ListView.builder(
                      itemCount: _ipAddressList.length,
                      itemBuilder: (context, index) {
                        final ip = _ipAddressList[index];
                        return RadioListTile<String>(
                          title: Text(ip),
                          value: ip,
                          groupValue: _selectedIp,
                          onChanged: (value) {
                            setState(() {
                              _selectedIp = value;
                            });
                          },
                        );
                      },
                    )
                  : Center(
                      child: Text(
                        'Belum ada IP Address yang ditambahkan.',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: (_isLoading ||
                      _selectedIp == null ||
                      _selectedKodeWilayah == null)
                  ? null
                  : _runAutomation,
              child: Text(
                'Alih Data Elektronis untuk Book ID: ${widget.bookId}',
              ),
            ),
            if (_isLoading)
              Center(
                child: CircularProgressIndicator(),
              ),
          ],
        ),
      ),
    );
  }
}