import 'package:flutter/material.dart';

class ProspectGalleryScreen extends StatelessWidget {
  final String location;

  const ProspectGalleryScreen({super.key, required this.location});

  // Dummy-Daten für Prospekte
  final List<Map<String, dynamic>> prospects = const [
    {
      'store': 'Türkischer Markt',
      'distance': '2.5 km',
      'validUntil': '15.03.2025',
      'imageUrl': 'https://via.placeholder.com/150',
    },
    {
      'store': 'Afroshop',
      'distance': '1.8 km',
      'validUntil': '20.03.2025',
      'imageUrl': 'https://via.placeholder.com/150',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Aktuelle Prospekte'),
        backgroundColor: Colors.teal,
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(10),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 0.75,
        ),
        itemCount: prospects.length,
        itemBuilder: (context, index) {
          return Card(
            elevation: 5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                  child: Image.network(
                    prospects[index]['imageUrl'],
                    height: 100,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        prospects[index]['store'],
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Text('Entfernung: ${prospects[index]['distance']}'),
                      Text('Gültig bis: ${prospects[index]['validUntil']}'),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}