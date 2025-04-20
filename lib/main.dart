import 'package:flutter/material.dart';
import 'package:otobook/screen/splash/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding
      .ensureInitialized(); // Ensure Flutter binding is initialized

  runApp(App());
}

class App extends StatelessWidget {
  @override
  
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OTOBOOK',
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    );
  }
}
