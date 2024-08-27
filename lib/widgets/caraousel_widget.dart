import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CarouselWidget extends StatefulWidget {
  final PageController pageController;
  final Function(int) onPageChanged;

  CarouselWidget({required this.pageController, required this.onPageChanged});

  @override
  _CarouselWidgetState createState() => _CarouselWidgetState();
}

class _CarouselWidgetState extends State<CarouselWidget> {
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.16,
          child: PageView(
            controller: widget.pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
              widget.onPageChanged(index);
            },
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
      ],
    );
  }

  Widget _buildPage({
    required Color color,
    required String iconPath,
    required String text1,
    required String text2,
  }) {
    return Container(
      color: color,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(iconPath, height: 60),
          SizedBox(height: 10),
          Text(
            text1,
            style: TextStyle(
              fontSize: 18,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 5),
          Text(
            text2,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        return AnimatedContainer(
          duration: Duration(milliseconds: 300),
          margin: EdgeInsets.symmetric(horizontal: 5),
          height: 8,
          width: _currentPage == index ? 12 : 8,
          decoration: BoxDecoration(
            color: _currentPage == index ? Colors.black : Colors.grey,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}
