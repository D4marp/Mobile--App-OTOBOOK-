import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:Otobook/services/api.dart';
import 'package:shared_preferences/shared_preferences.dart';

class IpSettingsPage extends StatefulWidget {
  final int bookId;

  const IpSettingsPage({super.key, required this.bookId});

  @override
  _IpSettingsPageState createState() => _IpSettingsPageState();
}

class _IpSettingsPageState extends State<IpSettingsPage> {
  bool _isLoading = false;

  void _runAutomation() async {
    setState(() {
      _isLoading = true; // Mulai pemuatan
    });

    Uri url = Uri.parse(
        '${GetData().runAutomationUrl}/${widget.bookId}'); // Mengambil bookId dari widget
    try {
      final response = await http.post(
        url,
        body: json.encode({
          'bookId': widget.bookId,
          // 'ipAddress': selectedIp,
          // 'username': username,
          // 'password': password,
        }),
        headers: {
          'Content-Type': 'application/json',
        },
      );

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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: terdapat enter pada data')),
        );
        Navigator.pop(context, 'Error: terdapat enter pada data');
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
        title: Text("Run Automasi"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : _runAutomation,
              child: Text(
                'Simpan IP dan Jalankan Automasi untuk Book ID: ${widget.bookId}',
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
