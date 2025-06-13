import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'package:otobook/screen/book/list_book.dart';
import 'package:otobook/screen/home/home.dart';
import 'package:otobook/screen/profile/profile.dart';
import 'package:otobook/screen/search/search_page.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class NavigationMenu extends StatefulWidget {
  const NavigationMenu({super.key});

  @override
  State<NavigationMenu> createState() => _NavigationMenuState();
}

class _NavigationMenuState extends State<NavigationMenu> with TickerProviderStateMixin {
  int _selectedIndex = 0;
  PageController? _pageController; // Changed to nullable
  List<AnimationController> _animationControllers = []; // Initialize as empty list
  List<Animation<double>> _scaleAnimations = []; // Initialize as empty list

  final List<Widget> _widgetOptions = <Widget>[
    const HomeScreen(),
    const SearchPage(),
    const GetBooksPage(),
    const ProfilePage(),
  ];

  final List<NavigationItem> _navigationItems = [
    NavigationItem(
      icon: FontAwesomeIcons.house,
      activeIcon: FontAwesomeIcons.house,
      label: 'Beranda',
      color: const Color(0xFF4A90E2),
    ),
    NavigationItem(
      icon: FontAwesomeIcons.magnifyingGlass,
      activeIcon: FontAwesomeIcons.magnifyingGlass,
      label: 'Cari Buku',
      color: const Color(0xFF4A90E2),
    ),
    NavigationItem(
      icon: FontAwesomeIcons.bookOpen,
      activeIcon: FontAwesomeIcons.bookOpen,
      label: 'Daftar Buku',
      color: const Color(0xFF4A90E2),
    ),
    NavigationItem(
      icon: FontAwesomeIcons.user,
      activeIcon: FontAwesomeIcons.solidUser,
      label: 'Profil',
      color: const Color(0xFF4A90E2),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    // Initialize PageController
    _pageController = PageController(initialPage: _selectedIndex);
    
    // Initialize animation controllers
    _animationControllers = List.generate(
      _navigationItems.length,
      (index) => AnimationController(
        duration: const Duration(milliseconds: 200),
        vsync: this,
      ),
    );

    // Initialize scale animations
    _scaleAnimations = _animationControllers.map((controller) {
      return Tween<double>(begin: 1.0, end: 1.2).animate(
        CurvedAnimation(parent: controller, curve: Curves.elasticOut),
      );
    }).toList();

    // Start animation for initial selected item
    if (_animationControllers.isNotEmpty) {
      _animationControllers[_selectedIndex].forward();
    }
  }

  @override
  void dispose() {
    // Safely dispose PageController
    _pageController?.dispose();
    
    // Dispose all animation controllers
    for (var controller in _animationControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _onItemTapped(int index) {
    if (_selectedIndex == index || _pageController == null) return;

    // Haptic feedback
    HapticFeedback.lightImpact();

    setState(() {
      // Reset previous animation
      if (_animationControllers.isNotEmpty && _selectedIndex < _animationControllers.length) {
        _animationControllers[_selectedIndex].reverse();
      }
      
      _selectedIndex = index;
      
      // Start new animation
      if (_animationControllers.isNotEmpty && _selectedIndex < _animationControllers.length) {
        _animationControllers[_selectedIndex].forward();
      }
    });

    // Animate to new page
    _pageController?.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Return loading widget if controllers are not initialized
    if (_pageController == null || _animationControllers.isEmpty) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      extendBody: true,
      body: PageView.builder(
        controller: _pageController!,
        itemCount: _widgetOptions.length,
        onPageChanged: (index) {
          if (_selectedIndex != index && _animationControllers.isNotEmpty) {
            setState(() {
              if (_selectedIndex < _animationControllers.length) {
                _animationControllers[_selectedIndex].reverse();
              }
              _selectedIndex = index;
              if (_selectedIndex < _animationControllers.length) {
                _animationControllers[_selectedIndex].forward();
              }
            });
          }
        },
        itemBuilder: (context, index) {
          return _widgetOptions[index];
        },
      ),
      bottomNavigationBar: _buildModernBottomNavBar(),
    );
  }

  Widget _buildModernBottomNavBar() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            spreadRadius: 0,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 40,
            spreadRadius: 0,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            height: 75,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.9),
                  Colors.white.withOpacity(0.8),
                ],
              ),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(
                _navigationItems.length,
                (index) => _buildNavItem(index),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index) {
    final item = _navigationItems[index];
    final isSelected = _selectedIndex == index;

    // Safety check for animations
    if (_scaleAnimations.isEmpty || index >= _scaleAnimations.length) {
      return _buildSimpleNavItem(item, isSelected, index);
    }

    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: AnimatedBuilder(
        animation: _scaleAnimations[index],
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimations[index].value,
            child: _buildNavItemContent(item, isSelected),
          );
        },
      ),
    );
  }

  Widget _buildSimpleNavItem(NavigationItem item, bool isSelected, int index) {
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: _buildNavItemContent(item, isSelected),
    );
  }

  Widget _buildNavItemContent(NavigationItem item, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: isSelected
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  item.color.withOpacity(0.15),
                  item.color.withOpacity(0.05),
                ],
              )
            : null,
        borderRadius: BorderRadius.circular(20),
        border: isSelected
            ? Border.all(
                color: item.color.withOpacity(0.3),
                width: 1,
              )
            : null,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isSelected
                  ? item.color.withOpacity(0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: FaIcon(
                isSelected ? item.activeIcon : item.icon,
                key: ValueKey('${item.label}_$isSelected'),
                size: 20,
                color: isSelected
                    ? item.color
                    : Colors.grey[600],
              ),
            ),
          ),
          const SizedBox(height: 4),
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: TextStyle(
              fontSize: isSelected ? 11 : 10,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color: isSelected
                  ? item.color
                  : Colors.grey[600],
            ),
            child: Text(
              item.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class NavigationItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final Color color;

  const NavigationItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.color,
  });
}