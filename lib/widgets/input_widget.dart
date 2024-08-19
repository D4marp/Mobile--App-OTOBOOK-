import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class InputWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Get the screen width to determine the sizes dynamically
        double screenWidth = MediaQuery.of(context).size.width;

        // Calculate the text and icon size based on screen width
        double textSize = screenWidth * 0.05; // Adjust this value as needed
        double subTextSize = screenWidth * 0.03; // Adjust this value as needed
        double iconSize = screenWidth * 0.4; // Adjust this value as needed

        return Container(
          width: screenWidth * 0.9, // Make the container width responsive
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 25),
          decoration: ShapeDecoration(
            color: Color(0xFF3C83F5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            shadows: [
              BoxShadow(
                color: Color(0x0C000000),
                blurRadius: 10,
                offset: Offset(0, 4),
                spreadRadius: 0,
              ),
            ],
          ),
          child: Stack(
            children: [
              Padding(
                padding: EdgeInsets.only(right: iconSize * 1.2), // Adjust padding to avoid overlap
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: screenWidth * 0.5,
                      child: Text(
                        'Fitur Canggih dan Terbaru',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: textSize, // Use dynamic text size
                          fontFamily: 'Overpass',
                          height: 1.2, // Adjust height to space text better
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    SizedBox(
                      width: screenWidth * 0.6,
                      child: Text(
                        'Menawarkan teknologi terbaru dan terkini, proses katalogisasi Perpustakaan menjadi lebih cepat dan akurat.',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.96),
                          fontSize: subTextSize, // Use dynamic subtext size
                          fontFamily: 'Overpass',
                          height: 1.4, // Adjust height to space text better
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  width: iconSize * 0.8, // Adjust icon size
                  height: iconSize * 0.8,
                  child: SvgPicture.asset(
                    'assets/icon/Kuning.svg',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
