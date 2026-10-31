import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'features/welcome/screens/welcome_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const AgroBolivarApp());
}

class AgroBolivarApp extends StatelessWidget {
  const AgroBolivarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AgroBolívar',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const WelcomeScreen(),
    );
  }
}