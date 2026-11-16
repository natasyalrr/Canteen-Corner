import 'package:flutter/material.dart';
import 'screens/menu_screen.dart';

void main() {
  runApp(const MenuPreviewApp());
}

class MenuPreviewApp extends StatelessWidget {
  const MenuPreviewApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Canteen Corner Preview',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF176B78),
        ),
        useMaterial3: true,
      ),
      home: const MenuScreen(),
    );
  }
}
