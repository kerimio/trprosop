import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'prospect_detail_screen.dart';

class ProspectGalleryScreen extends StatefulWidget {
  final String location;

  const ProspectGalleryScreen({super.key, required this.location});

  @override
  _ProspectGalleryScreenState createState() => _ProspectGalleryScreenState();
}

class _ProspectGalleryScreenState extends State<ProspectGalleryScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  final List<Map<String, dynamic>> prospects = const [
    {
      'store': 'Türkischer Markt',
      'latitude': 37.785834,
      'longitude': -122.436,
      'validUntil': '15.03.2025',
      'imageUrl': 'https://via.placeholder.com/150',
    },
    {
      'store': 'Afroshop',
      'latitude': 37.795834,
      'longitude': -122.426,
      'validUntil': '20.03.2025',
      'imageUrl': 'https://via.placeholder.com/150',
    },
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String calculateDistance(double userLat, double userLon, double storeLat, double storeLon) {
    double distanceInMeters = Geolocator.distanceBetween(userLat, userLon, storeLat, storeLon);
    double distanceInKm = distanceInMeters / 1000;
    return distanceInKm.toStringAsFixed(1);
  }

  @override
  Widget build(BuildContext context) {
    final List<String> coords = widget.location.split(', ');
    final double userLat = double.parse(coords[0]);
    final double userLon = double.parse(coords[1]);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Aktuelle Prospekte'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        titleTextStyle: Theme.of(context).textTheme.headlineLarge?.copyWith(
          color: const Color(0xFF212121),
        ),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(20),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 15,
          mainAxisSpacing: 15,
          childAspectRatio: 0.7,
        ),
        itemCount: prospects.length,
        itemBuilder: (context, index) {
          String distance = calculateDistance(
            userLat,
            userLon,
            prospects[index]['latitude'],
            prospects[index]['longitude'],
          );

          return FadeTransition(
            opacity: _fadeAnimation,
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) => ProspectDetailScreen(
                      prospect: prospects[index],
                    ),
                    transitionsBuilder: (context, animation, secondaryAnimation, child) {
                      return ScaleTransition(
                        scale: Tween<double>(begin: 0.9, end: 1.0).animate(
                          CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
                        ),
                        child: child,
                      );
                    },
                  ),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFE0B2), Color(0xFFFFF3E0)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                      child: Image.network(
                        prospects[index]['imageUrl'],
                        height: 110,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            prospects[index]['store'],
                            style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontSize: 18),
                          ),
                          const SizedBox(height: 5),
                          Row(
                            children: [
                              const Icon(Icons.location_on, size: 16, color: Color(0xFFAB47BC)),
                              const SizedBox(width: 5),
                              Text(
                                '$distance km',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                          const SizedBox(height: 5),
                          Row(
                            children: [
                              const Icon(Icons.calendar_today, size: 16, color: Color(0xFFAB47BC)),
                              const SizedBox(width: 5),
                              Text(
                                prospects[index]['validUntil'],
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
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
    );
  }
}