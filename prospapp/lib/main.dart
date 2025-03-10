import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'core/theme/app_theme.dart';
import 'features/home/home_screen.dart';
import 'features/home/prospect_provider.dart';
import 'features/location/location_input_screen.dart';
void main() {
  runApp(const ProspektApp());
}

class ProspektApp extends StatelessWidget {
  const ProspektApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ProspectProvider(),
      child: MaterialApp(
        title: 'Prospekt App',
        theme: AppTheme.lightTheme,
        home: const LocationInitializer(),
      ),
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

  void _onLocationChange() async {
    final newLocation = await _navigateToLocationInput();
    if (newLocation != null && newLocation.isNotEmpty) {
      setState(() {
        _locationFuture = Future.value(newLocation);
      });
    }
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
        Provider.of<ProspectProvider>(context, listen: false).setLocation(snapshot.data!);
        return HomeScreen(
          location: snapshot.data!,
          onLocationChange: _onLocationChange,
        );
      },
    );
  }
}