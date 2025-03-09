import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'screens/home_screen.dart';
import 'screens/location_input_screen.dart';

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
        primaryColor: const Color(0xFF4CAF50), // Grün
        scaffoldBackgroundColor: const Color(0xFFF5F5F5), // Heller Hintergrund
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
            fontSize: 14,
            color: Color(0xFF757575), // Grau
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
            backgroundColor: const Color(0xFF4CAF50), // Grün
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            elevation: 5,
          ),
        ),
        cardTheme: CardTheme(
          elevation: 5,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          color: Colors.white,
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const LocationInitializer(),
    );
  }
}

class LocationInitializer extends StatefulWidget {
  const LocationInitializer({super.key});

  @override
  _LocationInitializerState createState() => _LocationInitializerState();
}

class _LocationInitializerState extends State<LocationInitializer> {
  late Future<String> _locationFuture;

  @override
  void initState() {
    super.initState();
    _locationFuture = _getLocation();
  }

  Future<String> _getLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return await _navigateToLocationInput();
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return await _navigateToLocationInput();
      }
    }

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    return '${position.latitude}, ${position.longitude}';
  }

  Future<String> _navigateToLocationInput() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LocationInputScreen()),
    );
    return result ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _locationFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError || snapshot.data == null || snapshot.data!.isEmpty) {
          return const LocationInputScreen();
        }
        return HomeScreen(
          location: snapshot.data!,
          onLocationChange: () async {
            final newLocation = await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const LocationInputScreen()),
            );
            if (newLocation != null && newLocation.isNotEmpty) {
              setState(() {
                _locationFuture = Future.value(newLocation);
              });
            }
          },
        );
      },
    );
  }
}