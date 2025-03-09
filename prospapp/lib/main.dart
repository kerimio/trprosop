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
        primaryColor: const Color(0xFF26C6DA), // Türkis
        scaffoldBackgroundColor: Colors.white,
        textTheme: const TextTheme(
          headlineLarge: TextStyle(
            fontFamily: 'Nunito',
            fontWeight: FontWeight.w800,
            fontSize: 28,
            color: Color(0xFF212121), // Dunkelgrau
          ),
          bodyMedium: TextStyle(
            fontFamily: 'Nunito',
            fontWeight: FontWeight.normal,
            fontSize: 16,
            color: Color(0xFF757575), // Mittelgrau
          ),
          labelLarge: TextStyle(
            fontFamily: 'Nunito',
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.white,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFF8C00), // Orange
            foregroundColor: const Color(0xFFFFA726), // Leichteres Orange für Hover
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            elevation: 5,
          ),
        ),
        cardTheme: CardTheme(
          elevation: 5,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          color: Colors.white,
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const HomeScreen(),
    );
  }
}