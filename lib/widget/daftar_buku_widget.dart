import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:otobook/models/master_book_response_model.dart';
import 'package:otobook/services/api.dart';
import 'package:otobook/screen/book/book_detail.dart';
import 'package:shimmer/shimmer.dart';

class DaftarBukuWidget extends StatefulWidget {
  const DaftarBukuWidget({super.key});

  @override
  State<DaftarBukuWidget> createState() => _DaftarBukuWidgetState();
}

class _DaftarBukuWidgetState extends State<DaftarBukuWidget> 
    with AutomaticKeepAliveClientMixin {
  
  bool _isLoading = true; // Start with loading
  List<masterBook> _books = [];
  bool _hasLoaded = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadBooks();
  }

  Future<void> _loadBooks() async {
    if (!mounted) return;
    
    try {
      final result = await GetData.getBooks();
      
      if (mounted) {
        setState(() {
          _books = result ?? [];
          _isLoading = false;
          _hasLoaded = true;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _books = [];
          _isLoading = false;
          _hasLoaded = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    // Still loading - don't show anything
    if (_isLoading) {
      return const SizedBox.shrink();
    }

    // Loaded but no books - show completely empty
    if (_hasLoaded && _books.isEmpty) {
      return const SizedBox.shrink();
    }

    // Has books - show the widget
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = MediaQuery.of(context).size.width;
        final isSmallScreen = screenWidth < 360;
        final cardWidth = isSmallScreen ? 100.0 : 115.0;
        final imageHeight = isSmallScreen ? 120.0 : 135.0;
        
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(),
              const SizedBox(height: 8),
              SizedBox(
                height: imageHeight + 60,
                child: _buildBooksList(cardWidth, imageHeight),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Daftar Buku',
            style: TextStyle(
              color: Color(0xFF1A1A1A),
              fontSize: 18,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${_books.length} buku',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 6),
              GestureDetector(
                onTap: () {
                  setState(() => _isLoading = true);
                  _loadBooks();
                },
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Icon(
                    Icons.refresh,
                    size: 14,
                    color: Colors.blue[600],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBooksList(double cardWidth, double imageHeight) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: _books.length,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(right: 12),
          child: CompactBookCard(
            book: _books[index],
            cardWidth: cardWidth,
            imageHeight: imageHeight,
          ),
        );
      },
    );
  }
}

class CompactBookCard extends StatefulWidget {
  final masterBook book;
  final double cardWidth;
  final double imageHeight;
  
  const CompactBookCard({
    required this.book,
    required this.cardWidth,
    required this.imageHeight,
    super.key,
  });

  @override
  State<CompactBookCard> createState() => _CompactBookCardState();
}

class _CompactBookCardState extends State<CompactBookCard> {
  String? _coverUrl;
  bool _isLoadingCover = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadCover();
  }

  Future<void> _loadCover() async {
    try {
      final response = await http.get(
        Uri.parse('${GetData().getCoverUrl}/${widget.book.id}'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final coverPath = data['path'] as String?;
        
        if (mounted && coverPath != null && coverPath.isNotEmpty) {
          setState(() {
            _coverUrl = '${GetData().Url}$coverPath';
            _isLoadingCover = false;
            _hasError = false;
          });
        } else {
          if (mounted) {
            setState(() {
              _isLoadingCover = false;
              _hasError = true;
            });
          }
        }
      } else {
        if (mounted) {
          setState(() {
            _isLoadingCover = false;
            _hasError = true;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingCover = false;
          _hasError = true;
        });
      }
    }
  }

  void _navigateToDetail() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => BookDetailPage(bookId: widget.book.id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _navigateToDetail,
      child: Container(
        width: widget.cardWidth,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildCoverImage(),
            _buildBookInfo(),
          ],
        ),
      ),
    );
  }

  Widget _buildCoverImage() {
    return Container(
      height: widget.imageHeight,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
            child: _buildImageContent(),
          ),
          
          if (widget.book.kategori != null)
            Positioned(
              top: 4,
              right: 4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: BoxDecoration(
                  color: _getCategoryColor().withOpacity(0.9),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  widget.book.kategori!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 8,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildImageContent() {
    if (_isLoadingCover) {
      return Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.grey.shade300,
        ),
      );
    }

    if (_hasError || _coverUrl == null) {
      return Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blue[100]!,
              Colors.blue[200]!,
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.book,
              size: widget.cardWidth * 0.25,
              color: Colors.blue[600],
            ),
            const SizedBox(height: 4),
            Text(
              'No Cover',
              style: TextStyle(
                fontSize: 8,
                color: Colors.blue[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return Hero(
      tag: 'book_cover_${widget.book.id}',
      child: Image.network(
        _coverUrl!,
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          
          return Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.grey.shade300,
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.red[100]!,
                  Colors.red[200]!,
                ],
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.broken_image,
                  size: widget.cardWidth * 0.25,
                  color: Colors.red[600],
                ),
                const SizedBox(height: 4),
                Text(
                  'Error',
                  style: TextStyle(
                    fontSize: 8,
                    color: Colors.red[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBookInfo() {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.book.judul ?? 'Untitled',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 11,
              color: Color(0xFF1A1A1A),
              height: 1.2,
            ),
          ),
          if (widget.book.pengarang != null) ...[
            const SizedBox(height: 2),
            Text(
              widget.book.pengarang!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 9,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getCategoryColor() {
    switch (widget.book.kategori?.toLowerCase()) {
      case 'diolah':
        return Colors.green[600]!;
      case 'belum diolah':
        return Colors.orange[600]!;
      case 'draft':
        return Colors.blue[600]!;
      default:
        return Colors.grey[600]!;
    }
  }
}