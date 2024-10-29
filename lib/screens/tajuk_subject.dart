import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:csv/csv.dart';

class TajukSubject extends StatefulWidget {
  @override
  _TajukSubjectState createState() => _TajukSubjectState();
}

class _TajukSubjectState extends State<TajukSubject> {
  final _deweyNoClass = TextEditingController();
  final _tajukController = TextEditingController();
  final _nomorController = TextEditingController();
  List<List<String>> _data = [];

  // Menambah data tajuk dan nomor ke list
  void _addTajuk() {
    if (_tajukController.text.isNotEmpty && _nomorController.text.isNotEmpty) {
      setState(() {
        _data.add([_tajukController.text, _nomorController.text, _deweyNoClass.text]);
        _deweyNoClass.clear();
        _tajukController.clear();
        _nomorController.clear();
      });
    }
  }

  // Simpan data dalam file CSV
  Future<void> _saveCSV() async {
    String csvData = const ListToCsvConverter().convert(_data);
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/tajuk_subjek.csv';
    final file = File(path);

    await file.writeAsString(csvData);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Data tersimpan di $path')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tambah Tajuk Subjek', style: TextStyle(fontWeight: FontWeight.w600)),
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
            _buildInputField('DDC Class Number', _deweyNoClass),
            SizedBox(height: 16),
            _buildInputField('Tajuk Subjek', _tajukController),
            SizedBox(height: 16),
            _buildInputField('Nomor DDC', _nomorController),
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
            SizedBox(height: 16),
            Expanded(
              child: _buildDataList(),
            ),
            SizedBox(height: 16),
            Center(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: Icon(Icons.save),
                onPressed: _saveCSV,
                label: Text('Simpan ke CSV', style: TextStyle(fontSize: 16)),
              ),
            ),
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

  Widget _buildDataList() {
    return ListView.builder(
      itemCount: _data.length,
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 6),
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: ListTile(
            leading: Icon(Icons.label, color: Colors.blueAccent),
            title: Text(
              _data[index][0],
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text('Nomor DDC: ${_data[index][1]}'),
            trailing: Icon(Icons.delete, color: Colors.redAccent),
            onTap: () {
              setState(() {
                _data.removeAt(index);
              });
            },
          ),
        );
      },
    );
  }
}
