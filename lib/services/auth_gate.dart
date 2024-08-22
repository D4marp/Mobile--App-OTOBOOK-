import 'package:Otobook/navigation.dart';
import 'package:Otobook/services/login_or_register.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  @override
  void initState() {
    super.initState();
    getToken();
  }

  void getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    print(token);
    if (token != null && token.isNotEmpty) {
      // Token ada dan valid, arahkan ke halaman utama
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const NavigationMenu()),
      );
    } else {
      // Token tidak ada atau tidak valid, arahkan ke halaman login/register
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginOrRegister()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child:
            CircularProgressIndicator(), // Tampilkan loader sementara menunggu navigasi
      ),
    );
  }
}
