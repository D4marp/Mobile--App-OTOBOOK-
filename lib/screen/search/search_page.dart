import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:otobook/models/master_book_response_model.dart';
import 'package:otobook/screen/book/book_search.dart';
import 'package:otobook/screen/camera/cover_scan.dart';
import 'package:otobook/services/api.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  List<masterBook> _books = [];
  bool _isLoading = false;
  String _errorMessage = '';
  String _userName = 'Guest';
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  Future<void> _fetchUserData() async {
    try {
      final userData = await getUserData();
      if (mounted) {
        setState(() {
          _userName = userData['username'] ?? 'Guest';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _userName = 'Guest';
        });
      }
      debugPrint('Error fetching user data: $e');
    }
  }

  Future<Map<String, dynamic>> getUserData() async {
    int? id = await getId();
    if (id == null) throw Exception('No user ID found');

    final response = await http.get(
      Uri.parse('${GetData().getUserIdUrl}/$id'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return {
        'username': data['username'],
        'email': data['email'],
        'path': data['path'],
      };
    } else {
      throw Exception('Failed to load user data');
    }
  }

  Future<int?> getId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return int.tryParse(prefs.getString('id') ?? '');
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        20,
        MediaQuery.of(context).padding.top > 0 ? 8 : 16,
        20,
        16,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            Colors.grey[50]!,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            spreadRadius: 1,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isSmallScreen = constraints.maxWidth < 360;
            return Row(
                children: [
                // User greeting section
                Expanded(
                  flex: 3,
                  child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                    children: [
                      Text(
                      'Hi, ',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: isSmallScreen ? 16 : 18,
                        fontWeight: FontWeight.w400,
                      ),
                      ),
                      Flexible(
                      child: Text(
                        _userName,
                        style: TextStyle(
                        color: Colors.black87,
                        fontSize: isSmallScreen ? 18 : 20,
                        fontWeight: FontWeight.w700,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                      '👋',
                      style: TextStyle(
                        fontSize: isSmallScreen ? 16 : 18,
                      ),
                      ),
                    ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                    'Temukan buku favoritmu',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: isSmallScreen ? 12 : 13,
                      fontWeight: FontWeight.w400,
                    ),
                    ),
                  ],
                  ),
                ),
                const SizedBox(width: 12),
                // Logo section
                Hero(
                  tag: 'otobook-logo',
                  child: Image.asset(
                  'assets/logo_oto.PNG',
                  height: isSmallScreen ? 40 : 45,
                  width: isSmallScreen ? 40 : 45,
                  fit: BoxFit.contain,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _onSearch(String keyword) async {
    if (keyword.trim().isEmpty) return;
    
    _searchFocusNode.unfocus();
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    
    try {
      Uri url = Uri.parse(GetData().searchBookUrl);
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(<String, String>{'keyword': keyword.trim()}),
      );
      
      if (response.statusCode == 200) {
        final body = response.body;
        final result = jsonDecode(body);

        if (result['data'] != null && result['data'].isNotEmpty) {
          setState(() {
            _books = List<masterBook>.from(
              result['data'].map((i) => masterBook.fromJson(i)),
            );
          });
          _animationController.forward(from: 0);
        } else {
          setState(() {
            _errorMessage = 'Tidak ada buku yang cocok dengan pencarian Anda.';
          });
        }
      } else {
        setState(() {
          _errorMessage = 'Gagal mencari buku. Silakan coba lagi.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Terjadi kesalahan jaringan. Periksa koneksi internet Anda.';
      });
      debugPrint('Search error: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<String> fetchCoverPath(int masterBukuId) async {
    final response = await http.get(
      Uri.parse('${GetData().getCoverUrl}/$masterBukuId'),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return data['path'] ?? '';
    } else {
      throw Exception('Failed to load cover');
    }
  }

  Future<void> _deleteBook(BuildContext context, int id) async {
    try {
      final response = await http.delete(
        Uri.parse('${GetData().deleteBookUrl}/$id'),
        headers: {'Content-Type': 'application/json'},
      );

      final responseBody = jsonDecode(response.body);

      if (response.statusCode == 200) {
        _showSnackBar('Buku berhasil dihapus', Colors.green, Icons.check_circle);
        if (_searchController.text.isNotEmpty) {
          _onSearch(_searchController.text);
        }
      } else {
        _showSnackBar(
          'Gagal menghapus buku: ${responseBody['message'] ?? 'Unknown error'}',
          Colors.red,
          Icons.error,
        );
      }
    } catch (e) {
      _showSnackBar('Terjadi kesalahan: $e', Colors.orange, Icons.warning);
      debugPrint('Delete error: $e');
    }
  }

  void _showSnackBar(String message, Color color, IconData icon) {
    if (!mounted) return;
    
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Widget _buildSearchBar() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 12,
                spreadRadius: 1,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextField(
            controller: _searchController,
            focusNode: _searchFocusNode,
            textInputAction: TextInputAction.search,
            style: const TextStyle(fontSize: 15),
            decoration: InputDecoration(
              hintText: 'Cari judul buku, pengarang...',
              hintStyle: TextStyle(
                color: Colors.grey[400],
                fontSize: 15,
              ),
              prefixIcon: Container(
                padding: const EdgeInsets.all(12),
                child: Icon(
                  Icons.search_rounded,
                  color: Colors.teal[600],
                  size: 22,
                ),
              ),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: Icon(
                        Icons.clear_rounded,
                        color: Colors.grey[500],
                        size: 20,
                      ),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _books.clear();
                          _errorMessage = '';
                        });
                        _animationController.reset();
                      },
                      splashRadius: 20,
                    )
                  : null,
              filled: true,
              fillColor: Colors.transparent,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),
            ),
            onSubmitted: _onSearch,
            onChanged: (value) => setState(() {}),
          ),
        );
      },
    );
  }

  Widget _buildBookCard(masterBook book, int index) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmallScreen = constraints.maxWidth < 360;
        
        return FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
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
            child: Container(
              margin: EdgeInsets.only(
                left: 20,
                right: 20,
                bottom: 16,
                top: index == 0 ? 8 : 0,
              ),
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
                        builder: (context) => Booksearch(bookId: book.id),
                      ),
                    );
                  },
                  child: Padding(
                    padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
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
                                  final coverWidth = isSmallScreen ? 70.0 : 80.0;
                                  final coverHeight = isSmallScreen ? 100.0 : 120.0;
                                  
                                  if (snapshot.connectionState == ConnectionState.waiting) {
                                    return Container(
                                      width: coverWidth,
                                      height: coverHeight,
                                      decoration: BoxDecoration(
                                        color: Colors.grey[200],
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      child: const Center(
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation<Color>(Colors.teal),
                                        ),
                                      ),
                                    );
                                  } else if (snapshot.hasError || !snapshot.hasData) {
                                    return Container(
                                      width: coverWidth,
                                      height: coverHeight,
                                      decoration: BoxDecoration(
                                        color: Colors.grey[200],
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      child: Icon(
                                        Icons.book_outlined,
                                        color: Colors.grey[400],
                                        size: isSmallScreen ? 28 : 32,
                                      ),
                                    );
                                  } else {
                                    final coverUrl = '${GetData().Url}${snapshot.data!}';
                                    return Image.network(
                                      coverUrl,
                                      width: coverWidth,
                                      height: coverHeight,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Container(
                                          width: coverWidth,
                                          height: coverHeight,
                                          decoration: BoxDecoration(
                                            color: Colors.grey[200],
                                            borderRadius: BorderRadius.circular(15),
                                          ),
                                          child: Icon(
                                            Icons.book_outlined,
                                            color: Colors.grey[400],
                                            size: isSmallScreen ? 28 : 32,
                                          ),
                                        );
                                      },
                                    );
                                  }
                                },
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: isSmallScreen ? 12 : 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                book.judul,
                                style: TextStyle(
                                  fontSize: isSmallScreen ? 16 : 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                  height: 1.3,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(
                                    Icons.person_outline_rounded,
                                    size: isSmallScreen ? 14 : 16,
                                    color: Colors.grey[600],
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      book.pengarang,
                                      style: TextStyle(
                                        fontSize: isSmallScreen ? 12 : 14,
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
                            icon: Icon(
                              Icons.more_vert_rounded,
                              color: Colors.blueAccent,
                              size: isSmallScreen ? 18 : 20,
                            ),
                            onPressed: () => _showBookOptionsModal(book),
                            splashRadius: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showBookOptionsModal(masterBook book) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
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
                      icon: Icons.camera_alt_outlined,
                      iconColor: Colors.teal,
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
                            setState(() {
                              _onSearch(_searchController.text);
                            });
                          }
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildModalOption(
                      icon: Icons.delete_outline_rounded,
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
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
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

  Widget _buildEmptyState() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmallScreen = constraints.maxWidth < 360;
        
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(isSmallScreen ? 24 : 32),
                  decoration: BoxDecoration(
                    color: Colors.blueAccent.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.search_rounded,
                    size: isSmallScreen ? 48 : 64,
                    color: Colors.blueAccent,
                  ),
                ),
                SizedBox(height: isSmallScreen ? 16 : 24),
                Text(
                  'Tidak ada hasil',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 16 : 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: isSmallScreen ? 6 : 8),
                Text(
                  'Coba gunakan kata kunci yang berbeda\natau periksa ejaan Anda',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 13 : 14,
                    color: Colors.grey[600],
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildErrorState() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmallScreen = constraints.maxWidth < 360;
        
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(isSmallScreen ? 20 : 24),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.error_outline_rounded,
                    size: isSmallScreen ? 40 : 48,
                    color: Colors.red,
                  ),
                ),
                SizedBox(height: isSmallScreen ? 16 : 20),
                Text(
                  'Oops! Terjadi kesalahan',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 16 : 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: isSmallScreen ? 6 : 8),
                Text(
                  _errorMessage,
                  style: TextStyle(
                    fontSize: isSmallScreen ? 13 : 14,
                    color: Colors.grey[600],
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: isSmallScreen ? 20 : 24),
                ElevatedButton.icon(
                  onPressed: () {
                    if (_searchController.text.isNotEmpty) {
                      _onSearch(_searchController.text);
                    }
                  },
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: const Text('Coba Lagi'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(
                      horizontal: isSmallScreen ? 20 : 24,
                      vertical: isSmallScreen ? 10 : 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInitialState() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmallScreen = constraints.maxWidth < 360;
        
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(isSmallScreen ? 24 : 32),
                  decoration: BoxDecoration(
                    color: Colors.teal.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.menu_book_rounded,
                    size: isSmallScreen ? 48 : 64,
                    color: Colors.teal,
                  ),
                ),
                SizedBox(height: isSmallScreen ? 16 : 24),
                Text(
                  'Mulai pencarian',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 16 : 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: isSmallScreen ? 6 : 8),
                Text(
                  'Ketik judul buku atau nama pengarang\nuntuk mencari buku yang Anda inginkan',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 13 : 14,
                    color: Colors.grey[600],
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 16),
            _buildSearchBar(),
            const SizedBox(height: 16),
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.teal),
                      ),
                    )
                  : _errorMessage.isNotEmpty
                      ? _buildErrorState()
                      : _books.isEmpty
                          ? (_searchController.text.isEmpty
                              ? _buildInitialState()
                              : _buildEmptyState())
                          : ListView.builder(
                              physics: const BouncingScrollPhysics(),
                              itemCount: _books.length,
                              itemBuilder: (context, index) {
                                return _buildBookCard(_books[index], index);
                              },
                            ),
            ),
          ],
        ),
      ),
    );
  }
}