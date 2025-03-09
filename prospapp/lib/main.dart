import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const ProspektApp());
}

class ProspektApp extends StatelessWidget {
  const ProspektApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Prospekt App',
      theme: ThemeData(
        primaryColor: Colors.teal,
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'Poppins', // Optional: Füge Poppins als Asset hinzu, wenn verfügbar
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const HomeScreen(),
    );
  }
}