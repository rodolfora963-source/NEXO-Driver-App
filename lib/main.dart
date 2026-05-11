import 'package:flutter/material.dart';
import 'register_page.dart';

void main() {
  runApp(const NexoDriverApp());
}

class NexoDriverApp extends StatelessWidget {
  const NexoDriverApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NEXO Elite Driver',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        fontFamily: 'Inter',
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFD4AF37),
          surface: Color(0xFF1A1A1A),
        ),
      ),
      home: const RegisterPage(),
    );
  }
}
