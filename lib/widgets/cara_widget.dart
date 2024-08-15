import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CaraWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 355,
      height: 176,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            top: 0,
            child: Container(
              width: 355,
              height: 176,
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 25),
              decoration: ShapeDecoration(
                color: Color(0xFFF9AD34),
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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 186,
                    height: 46,
                    child: Text(
                      'Cara Cepat dan Mudah',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontFamily: 'Overpass',
                        height: 0.05,
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  SizedBox(
                    width: 186,
                    height: 34,
                    child: Text(
                      'Solusi Mudah cepat untuk Pengkatalogan data Bibliografis, untuk digitalisasi Perpustakaan.',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.96),
                        fontSize: 12,
                        fontFamily: 'Overpass',
                        height: 0.11,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 196,
            top: 9,
            child: Container(
              width: 155,
              height: 141,
              child: SvgPicture.asset(
                'assets/Car.svg',
                fit: BoxFit.contain,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
