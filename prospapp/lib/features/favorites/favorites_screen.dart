import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../../core/utils/helpers.dart'; // Für calculateDistance, calculateDaysLeft
import '../prospect/prospect_detail_screen.dart';

class FavoritesScreen extends StatelessWidget {
  final Set<int> favorites;
  final List<Map<String, dynamic>> filteredProspects;
  final String location;

  const FavoritesScreen({
    super.key,
    required this.favorites,
    required this.filteredProspects,
    required this.location,
  });

  String calculateDistance(double userLat, double userLon, double storeLat, double storeLon) {
    double distanceInMeters = Geolocator.distanceBetween(userLat, userLon, storeLat, storeLon);
    if (distanceInMeters > 990) {
      double distanceInKm = distanceInMeters / 1000;
      return '${distanceInKm.toStringAsFixed(1)} km';
    } else {
      return '${distanceInMeters.toStringAsFixed(0)} m';
    }
  }

  String calculateDaysLeft(String validUntil) {
    DateTime currentDate = DateTime(2025, 3, 9); // Aktuelles Datum: 9. März 2025
    DateTime expiryDate = DateTime.parse(validUntil.split('.').reversed.join('-'));
    int daysLeft = expiryDate.difference(currentDate).inDays;
    return '$daysLeft Tage gültig';
  }

  bool isCoordinates(String location) {
    return location.contains(', ');
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final double padding = screenWidth < 360 ? 8.0 : 12.0;
    final double minFontSize = screenWidth < 360 ? 12.0 : 14.0;

    // Filtere die favorisierten Prospekte basierend auf den Indizes in `favorites`
    final List<Map<String, dynamic>> favoriteProspects = filteredProspects
        .asMap()
        .entries
        .where((entry) => favorites.contains(entry.key))
        .map((entry) => entry.value)
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Favoriten'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        bottom: false,
        child: favoriteProspects.isEmpty
            ? const Center(child: Text('Keine Favoriten vorhanden'))
            : ListView.builder(
          padding: EdgeInsets.all(padding),
          itemCount: favoriteProspects.length,
          itemBuilder: (context, index) {
            final prospect = favoriteProspects[index];
            String distance = 'N/A';
            if (isCoordinates(location)) {
              final List<String> coords = location.split(', ');
              final double userLat = double.parse(coords[0]);
              final double userLon = double.parse(coords[1]);
              distance = calculateDistance(
                userLat,
                userLon,
                prospect['latitude'],
                prospect['longitude'],
              );
            }

            final imageUrls = prospect['imageUrls'] as List<dynamic>?;
            final imageUrl = imageUrls != null && imageUrls.isNotEmpty
                ? imageUrls[0]
                : 'https://via.placeholder.com/150';

            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProspectDetailScreen(
                      prospect: prospect,
                      distance: distance,
                    ),
                  ),
                );
              },
              child: Card(
                elevation: 5,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                color: Colors.white,
                margin: EdgeInsets.symmetric(vertical: padding / 2),
                child: Padding(
                  padding: EdgeInsets.all(padding),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          imageUrl,
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey,
                              child: const Center(child: Text('Bild nicht verfügbar')),
                            );
                          },
                        ),
                      ),
                      SizedBox(width: padding),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              prospect['store'],
                              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                                fontSize: minFontSize,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF212121),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              '${calculateDaysLeft(prospect['validUntil'])} - $distance',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: const Color(0xFF757575),
                                fontSize: minFontSize - 2.0,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (prospect['isNew'] == true)
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: padding / 2, vertical: padding / 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF44336),
                                  borderRadius: BorderRadius.circular(padding / 2),
                                ),
                                child: Text(
                                  'NEU',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: minFontSize - 2.0,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1, // Favoriten ist der aktive Tab
        onTap: (index) {
          if (index == 0) {
            Navigator.pop(context); // Zurück zur HomeScreen
          } else if (index == 4) {
            // Einstellungen (Platzhalter)
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Prospekte'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Favoriten'),
          BottomNavigationBarItem(icon: Icon(Icons.circle), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.circle), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Einstellungen'),
        ],
        selectedItemColor: const Color(0xFF4CAF50),
        unselectedItemColor: const Color(0xFF757575),
        backgroundColor: Colors.white,
        elevation: 5,
      ),
    );
  }
}