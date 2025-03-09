import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'prospect_detail_screen.dart';
import 'location_input_screen.dart';

class HomeScreen extends StatefulWidget {
  final String location;
  final VoidCallback onLocationChange;

  const HomeScreen({super.key, required this.location, required this.onLocationChange});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  final TextEditingController _searchController = TextEditingController();
  String _filter = 'distance'; // Standardfilter: Nächste Entfernung
  List<Map<String, dynamic>> _prospects = [];
  List<Map<String, dynamic>> _filteredProspects = [];

  final List<Map<String, dynamic>> prospects = const [
    {
      'store': 'Türkischer Markt',
      'latitude': 37.785834,
      'longitude': -122.436,
      'validUntil': '15.03.2025',
      'imageUrls': [
        'https://picsum.photos/150?random=1',
        'https://picsum.photos/150?random=2',
        'https://picsum.photos/150?random=3',
      ],
    },
    {
      'store': 'Afroshop',
      'latitude': 37.795834,
      'longitude': -122.426,
      'validUntil': '20.03.2025',
      'imageUrls': [
        'https://picsum.photos/150?random=4',
        'https://picsum.photos/150?random=5',
        'https://picsum.photos/150?random=6',
      ],
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
    _loadProspects();
  }

  @override
  void dispose() {
    _controller.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _loadProspects() {
    setState(() {
      _prospects = prospects.map((prospect) => prospect).toList();
      _filteredProspects = _prospects;
      _sortProspects();
    });
  }

  void _sortProspects() {
    if (_filter == 'distance' && widget.location.isNotEmpty) {
      final List<String> coords = widget.location.split(', ');
      final double userLat = double.parse(coords[0]);
      final double userLon = double.parse(coords[1]);
      _filteredProspects.sort((a, b) {
        double distanceA = Geolocator.distanceBetween(
            userLat, userLon, a['latitude'], a['longitude']);
        double distanceB = Geolocator.distanceBetween(
            userLat, userLon, b['latitude'], b['longitude']);
        return distanceA.compareTo(distanceB);
      });
    } else if (_filter == 'newest') {
      _filteredProspects.sort((a, b) {
        DateTime dateA = DateTime.parse(a['validUntil'].split('.').reversed.join('-'));
        DateTime dateB = DateTime.parse(b['validUntil'].split('.').reversed.join('-'));
        return dateB.compareTo(dateA);
      });
    }
  }

  void _filterProspects(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredProspects = _prospects;
      } else {
        _filteredProspects = _prospects
            .where((prospect) =>
            prospect['store'].toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
      _sortProspects();
    });
  }

  String calculateDistance(double userLat, double userLon, double storeLat, double storeLon) {
    double distanceInMeters = Geolocator.distanceBetween(userLat, userLon, storeLat, storeLon);
    double distanceInKm = distanceInMeters / 1000;
    return distanceInKm.toStringAsFixed(1);
  }

  bool isCoordinates(String location) {
    return location.contains(', ');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Prospekte'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.location_on, color: Color(0xFFAB47BC)),
            onPressed: widget.onLocationChange,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                Expanded(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Adresse oder Markt suchen...',
                        border: InputBorder.none,
                        prefixIcon: const Icon(Icons.search, color: Color(0xFFAB47BC)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      ),
                      onSubmitted: (value) async {
                        if (value.isNotEmpty) {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const LocationInputScreen()),
                          );
                          if (result != null) {
                            widget.onLocationChange();
                            setState(() {
                              _filterProspects('');
                            });
                          }
                        }
                      },
                      onChanged: (value) => _filterProspects(value),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.filter_list, color: Color(0xFFAB47BC)),
                  onSelected: (value) {
                    setState(() {
                      _filter = value;
                      _sortProspects();
                    });
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'distance',
                      child: Text('Nächste Entfernung'),
                    ),
                    const PopupMenuItem(
                      value: 'newest',
                      child: Text('Neueste Prospekte'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(20),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                childAspectRatio: 0.7,
              ),
              itemCount: _filteredProspects.length,
              itemBuilder: (context, index) {
                String distance = 'N/A';
                if (isCoordinates(widget.location)) {
                  final List<String> coords = widget.location.split(', ');
                  final double userLat = double.parse(coords[0]);
                  final double userLon = double.parse(coords[1]);
                  distance = calculateDistance(
                    userLat,
                    userLon,
                    _filteredProspects[index]['latitude'],
                    _filteredProspects[index]['longitude'],
                  );
                }

                // Sicherstellen, dass imageUrls existiert und eine Liste ist
                final imageUrls = _filteredProspects[index]['imageUrls'] as List<dynamic>?;
                final imageUrl = imageUrls != null && imageUrls.isNotEmpty
                    ? imageUrls[0]
                    : 'https://via.placeholder.com/150';

                return FadeTransition(
                  opacity: _fadeAnimation,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (context, animation, secondaryAnimation) =>
                              ProspectDetailScreen(
                                prospect: _filteredProspects[index],
                                distance: distance, // Entfernung übergeben
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
                              imageUrl,
                              height: 110,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  height: 110,
                                  color: Colors.grey,
                                  child: const Center(child: Text('Bild nicht verfügbar')),
                                );
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _filteredProspects[index]['store'],
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineLarge
                                      ?.copyWith(fontSize: 18),
                                ),
                                const SizedBox(height: 5),
                                Row(
                                  children: [
                                    const Icon(Icons.location_on,
                                        size: 16, color: Color(0xFFAB47BC)),
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
                                    const Icon(Icons.calendar_today,
                                        size: 16, color: Color(0xFFAB47BC)),
                                    const SizedBox(width: 5),
                                    Text(
                                      _filteredProspects[index]['validUntil'],
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
          ),
        ],
      ),
    );
  }
}