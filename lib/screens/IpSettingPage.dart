import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:Otobook/services/api.dart';

class IpSettingsPage extends StatefulWidget {
  final int bookId;

  const IpSettingsPage({super.key, required this.bookId});

  @override
  _IpSettingsPageState createState() => _IpSettingsPageState();
}

class _IpSettingsPageState extends State<IpSettingsPage> {
  final TextEditingController _ipController = TextEditingController();

  // Fungsi untuk menjalankan automasi
  void _runAutomation(String enteredIp) async {
    Uri url = Uri.parse(
        '${GetData().runAutomationUrl}/${widget.bookId}'); // Mengambil bookId dari widget
    try {
      final response = await http.post(
        url,
        body: json.encode({
          'bookId': widget.bookId, // Kirim bookId sebagai parameter
          'ipAdress': enteredIp, // Kirim IP yang diatur
        }),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Automation triggered: ${responseData['message']}'),
          ),
        );
      } else {
        final responseData = json.decode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${responseData['error']}')),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to connect to the server: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Pengaturan IP"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _ipController,
              decoration: InputDecoration(
                labelText: 'Masukkan IP Address',
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                String enteredIp = _ipController.text;

                // Simpan IP dan jalankan automasi
                Navigator.pop(context,
                    enteredIp); // Kembali ke halaman sebelumnya dengan IP yang diatur
                _runAutomation(
                    enteredIp); // Jalankan automasi setelah IP diatur
              },
              child: Text(
                  'Simpan IP dan Jalankan Automasi untuk Book ID: ${widget.bookId}'),
            ),
          ],
        ),
      ),
    );
  }
}
