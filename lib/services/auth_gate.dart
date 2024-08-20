import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
// import 'package:otobook/pages/home_page.dart';
import 'package:otobook/services/login_or_register.dart';
import 'package:otobook/navigation.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return const NavigationMenu();
          } else {
            return const LoginOrRegister();
          }
        },
      ),
    );
  }
}
