import 'package:flutter/material.dart';
import 'package:Otobook/screens/katalog.dart';
import 'package:Otobook/screens/team.dart';
import 'package:Otobook/screens/list_book.dart';
import 'screens/home.dart';

class NavigationMenu extends StatefulWidget {
  const NavigationMenu({super.key});

  @override
  _NavigationMenuState createState() => _NavigationMenuState();
}

class _NavigationMenuState extends State<NavigationMenu> {
  int _selectedIndex = 0;

  List<Widget> _widgetOptions = <Widget>[
    HomeScreen(),
    KatalogScreen(),
   // Placeholder, jika perlu
    ListBooksScreen(),
    TeamScreen(),
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
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Color.fromARGB(255, 255, 255, 255),
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_box),
            label: 'Add',
          ),
        
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'list', // Sesuaikan label ini dengan _widgetOptions
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Saya',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Color(0xFF005CBE),
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
      ),
      
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
