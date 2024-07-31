import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:Otobook/screens/start.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:Otobook/screens/ocr_scanner.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() {
  runApp(App());
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  String _userName = '';

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      setState(() {
        _userName = userDoc['name'] ?? 'User';
      });
    }
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
          children: [
            // Greeting and logo section
            Container(
              decoration: BoxDecoration(
                color: Colors.white, // Background color for this section
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(20.0), // Rounded corners at the bottom
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Color(0xFF95A2FF), // Background color for the left side
                        borderRadius: BorderRadius.only(
                          bottomRight: Radius.circular(20.0), // Rounded corner at the bottom-right
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hi!, $_userName',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 1.0), // Space between texts
                          ],
                        ),
                      ),
                    ),
                  ),
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => StartScreen()),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(50.0),
                        child: Image.asset(
                          'assets/logo_oto.PNG', // Path to the PNG image in assets
                          height: 40,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Space between greeting and carousel
            SizedBox(height: 5.0), // Adjust the height as needed

            // Carousel section
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.18, // Adjusted height for the carousel
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
                    text2: 'Untuk Mengklasifikasikan Keywords dari Sinopsis yang di Scan OR',
                  ),
                  _buildPage(
                    color: const Color.fromARGB(255, 111, 0, 255),
                    iconPath: 'assets/icon/ai-icon.svg',
                    text1: 'RPA Technology',
                    text2: 'Robotic Process Automation yang Terintegrasi dengan Perpustakaan',
                  ),
                ],
              ),
            ),
            _buildPageIndicator(),
            SizedBox(height: 20.0), // Space between carousel and images

            // Images with text inside
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  _buildImageWithText(
                    'assets/m.png', // Path to the PNG image
                    '', // Text inside the first image
                  ),
                  SizedBox(height: 20.0), // Space between the images
                  _buildImageWithText(
                    'assets/p.png',
                    '', // Path to the PNG image
                  ),
                ],
              ),
            ),
            // OCR Scanner button
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => OCRScannerScreen()),
                  );
                },
                child: Text('Start OCR Scanner'),
              ),
            ),
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
        width: MediaQuery.of(context).size.width * 0.8, // Adjust width as needed
        height: MediaQuery.of(context).size.height * 0.3, // Adjust height as needed
        decoration: BoxDecoration(
          color: color, // Inner rectangle color
          borderRadius: BorderRadius.circular(20.0), // Rounded corners
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
                    iconPath, // Path to the SVG icon
                    width: 40, // Adjust width as needed
                    height: 40, // Adjust height as needed
                    placeholderBuilder: (context) => SizedBox(
                      width: 40,
                      height: 40,
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  SizedBox(width: 16.0), // Space between icon and text
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          text1, // The bold text to display
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18, // Adjust font size as needed
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4.0), // Space between texts
                        Text(
                          text2, // The non-bold text to display
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16, // Adjust font size as needed
                          ),
                          overflow: TextOverflow.visible, // Ensure text can wrap and be visible
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

  Widget _buildImageWithText(String imagePath, String text) {
    return Container(
      margin: EdgeInsets.only(bottom: 20.0), // Space between images
      width: MediaQuery.of(context).size.width * 0.8, // Reduced width of the image
      height: 120, // Adjust height to make image smaller
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.0), // Rounded corners
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              imagePath, // Path to the PNG image
              fit: BoxFit.cover,
            ),
            Positioned(
              bottom: 8, // Position text inside the image
              left: 8,
              right: 8,
              child: Text(
                text, // Text inside the image
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14, // Adjust font size as needed
                  fontWeight: FontWeight.bold,
                  backgroundColor: Colors.black54, // Optional background for better readability
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
