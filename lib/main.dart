import 'package:cdegad_kp/screens/auth/login_screen.dart';
import 'package:cdegad_kp/screens/forms/cd_forms/cd.dart';
import 'package:cdegad_kp/screens/forms/extension_forms/extension_form.dart';
import 'package:cdegad_kp/screens/forms/gad_form/gad.dart';
import 'package:flutter/material.dart';
import 'package:cdegad_kp/constants/constants.dart';
import 'screens/home_screen.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Forest Department',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginPage(),
        '/home': (context) => const HomeScreen(),
        '/cd': (context) => const CDPage(),
        '/extension': (context) => const ExtensionScreen(),
        '/gad': (context) => const GADPage(),
      },
      onUnknownRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) => const Scaffold(
            body: Center(
              child: Text('Page not found'),
            ),
          ),
        );
      },
    );
  }
}
 