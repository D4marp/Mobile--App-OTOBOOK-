import 'package:flutter/material.dart';
import 'package:Otobook/screens/start.dart';

class TeamScreen extends StatefulWidget {
  const TeamScreen({super.key});

  @override
  State<TeamScreen> createState() => _TeamScreenState();
}

class _TeamScreenState extends State<TeamScreen> {
  String _userName = 'Guest'; // Default username

  @override
  void initState() {
    super.initState();
    _loadUserName(); // Simulate loading user data
  }

  // Simulate loading username; replace with actual logic if needed
  void _loadUserName() {
    // Simulate delay for loading user data
    Future.delayed(Duration(seconds: 1), () {
      setState(() {
        _userName = 'John Doe'; // Simulated user data
      });
    });
  }

  // Simulate sign out action
  void _signOut() {
    // Simulate sign out action
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => StartScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(20.0),
              ),
            ),
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'My Profile',
                  style: Theme.of(context).textTheme.headline6?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
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
                      padding: const EdgeInsets.all(8.0),
                      child: Image.asset(
                        'assets/logo_oto.PNG',
                        height: 40,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hi, $_userName!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4.0),
                  Text(
                    'Selamat datang di Otobook',
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 20.0),
                  ElevatedButton(
                    onPressed: _signOut,
                    child: Text('Log Out'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue, // Button color
                      padding: EdgeInsets.symmetric(horizontal: 16.0), // Padding
                      textStyle: TextStyle(fontSize: 16), // Text style
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
