import 'dart:async';

import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class ImageWidget extends StatefulWidget {
  @override
  _ImageWidgetState createState() => _ImageWidgetState();
}

class _ImageWidgetState extends State<ImageWidget> {
  // List gambar yang akan ditampilkan
  final List<String> imagePaths = [
    'assets/images/Gpt.png', // Path gambar GPT
    'assets/images/Rpa.png', // Path gambar RPA
    'assets/images/Ocr.png', // Path gambar OCR
  ];

  // Controller untuk PageView
  final PageController _pageController = PageController();

  // Indeks halaman saat ini
  int _currentIndex = 0;

  // Timer untuk auto-scroll
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    // Mulai auto-scroll setelah 3 detik
    _startAutoScroll();
  }

  @override
  void dispose() {
    // Hentikan timer ketika widget di-dispose
    _timer.cancel();
    _pageController.dispose();
    super.dispose();
  }

  // Fungsi untuk memulai auto-scroll
  void _startAutoScroll() {
    _timer = Timer.periodic(Duration(seconds: 3), (timer) {
      _currentIndex = (_currentIndex + 1) % imagePaths.length;
      _pageController.animateToPage(
        _currentIndex,
        duration: Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // PageView untuk carousel manual
        SizedBox(
          height: 200, // Sesuaikan tinggi carousel
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemCount: imagePaths.length,
            itemBuilder: (context, index) {
              return Container(
                width: MediaQuery.of(context).size.width,
                margin: EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),

                  image: DecorationImage(
                    image: AssetImage(imagePaths[index]),
                    fit: BoxFit.contain, // Sesuaikan gambar dengan container
                  ),
                ),
                child: Center(
                
                ),
              );
            },
          ),
        ),
      
        SmoothPageIndicator(
          controller: _pageController, // Controller untuk indicator
          count: imagePaths.length, // Jumlah halaman
          effect: ScrollingDotsEffect(
            activeDotColor: Colors.blue, // Warna dot aktif
            dotColor: Colors.grey, // Warna dot tidak aktif
            dotHeight: 10, // Tinggi dot
            dotWidth: 10, // Lebar dot
            spacing: 8, // Jarak antara dot
          ),
          onDotClicked: (index) {
            _pageController.animateToPage(
              index,
              duration: Duration(milliseconds: 500),
              curve: Curves.easeInOut,
            ); // Pindah ke halaman yang diklik
          },
        ),
      ],
    );
  }
}