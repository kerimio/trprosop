import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import '../home/home_screen.dart';
import '../home/prospect_provider.dart';

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
        // Verschiebe setLocation außerhalb des Build-Prozesses
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Provider.of<ProspectProvider>(context, listen: false).setLocation(snapshot.data!);
        });
        return HomeScreen(
          location: snapshot.data!,
          onLocationChange: _onLocationChange,
        );
      },
    );
  }
}

class LocationInputScreen extends StatefulWidget {
  const LocationInputScreen({super.key});

  @override
  _LocationInputScreenState createState() => _LocationInputScreenState();
}

class _LocationInputScreenState extends State<LocationInputScreen> {
  final _locationController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Standort eingeben')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _locationController,
              decoration: const InputDecoration(labelText: 'Standort (z. B. 37.7749, -122.4194)'),
              keyboardType: TextInputType.text,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, _locationController.text);
              },
              child: const Text('Bestätigen'),
            ),
          ],
        ),
      ),
    );
  }
}