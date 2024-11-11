import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:Otobook/screens/start.dart';
import 'package:Otobook/widgets/buttom.dart';
import 'package:Otobook/widgets/cara_widget.dart';
import 'package:Otobook/widgets/input_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  String _userName = ''; // Nama pengguna default

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  void _loadUserName() {
    // Fungsi ini sekarang hanya mengatur nama pengguna ke nilai default
    setState(() {
      _userName = 'Welcome to Otobook'; // Atur nama pengguna default
      _userName = 'Otobook'; // Atur nama pengguna def
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            // Greeting and logo section
            LayoutBuilder(
              builder: (context, constraints) {
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(20.0),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Color(0xFF95A2FF),
                            borderRadius: BorderRadius.only(
                              bottomRight: Radius.circular(20.0),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Hi, $_userName',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize:
                                        constraints.maxWidth > 600 ? 24 : 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 8.0),
                              ],
                            ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => StartScreen()),
                          );
                        },
                        child: Padding(
                          padding: constraints.maxWidth > 600
                              ? const EdgeInsets.all(50.0)
                              : const EdgeInsets.all(16.0),
                          child: Image.asset(
                            'assets/logo_oto.PNG',
                            height: 40,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            SizedBox(height: 10.0),

            // // Carousel section
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.16,
              child: PageView(
                controller: _pageController,
                onPageChanged: _onPageChanged,
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
                    text2:
                        'Untuk Klasifikasi Keywords dari Sinopsis yang di Scan OCR',
                  ),
                  _buildPage(
                    color: Color.fromARGB(255, 111, 0, 255),
                    iconPath: 'assets/icon/ai-icon.svg',
                    text1: 'RPA Technology',
                    text2:
                        'Robot Process Automation yang diintegrasi dengan Perpustakaan',
                  ),
                ],
              ),
            ),
            _buildPageIndicator(),

            SizedBox(height: 20.0),

            IconRowWidget(),

            SizedBox(height: 20.0),

            CaraWidget(),

            SizedBox(height: 25.0),

            InputWidget(),

            SizedBox(height: 20.0),
          ],
        ),
      ),
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
        width: MediaQuery.of(context).size.width * 0.8,
        height: MediaQuery.of(context).size.height * 0.3,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    iconPath,
                    width: 40,
                    height: 40,
                    placeholderBuilder: (context) => SizedBox(
                      width: 40,
                      height: 40,
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  SizedBox(width: 16.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          text1,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4.0),
                        Text(
                          text2,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                          overflow: TextOverflow.visible,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildPageIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(3, (index) {
          return Container(
            margin: EdgeInsets.symmetric(horizontal: 4.0),
            width: _currentPage == index ? 12.0 : 8.0,
            height: _currentPage == index ? 12.0 : 8.0,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _currentPage == index ? Colors.white : Colors.grey[400],
            ),
          );
        }),
      ),
    );
  }
}
