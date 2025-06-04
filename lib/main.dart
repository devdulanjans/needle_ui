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

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Needle Mobile App',
      theme: customTheme(),
      // home: LoginScreen(),
      home: FutureBuilder<bool>(
        future: tryAutoLogin(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return SplashScreen(); // Show loading while checking
          } else if (snapshot.data == true) {
            return MainScreen(); // Tokens valid, go to main app
          } else {
            return LoginScreen(); // Refresh failed or no token, go to login
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