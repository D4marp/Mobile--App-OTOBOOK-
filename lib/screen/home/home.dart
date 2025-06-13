import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:otobook/screen/splash/start_screen.dart';
import 'package:otobook/services/api.dart';
import 'package:otobook/widget/buttom_widget.dart';
import 'package:otobook/widget/daftar_buku_widget.dart';
import 'package:otobook/widget/image_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';



class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key}); 

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _pageController = PageController();
 String _userName = 'Guest'; // Default username
// Untuk menandai loading state
 
  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
    });
  }
void initState() {
    super.initState();
    _fetchUserData(); // Panggil fungsi untuk mengambil data pengguna
  }
Future<void> _fetchUserData() async {
    try {
      final userData = await getUserData(); // Ambil data pengguna
      setState(() {
        _userName = userData['username']; // Set username
// Tandai loading selesai
      });
    } catch (e) {
      setState(() {
        _userName = 'Guest'; // Fallback jika gagal
// Tandai loading selesai
      });
      print('Error fetching user data: $e');
    }
  }
 Future<Map<String, dynamic>> getUserData() async {
    int? id = await getId();
    final response = await http.get(Uri.parse('${GetData().getUserIdUrl}/$id'));

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
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
       backgroundColor: Colors.white,
      body: SingleChildScrollView(
        // Latar belakang putih bersih
        child: Column(
          
          children: <Widget>[
            _buildHeader(),
            ImageWidget(),
            IconRowWidget(),
            SizedBox(height: 2.0),
            DaftarBukuWidget(),
            SizedBox(height: 20.0),
          ],
        ),
      ),
    );
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
          color: Colors.black.withOpacity(0.08),
          blurRadius: 16,
          spreadRadius: 2,
          offset: const Offset(0, 6),
        ),
        BoxShadow(
          color: Colors.black.withOpacity(0.04),
          blurRadius: 8,
          spreadRadius: 1,
          offset: const Offset(0, 2),
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

  Widget _buildCarousel() {
    return Column(
      children: [
        SizedBox(
          height: 180,
          
          child: PageView(
            
            controller: _pageController,
            onPageChanged: _onPageChanged,
            physics: BouncingScrollPhysics(),
            children: [
              _buildPage(
                color: Colors.blue,
                iconPath: 'assets/icon/ocr-icon.svg',
                text1: 'OCR Technology',
                text2: 'Untuk Scan Meta Data Bibliografis/Buku',
              ),
              _buildPage(
                color: Colors.orange,
                iconPath: 'assets/icon/ai-icon.svg',
                text1: 'AI Technology',
                text2: 'Untuk Klasifikasi Keywords dari Sinopsis yang di Scan OCR',
              ),
              _buildPage(
                color: Color.fromARGB(255, 111, 0, 255),
                iconPath: 'assets/icon/ai-icon.svg',
                text1: 'RPA Technology',
                text2: 'Robot Process Automation yang diintegrasi dengan Perpustakaan',
              ),
            ],
          ),
        ),
        SizedBox(height: 16),
        SmoothPageIndicator(
          controller: _pageController,
          count: 3,
          effect: ExpandingDotsEffect(
            dotHeight: 10,
            dotWidth: 10,
            activeDotColor: Colors.blueAccent,
            dotColor: const Color.fromARGB(255, 111, 99, 99),
            expansionFactor: 3,
          ),
        ),
      ],
    );
  }

  Widget _buildPage({
    required Color color,
    required String iconPath,
    required String text1,
    required String text2,
  }) {
    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.85,
        height: 160,
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              spreadRadius: 2,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            SvgPicture.asset(
              iconPath,
              width: 50,
              height: 50,
              placeholderBuilder: (context) => CircularProgressIndicator(),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    text1,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    text2,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
