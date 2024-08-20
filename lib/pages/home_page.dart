import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'package:flutter_svg/flutter_svg.dart';
import 'package:otobook/widgets/button.dart';
import 'package:otobook/widgets/cara_widget.dart';
import 'package:otobook/widgets/input_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

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
            LayoutBuilder(
              builder: (context, constraints) {
                return Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(20.0),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: const BoxDecoration(
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
                                  'Hi!, Welcome to OTOBOOK',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize:
                                        constraints.maxWidth > 600 ? 24 : 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8.0),
                              ],
                            ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          // Navigator.push(
                          //   context,
                          //   MaterialPageRoute(
                          //       builder: (context) => StartScreen()),
                          // );
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
            const SizedBox(height: 10.0),

            // Carousel section
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
                    color: const Color.fromARGB(255, 111, 0, 255),
                    iconPath: 'assets/icon/ai-icon.svg',
                    text1: 'RPA Technology',
                    text2:
                        'Robot Process Automation yang diintegrasi dengan Perpustakaan',
                  ),
                ],
              ),
            ),
            _buildPageIndicator(),

            const SizedBox(height: 20.0),

            const IconRowWidget(),

            const SizedBox(height: 20.0),

            CaraWidget(),

            const SizedBox(height: 25.0),

            InputWidget(),

            const SizedBox(height: 20.0),
          ],
        ),
      ),
    );
  }

  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     body: SingleChildScrollView(
  //       child: Column(
  //         children: [
  //           // Greeting and logo section
  //           LayoutBuilder(
  //             builder: (context, constraints) {
  //               return Container(
  //                 decoration: const BoxDecoration(
  //                   color: Colors.white,
  //                   borderRadius: BorderRadius.vertical(
  //                     bottom: Radius.circular(20.0),
  //                   ),
  //                 ),
  //                 child: Row(
  //                   children: [
  //                     Expanded(
  //                       child: Container(
  //                         decoration: const BoxDecoration(
  //                           color: Color(0xFF95A2FF),
  //                           borderRadius: BorderRadius.only(
  //                             bottomRight: Radius.circular(20.0),
  //                           ),
  //                         ),
  //                         child: Padding(
  //                           padding: const EdgeInsets.all(16.0),
  //                           child: Column(
  //                             crossAxisAlignment: CrossAxisAlignment.start,
  //                             children: [
  //                               Text(
  //                                 'Hi!, Welcome to OTOBOOK',
  //                                 style: TextStyle(
  //                                   color: Colors.white,
  //                                   fontSize:
  //                                       constraints.maxWidth > 600 ? 24 : 18,
  //                                   fontWeight: FontWeight.bold,
  //                                 ),
  //                               ),
  //                               const SizedBox(height: 8.0),
  //                             ],
  //                           ),
  //                         ),
  //                       ),
  //                     ),
  //                     GestureDetector(
  //                       onTap: () {
  //                         // Navigator.push(
  //                         //   context,
  //                         //   MaterialPageRoute(
  //                         //       builder: (context) => StartScreen()),
  //                         // );
  //                       },
  //                       child: Padding(
  //                         padding: constraints.maxWidth > 600
  //                             ? const EdgeInsets.all(50.0)
  //                             : const EdgeInsets.all(16.0),
  //                         child: Image.asset(
  //                           'assets/logo_oto.PNG',
  //                           height: 40,
  //                         ),
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //               );
  //             },
  //           ),
  //           const SizedBox(height: 10.0),
  //           // Carousel section
  //           SizedBox(
  //             height: MediaQuery.of(context).size.height * 0.16,
  //             child: PageView(
  //               controller: _pageController,
  //               onPageChanged: _onPageChanged,
  //               children: [
  //                 _buildPage(
  //                   color: Colors.blue,
  //                   iconPath: 'assets/icon/ocr-icon.svg',
  //                   text1: 'OCR Technology',
  //                   text2: 'Untuk Scan Meta Data Bibliografis/Buku',
  //                 ),
  //                 _buildPage(
  //                   color: Colors.orange,
  //                   iconPath: 'assets/icon/ai-icon.svg',
  //                   text1: 'AI Technology',
  //                   text2:
  //                       'Untuk Klasifikasi Keywords dari Sinopsis yang di Scan OCR',
  //                 ),
  //                 _buildPage(
  //                   color: const Color.fromARGB(255, 111, 0, 255),
  //                   iconPath: 'assets/icon/ai-icon.svg',
  //                   text1: 'RPA Technology',
  //                   text2:
  //                       'Robot Process Automation yang diintegrasi dengan Perpustakaan',
  //                 ),
  //               ],
  //             ),
  //           ),
  //           _buildPageIndicator(),

  //           const SizedBox(height: 20.0),

  //           const IconRowWidget(),

  //           const SizedBox(height: 20.0),

  //           // Images with text inside
  //           Container(
  //             width:
  //                 MediaQuery.of(context).size.width * 0.9, // Responsive width
  //             height: 176,
  //             padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 25),
  //             decoration: ShapeDecoration(
  //               color: const Color(0xFFF9AD34),
  //               shape: RoundedRectangleBorder(
  //                 borderRadius: BorderRadius.circular(12),
  //               ),
  //               shadows: [
  //                 BoxShadow(
  //                   color: Color(0x0C000000), // Light shadow
  //                   blurRadius: 10,
  //                   offset: Offset(0, 4),
  //                   spreadRadius: 1,
  //                 ),
  //                 BoxShadow(
  //                   color: Color(0x1F000000), // Medium shadow
  //                   blurRadius: 20,
  //                   offset: Offset(0, 8),
  //                   spreadRadius: 0,
  //                 ),
  //                 BoxShadow(
  //                   color: Color(0x33000000), // Dark shadow
  //                   blurRadius: 30,
  //                   offset: Offset(0, 12),
  //                   spreadRadius: -5,
  //                 ),
  //               ],
  //             ),
  //             child: Column(
  //               mainAxisSize: MainAxisSize.min,
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               children: [
  //                 const Text(
  //                   'Cara Cepat dan Mudah',
  //                   style: TextStyle(
  //                     color: Colors.white,
  //                     fontSize: 23,
  //                     fontFamily: 'Overpass',
  //                     height: 1.2, // Improved line height
  //                   ),
  //                 ),
  //                 const SizedBox(height: 15),
  //                 Text(
  //                   'Solusi Mudah cepat untuk Pengkatalogan data Bibliografis, untuk digitalisasi Perpustakaan menggunakan teknologi Optical Character Recognition (OCR) dipadukan dengan Artificial Intelligence (AI).',
  //                   style: TextStyle(
  //                     color: Colors.white.withOpacity(0.96),
  //                     fontSize: 12,
  //                     fontFamily: 'Overpass',
  //                     height: 1.4, // Improved line height
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ),

  //           const SizedBox(height: 25.0),

  //           Container(
  //             width:
  //                 MediaQuery.of(context).size.width * 0.9, // Responsive width
  //             height: 176,
  //             padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 25),
  //             decoration: ShapeDecoration(
  //               color: const Color(0xFF4894FE), // Changed color for variety
  //               shape: RoundedRectangleBorder(
  //                 borderRadius: BorderRadius.circular(12),
  //               ),
  //               shadows: [
  //                 BoxShadow(
  //                   color: Color(0x0C000000), // Light shadow
  //                   blurRadius: 10,
  //                   offset: Offset(0, 4),
  //                   spreadRadius: 1,
  //                 ),
  //                 BoxShadow(
  //                   color: Color(0x1F000000), // Medium shadow
  //                   blurRadius: 20,
  //                   offset: Offset(0, 8),
  //                   spreadRadius: 0,
  //                 ),
  //                 BoxShadow(
  //                   color: Color(0x33000000), // Dark shadow
  //                   blurRadius: 30,
  //                   offset: Offset(0, 12),
  //                   spreadRadius: -5,
  //                 ),
  //               ],
  //             ),
  //             child: Column(
  //               mainAxisSize: MainAxisSize.min,
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               children: [
  //                 const Text(
  //                   'Fitur Canggih dan Terbaru',
  //                   style: TextStyle(
  //                     color: Colors.white,
  //                     fontSize: 23,
  //                     fontFamily: 'Overpass',
  //                     height: 1.2, // Improved line height
  //                   ),
  //                 ),
  //                 const SizedBox(height: 15),
  //                 Text(
  //                   'Menawarkan teknologi terbaru untuk mengoptimalkan proses digitalisasi dan pengelolaan data perpustakaan. Dengan teknologi terkini, proses katalogisasi menjadi lebih cepat dan akurat.',
  //                   style: TextStyle(
  //                     color: Colors.white.withOpacity(0.96),
  //                     fontSize: 12,
  //                     fontFamily: 'Overpass',
  //                     height: 1.4, // Improved line height
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ),

  //           const SizedBox(height: 20.0),
  //         ],
  //       ),
  //     ),
  //   );
  // }

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
                    placeholderBuilder: (context) => const SizedBox(
                      width: 40,
                      height: 40,
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  const SizedBox(width: 16.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          text1,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4.0),
                        Text(
                          text2,
                          style: const TextStyle(
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
            margin: const EdgeInsets.symmetric(horizontal: 4.0),
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

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Home Page'),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.logout),
//             onPressed: logout,
//           ),
//         ],
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//            children: const [
//            Text('Welcome to OTOBOOK'),
//           ],
//         ),
//       ),
//     );
//   }
// }
