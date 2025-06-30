import 'package:flutter/material.dart';

import 'controller/auth_controller.dart';
import 'controller/old_auth_controller.dart';
import 'view/authentication/login_new.dart';
import 'view/authentication/sign_up.dart';
import 'view/dashoboard/profile/profile.dart';
import 'view/main_screen.dart';
import 'view/theme/customThemeData.dart';
import 'view/theme/splash.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Future<bool> _autoLoginFuture;

  @override
  void initState() {
    super.initState();
    _autoLoginFuture = tryAutoLogin();

  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Needle Mobile App',
      theme: customTheme(),
      home: FutureBuilder<bool>(
        future: _autoLoginFuture,
        builder: (context, snapshot) {

          if (snapshot.connectionState == ConnectionState.waiting) {
            return SplashScreen(); // Show loading while checking
          } else if (snapshot.hasData) {
            return snapshot.data == true ? MainScreen() : LoginScreen();
          } else {
            return LoginScreen(); // Default to login if no data or error
          }
        },
      ),
      routes: {
        '/signup': (context) => SignupScreen(),
        '/main': (context) => MainScreen(),
        '/profile': (context) => ProfileScreen(),
      },
    );
  }
}
