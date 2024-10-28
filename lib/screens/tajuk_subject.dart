import 'dart:convert';
import 'package:Otobook/services/api.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class TajukSubject extends StatefulWidget {
  @override
  _TajukSubjectState createState() => _TajukSubjectState();
}

class _TajukSubjectState extends State<TajukSubject> {
  final TextEditingController _tajukController = TextEditingController();
  final TextEditingController _narasiController = TextEditingController();
  final TextEditingController _nomorController = TextEditingController();
  List<List<String>> _data = [];

  // Menambah data tajuk dan nomor ke list
  void _addTajuk() async {
    Uri url = Uri.parse(GetData().addKlasifikasiUrl);
    final response = await http.post(url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(<String, String>{
          'subject': _tajukController.text,
          'narasi_klasifikasi': _narasiController.text,
          'deweyNoClass': _nomorController.text,
        }));
    final responseBody = jsonDecode(response.body);

    if (response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(responseBody['message'] ?? 'Data berhasil ditambahkan'),
        ),
      );
      setState(() {
        _data.add([
          _tajukController.text,
          _nomorController.text,
          _narasiController.text,
        ]);
        _tajukController.clear();
        _nomorController.clear();
        _narasiController.clear();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(responseBody['message'] ?? 'Failed to save book'),
        ),
      );
    }
  }

  // Simpan data dalam file CSV
  // Future<void> _saveCSV() async {
  //   String csvData = const ListToCsvConverter().convert(_data);
  //   final directory = await getApplicationDocumentsDirectory();
  //   final path = '${directory.path}/tajuk_subjek.csv';
  //   final file = File(path);

  //   await file.writeAsString(csvData);

  //   ScaffoldMessenger.of(context).showSnackBar(
  //     SnackBar(content: Text('Data tersimpan di $path')),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tambah Tajuk Subjek',
            style: TextStyle(fontWeight: FontWeight.w600)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Masukkan Data Tajuk Subjek',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.blueAccent,
              ),
            ),
            SizedBox(height: 16),
            _buildInputField('DeweyNoClass', _nomorController),
            SizedBox(height: 16),
            _buildInputField('Narasi_klasifikasi', _narasiController),
            SizedBox(height: 16),
            _buildInputField('Subjek', _tajukController),
            SizedBox(height: 16),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: _addTajuk,
                child: Text('Tambahkan', style: TextStyle(fontSize: 16)),
              ),
            ),
            // SizedBox(height: 16),
            // Expanded(
            //   child: _buildDataList(),
            // ),
            // SizedBox(height: 16),
            // Center(
            //   child: ElevatedButton.icon(
            //     style: ElevatedButton.styleFrom(
            //       padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            //       shape: RoundedRectangleBorder(
            //         borderRadius: BorderRadius.circular(10),
            //       ),
            //     ),
            //     icon: Icon(Icons.save),
            //     onPressed: _saveCSV,
            //     label: Text('Simpan ke CSV', style: TextStyle(fontSize: 16)),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        filled: true,
        fillColor: Colors.grey[100],
      ),
    );
  }

  // Widget _buildDataList() {
  //   return ListView.builder(
  //     itemCount: _data.length,
  //     itemBuilder: (context, index) {
  //       return Card(
  //         margin: const EdgeInsets.symmetric(vertical: 6),
  //         elevation: 3,
  //         shape: RoundedRectangleBorder(
  //           borderRadius: BorderRadius.circular(10),
  //         ),
  //         child: ListTile(
  //           leading: Icon(Icons.label, color: Colors.blueAccent),
  //           title: Text(
  //             _data[index][0],
  //             style: TextStyle(fontWeight: FontWeight.w600),
  //           ),
  //           subtitle: Text('Nomor DDC: ${_data[index][1]}'),
  //           trailing: Icon(Icons.delete, color: Colors.redAccent),
  //           onTap: () {
  //             setState(() {
  //               _data.removeAt(index);
  //             });
  //           },
  //         ),
  //       );
  //     },
  //   );
  // }
}
