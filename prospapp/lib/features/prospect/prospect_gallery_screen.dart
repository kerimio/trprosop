import 'package:flutter/material.dart';

class ProspectGalleryScreen extends StatelessWidget {
  final String location;

  const ProspectGalleryScreen({super.key, required this.location});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Prospekt Galerie'),
      ),
      body: Center(
        child: Text('Standort: $location'),
      ),
    );
  }
}