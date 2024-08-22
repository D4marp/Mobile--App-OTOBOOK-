import 'package:Otobook/screens/signin.dart';
import 'package:Otobook/screens/signup.dart';
import 'package:flutter/widgets.dart';

class LoginOrRegister extends StatefulWidget {
  const LoginOrRegister({super.key});

  @override
  State<LoginOrRegister> createState() => _LoginOrRegisterState();
}

class _LoginOrRegisterState extends State<LoginOrRegister> {
  bool _isLogin = true;

  void togglePage() {
    setState(() {
      _isLogin = !_isLogin;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLogin) {
      return LoginPage(ontap: togglePage);
    } else {
      return RegisterPage(ontap: togglePage);
    }
  }
}
