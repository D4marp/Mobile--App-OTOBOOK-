import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:otobook/models/master_book_response_model.dart';
import 'package:otobook/screen/book/book_detail.dart';
import 'package:otobook/screen/camera/cover_scan.dart';
import 'package:otobook/services/api.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum BookFilter { all, diproses, disumbangkan }

class GetBooksPage extends StatefulWidget {
  const GetBooksPage({super.key});

  @override
  State<GetBooksPage> createState() => _GetBooksPageState();
}

class _GetBooksPageState extends State<GetBooksPage> with TickerProviderStateMixin {
  bool isLoading = false;
  List<masterBook> books = [];
  String noBooksMessage = '';
  BookFilter _selectedFilter = BookFilter.all;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    getBooks();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void getBooks() async {
    setState(() {
      isLoading = true;
    });

    try {
      final result = await GetData.getBooks();
      setState(() {
        books = result;
        if (books.isEmpty) {
          noBooksMessage = 'Anda belum menambahkan buku apapun.';
        } else {
          noBooksMessage = '';
        }
        isLoading = false;
      });
      _animationController.forward();
    } catch (e) {
      setState(() {
        books = [];
        noBooksMessage = 'Buku belum tersedia';
        isLoading = false;
      });
    }
  }

  void getBooksProses() async {
    setState(() {
      isLoading = true;
    });

    try {
      final result = await GetData.getBooksProses();
      setState(() {
        books = result;
        if (books.isEmpty) {
          noBooksMessage = 'Anda belum menambahkan buku apapun.';
        } else {
          noBooksMessage = '';
        }
        isLoading = false;
      });
      _animationController.forward();
    } catch (e) {
      setState(() {
        books = [];
        noBooksMessage = 'Buku belum tersedia';
        isLoading = false;
      });
    }
  }

  void getBooksDisumbangkan() async {
    setState(() {
      isLoading = true;
    });

    try {
      final result = await GetData.getBooksDisumbangkan();
      setState(() {
        books = result;
        if (books.isEmpty) {
          noBooksMessage = 'Anda belum menambahkan buku apapun.';
        } else {
          noBooksMessage = '';
        }
        isLoading = false;
      });
      _animationController.forward();
    } catch (e) {
      setState(() {
        books = [];
        noBooksMessage = 'Buku belum tersedia';
        isLoading = false;
      });
    }
  }

  Future<void> _downloadExcel() async {
    setState(() {
      isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('id');

      if (userId == null) {
        _showModernSnackBar('ID Pengguna tidak ditemukan', Colors.orange, Icons.warning);
        return;
      }

      final url = Uri.parse("${GetData().downloadExcelUrl}?userId=$userId");

      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final bytes = response.bodyBytes;
        final directory = await getApplicationDocumentsDirectory();
        final filePath = '${directory.path}/books.xlsx';
        final file = File(filePath);

        await file.writeAsBytes(bytes);

        _showModernSnackBar('Excel berhasil diunduh', Colors.green, Icons.check_circle);
        await OpenFile.open(file.path);
      } else {
        _showModernSnackBar('Gagal unduh Excel: ${response.body}', Colors.red, Icons.error);
      }
    } catch (e) {
      print(e);
      _showModernSnackBar('Terjadi kesalahan: $e', Colors.red, Icons.error);
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _showModernSnackBar(String message, Color color, IconData icon) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _onFilterChanged(BookFilter? value) {
    if (value == null) return;

    setState(() {
      _selectedFilter = value;
      _animationController.reset();
      if (_selectedFilter == BookFilter.all) {
        getBooks();
      } else if (_selectedFilter == BookFilter.diproses) {
        getBooksProses();
      } else if (_selectedFilter == BookFilter.disumbangkan) {
        getBooksDisumbangkan();
      }
    });
  }

  String _getFilterTitle() {
    switch (_selectedFilter) {
      case BookFilter.all:
        return 'Semua Buku';
      case BookFilter.diproses:
        return 'Buku Diolah';
      case BookFilter.disumbangkan:
        return 'Buku Disumbangkan';
    }
  }

  Widget _buildFilterChips() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: BookFilter.values.map((filter) {
                  final isSelected = _selectedFilter == filter;
                  String label;
                  switch (filter) {
                    case BookFilter.all:
                      label = 'Semua';
                      break;
                    case BookFilter.diproses:
                      label = 'Diolah';
                      break;
                    case BookFilter.disumbangkan:
                      label = 'Disumbangkan';
                      break;
                  }

                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: FilterChip(
                      label: Text(
                        label,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.grey[700],
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        ),
                      ),
                      selected: isSelected,
                      onSelected: (_) => _onFilterChanged(filter),
                      backgroundColor: Colors.grey[100],
                      selectedColor: Colors.blue[600],
                      checkmarkColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: isSelected ? Colors.blue[600]! : Colors.grey[300]!,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          if (_selectedFilter == BookFilter.disumbangkan) ...[
            const SizedBox(width: 12),
            Container(
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                icon: Icon(Icons.download, color: Colors.green[700]),
                onPressed: isLoading ? null : _downloadExcel,
                tooltip: 'Unduh Excel',
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    IconData icon;
    String title;
    String subtitle;

    switch (_selectedFilter) {
      case BookFilter.all:
        icon = Icons.library_books_outlined;
        title = 'Belum Ada Buku';
        subtitle = 'Mulai tambahkan buku pertama Anda';
        break;
      case BookFilter.diproses:
        icon = Icons.hourglass_empty;
        title = 'Tidak Ada Buku Diolah';
        subtitle = 'Buku yang sedang diproses akan muncul di sini';
        break;
      case BookFilter.disumbangkan:
        icon = Icons.volunteer_activism_outlined;
        title = 'Belum Ada Sumbangan';
        subtitle = 'Buku yang telah disumbangkan akan tampil di sini';
        break;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 64,
              color: Colors.blue[400],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
        ),
        title: Text(
          _getFilterTitle(),
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          _buildFilterChips(),
          Expanded(
            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                    ),
                  )
                : books.isEmpty
                    ? _buildEmptyState()
                    : FadeTransition(
                        opacity: _fadeAnimation,
                        child: ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: books.length,
                          itemBuilder: (context, index) {
                            return SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(0, 0.3),
                                end: Offset.zero,
                              ).animate(CurvedAnimation(
                                parent: _animationController,
                                curve: Interval(
                                  (index * 0.1).clamp(0.0, 1.0),
                                  1.0,
                                  curve: Curves.easeOutBack,
                                ),
                              )),
                              child: BookItem(
                                book: books[index],
                                index: index,
                                onDelete: () {
                                  switch (_selectedFilter) {
                                    case BookFilter.all:
                                      getBooks();
                                      break;
                                    case BookFilter.diproses:
                                      getBooksProses();
                                      break;
                                    case BookFilter.disumbangkan:
                                      getBooksDisumbangkan();
                                      break;
                                  }
                                },
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}

class BookItem extends StatelessWidget {
  final masterBook book;
  final int index;
  final VoidCallback onDelete;

  const BookItem({
    super.key,
    required this.book,
    required this.index,
    required this.onDelete,
  });

  Future<Map<String, dynamic>> _deleteBook(BuildContext context, int id) async {
    Uri url = Uri.parse("${GetData().deleteBookUrl}/$id");

    try {
      final response = await http.delete(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      final responseBody = jsonDecode(response.body);

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Text('Buku berhasil dihapus'),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(16),
          ),
        );
        onDelete();
        return responseBody;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text('Gagal menghapus buku: ${responseBody['message']}'),
                ),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(16),
          ),
        );
        return responseBody;
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.warning, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(child: Text('Terjadi kesalahan: $e')),
            ],
          ),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
      return {'message': 'Terjadi kesalahan: $e'};
    }
  }

  Future<String> fetchCoverPath(int masterBukuId) async {
    final response = await http.get(
      Uri.parse('${GetData().getCoverUrl}/$masterBukuId'),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return data['path'];
    } else {
      throw Exception('Gagal memuat sampul');
    }
  }

  void _showBookOptionsModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(25),
              topRight: Radius.circular(25),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 50,
                height: 5,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _buildModalOption(
                      context: context,
                      icon: Icons.camera_alt_outlined,
                      iconColor: Colors.blue,
                      title: 'Tambah Sampul',
                      subtitle: 'Ambil foto sampul buku',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CoverScanner(id: book.id),
                          ),
                        ).then((result) {
                          if (result == true) {
                            onDelete();
                          }
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildModalOption(
                      context: context,
                      icon: Icons.delete_outline,
                      iconColor: Colors.red,
                      title: 'Hapus Buku',
                      subtitle: 'Hapus buku secara permanen',
                      onTap: () async {
                        Navigator.pop(context);
                        await _deleteBook(context, book.id);
                      },
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildModalOption({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
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
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            spreadRadius: 1,
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BookDetailPage(bookId: book.id),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Hero(
                  tag: 'book_cover_${book.id}',
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: FutureBuilder<String>(
                        future: fetchCoverPath(book.id),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return Container(
                              width: 80,
                              height: 120,
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: const Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                                ),
                              ),
                            );
                          } else if (snapshot.hasError || !snapshot.hasData) {
                            return Image.asset(
                              'assets/placeholder.jpg',
                              width: 80,
                              height: 120,
                              fit: BoxFit.cover,
                            );
                          } else {
                            final coverPath = snapshot.data!;
                            final coverUrl = '${GetData().Url}$coverPath';
                            return Image.network(
                              coverUrl,
                              width: 80,
                              height: 120,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Image.asset(
                                  'assets/placeholder.jpg',
                                  width: 80,
                                  height: 120,
                                  fit: BoxFit.cover,
                                );
                              },
                            );
                          }
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        book.judul,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.person_outline,
                            size: 16,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              book.pengarang,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.more_vert,
                      color: Colors.grey,
                      size: 20,
                    ),
                    onPressed: () => _showBookOptionsModal(context),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}