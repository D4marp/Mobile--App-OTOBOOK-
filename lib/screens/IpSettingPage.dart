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
  // List<String> ipList = ['192.168.9.62', '192.168.1.2', '192.168.1.3'];

  // String? selectedIp;
  // String username = '';
  // String password = '';
  // Fungsi untuk menjalankan automasi
  void _runAutomation() async {
    // if (selectedIp == null && username.isEmpty && password.isEmpty) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     SnackBar(content: Text('Tidak ada IP yang dipilih atau username dan password kosong.')),
    //   );
    //   return;
    // }
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
            // Input untuk username
            // TextFormField(
            //   decoration: InputDecoration(
            //     labelText: 'Username',
            //     border: OutlineInputBorder(),
            //   ),
            //   onChanged: (value) {
            //     setState(() {
            //       username = value;
            //     });
            //   },
            // ),
            // SizedBox(height: 20),
            // // Input untuk password
            // TextFormField(
            //   decoration: InputDecoration(
            //     labelText: 'Password',
            //     border: OutlineInputBorder(),
            //   ),
            //   obscureText: true, // Menyembunyikan input password
            //   onChanged: (value) {
            //     setState(() {
            //       password = value;
            //     });
            //   },
            // ),
            // SizedBox(height: 20.0),
            // Text('Pilih Alamat IP:'),
            // // Membuat daftar checkbox untuk setiap IP
            // Column(
            //   children: ipList.map((ip) {
            //     return RadioListTile<String>(
            //       title: Text(ip),
            //       value: ip,
            //       groupValue: selectedIp,
            //       onChanged: (String? value) {
            //         setState(() {
            //           selectedIp = value;
            //         });
            //       },
            //     );
            //   }).toList(),
            // ),
            SizedBox(height: 20),

            ElevatedButton(
              onPressed: () {
                // if (username.isNotEmpty &&
                //     password.isNotEmpty &&
                //     selectedIp != null)
                // {
                _runAutomation(); // Jalankan automasi setelah IP dipilih
                //   } else {
                //     ScaffoldMessenger.of(context).showSnackBar(
                //       SnackBar(
                //           content: Text(
                //               'Harap isi username, password, dan pilih IP terlebih dahulu.')),
                //     );
                //   }
              },
              child: Text(
                'Simpan IP dan Jalankan Automasi untuk Book ID: ${widget.bookId}',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
