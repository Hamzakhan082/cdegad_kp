import 'package:cdegad_kp/screens/auth/login_screen.dart';
import 'package:cdegad_kp/screens/forms/cd_forms/cd.dart';
import 'package:cdegad_kp/screens/forms/extension_forms/extension_form.dart';
import 'package:cdegad_kp/screens/forms/gad_form/gad.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cdegad_kp/constants/constants.dart';
import 'screens/home_screen.dart';
import 'screens/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _enableOverlay = false;

  @override
  void initState() {
    super.initState();
    _loadOverlaySetting();
  }

  Future<void> _loadOverlaySetting() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _enableOverlay = prefs.getBool('perf_overlay') ?? false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Forest Department',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: '/',
      builder: (context, child) {
        if (_enableOverlay) {
          return Stack(
            children: [
              child!,
              const Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: PerformanceOverlay(),
              ),
            ],
          );
        }
        return child!;
      },
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
          builder: (context) =>
              const Scaffold(body: Center(child: Text('Page not found'))),
        );
      },
    );
  }
}
