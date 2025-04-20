
import 'package:flutter/material.dart';

import 'package:otobook/screen/book/list_book.dart';
import 'package:otobook/screen/home/home.dart';
import 'package:otobook/screen/profile/profile.dart';
import 'package:otobook/screen/search/search_page.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart'; // Import Font Awesome

class NavigationMenu extends StatefulWidget {
  const NavigationMenu({super.key});

  @override
  _NavigationMenuState createState() => _NavigationMenuState();
}

class _NavigationMenuState extends State<NavigationMenu> {
  int _selectedIndex = 0;

  final List<Widget> _widgetOptions = <Widget>[
    HomeScreen(),
    SearchPage(),
    GetBooksPage(),
    ProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      print("Selected Index: $index"); // Debugging
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _widgetOptions[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9), // Efek glassmorphism
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              spreadRadius: 5,
              offset: Offset(0, -5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)), // Sudut melengkung lebih besar
          child: BottomNavigationBar(
            backgroundColor: Colors.transparent, // Latar belakang transparan
            items: <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _selectedIndex == 0 ? Color(0xFF005CBE).withOpacity(0.1) : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    FontAwesomeIcons.house, // Ikon Font Awesome untuk Home
                    size: 24,
                    color: _selectedIndex == 0 ? Color(0xFF005CBE) : Colors.grey.shade600,
                  ),
                ),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _selectedIndex == 1 ? Color(0xFF005CBE).withOpacity(0.1) : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    FontAwesomeIcons.magnifyingGlass, // Ikon Font Awesome untuk Search
                    size: 24,
                    color: _selectedIndex == 1 ? Color(0xFF005CBE) : Colors.grey.shade600,
                  ),
                ),
                label: 'Search',
              ),
              BottomNavigationBarItem(
                icon: AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _selectedIndex == 2 ? Color(0xFF005CBE).withOpacity(0.1) : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    FontAwesomeIcons.bookOpen, // Ikon Font Awesome untuk List
                    size: 24,
                    color: _selectedIndex == 2 ? Color(0xFF005CBE) : Colors.grey.shade600,
                  ),
                ),
                label: 'List',
              ),
              BottomNavigationBarItem(
                icon: AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _selectedIndex == 3 ? Color(0xFF005CBE).withOpacity(0.1) : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    FontAwesomeIcons.user, // Ikon Font Awesome untuk Profile
                    size: 24,
                    color: _selectedIndex == 3 ? Color(0xFF005CBE) : Colors.grey.shade600,
                  ),
                ),
                label: 'Profile',
              ),
            ],
            currentIndex: _selectedIndex,
            selectedItemColor: Color(0xFF005CBE), // Warna aktif
            unselectedItemColor: Colors.grey.shade600, // Warna non-aktif
            onTap: _onItemTapped,
            type: BottomNavigationBarType.fixed,
            elevation: 0, // Hilangkan elevation default
            showSelectedLabels: true,
            showUnselectedLabels: true,
            selectedFontSize: 12,
            unselectedFontSize: 12,
          ),
        ),
      ),
    );
  }
}