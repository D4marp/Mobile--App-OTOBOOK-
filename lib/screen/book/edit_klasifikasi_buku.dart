import 'dart:convert';


import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:otobook/services/api.dart';

import '../../models/klasifikasi_response_model.dart';

class Editklasifikasibuku extends StatefulWidget {
  final int klasifikasiId;
  const Editklasifikasibuku({super.key, required this.klasifikasiId});

  @override
  State<Editklasifikasibuku> createState() => _EditklasifikasibukuState();
}

class _EditklasifikasibukuState extends State<Editklasifikasibuku> {
  int get klasifikasiId => widget.klasifikasiId;
  late TextEditingController _noClassController;
  late TextEditingController _narasiController;
  late TextEditingController _subjectController;

  bool _isLoading = false;

  @override
  void initState() {
    _noClassController = TextEditingController();
    _narasiController = TextEditingController();
    _subjectController = TextEditingController();
    _fetchKlasifikasiBuku();
    super.initState();
  }

  Future<void> _fetchKlasifikasiBuku() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final response = await http
          .get(Uri.parse('${GetData().getKlasifikasiByIdUrl}/$klasifikasiId'));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final book = Klasifikasi.fromJson(data);
        _noClassController.text = book.deweyNoClass;
        _narasiController.text = book.narasiKlasifikasi ?? '';
        _subjectController.text = book.subject ?? '';
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to fetch book details')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updateKlasifikasi() async {
    setState(() {
      _isLoading = true;
    });

    final updateKlasifikasi = {
      'deweyNoClass': _noClassController.text,
      'narasi_klasifikasi': _narasiController.text,
      'subject': _subjectController.text,
    };
    try {
      final response = await http.put(
          Uri.parse('${GetData().updateKlasifikasiUrl}/$klasifikasiId'),
          headers: {
            'Content-Type': 'application/json',
          },
          body: json.encode(updateKlasifikasi));
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Book updated successfully')),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update book')),
        );
      }
      if (response.statusCode != 200) {
        print('Error: ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _narasiController.dispose();
    _noClassController.dispose();
    super.dispose();
  }

  Future<void> _deleteKlasifikasi() async {
    // Konfirmasi sebelum menghapus
    bool? confirmDelete = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Konfirmasi Hapus'),
          content:
              const Text('Apakah Anda yakin ingin menghapus klasifikasi ini?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );

    if (confirmDelete == true) {
      // Lakukan request ke API untuk menghapus klasifikasi
      try {
        Uri url = Uri.parse(
            '${GetData().deleteKlasifikasiUrl}/$klasifikasiId'); // URL API penghapusan
        final response = await http.delete(
          url,
          headers: {
            'Content-Type': 'application/json',
          },
        );
        final responseBody = jsonDecode(response.body);
        if (response.statusCode == 200) {
          // Berhasil dihapus
          Navigator.pop(context, true); // Kembali setelah penghapusan
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text('Failed to delete book: ${responseBody['message']}'),
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error occurred: $e'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Book'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            _buildTextArea(_noClassController, 'DeweyNoClass'),
                            const SizedBox(height: 16),
                            _buildTextArea(
                                _narasiController, 'Uraian Klasifikasi'),
                            const SizedBox(height: 16),
                            _buildTextArea(_subjectController, 'Subject'),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 40, vertical: 15),
                              backgroundColor: Colors.blueAccent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed:
                                _updateKlasifikasi, // Fungsi untuk update
                            child: const Text(
                              'Update Klasifikasi',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(height: 20), // Jarak antar tombol
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 40, vertical: 15),
                              backgroundColor: Colors
                                  .redAccent, // Warna merah untuk tombol hapus
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed:
                                _deleteKlasifikasi, // Fungsi untuk menghapus
                            child: const Text(
                              'Hapus Klasifikasi',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildTextArea(TextEditingController controller, String labelText) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        border: OutlineInputBorder(),
        labelStyle: const TextStyle(fontSize: 18),
      ),
      maxLines: null,
      keyboardType: TextInputType.multiline,
    );
  }
}