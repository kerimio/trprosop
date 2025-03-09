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
      'store': 'Lidl',
      'latitude': 37.785834,
      'longitude': -122.436,
      'validUntil': '15.03.2025',
      'imageUrls': [
        'https://picsum.photos/150?random=1',
        'https://picsum.photos/150?random=2',
        'https://picsum.photos/150?random=3',
      ],
      'isNew': true,
    },
    {
      'store': 'Lidl',
      'latitude': 37.785834,
      'longitude': -122.436,
      'validUntil': '15.03.2025',
      'imageUrls': [
        'https://picsum.photos/150?random=1',
        'https://picsum.photos/150?random=2',
        'https://picsum.photos/150?random=3',
      ],
      'isNew': true,
    },
    {
      'store': 'Lidl',
      'latitude': 37.785834,
      'longitude': -122.436,
      'validUntil': '15.03.2025',
      'imageUrls': [
        'https://picsum.photos/150?random=1',
        'https://picsum.photos/150?random=2',
        'https://picsum.photos/150?random=3',
      ],
      'isNew': true,
    },
    {
      'store': 'Lidl',
      'latitude': 37.785834,
      'longitude': -122.436,
      'validUntil': '15.03.2025',
      'imageUrls': [
        'https://picsum.photos/150?random=1',
        'https://picsum.photos/150?random=2',
        'https://picsum.photos/150?random=3',
      ],
      'isNew': true,
    },
    {
      'store': 'Lidl',
      'latitude': 37.785834,
      'longitude': -122.436,
      'validUntil': '15.03.2025',
      'imageUrls': [
        'https://picsum.photos/150?random=1',
        'https://picsum.photos/150?random=2',
        'https://picsum.photos/150?random=3',
      ],
      'isNew': true,
    },
    {
      'store': 'REWE',
      'latitude': 37.795834,
      'longitude': -122.426,
      'validUntil': '20.03.2025',
      'imageUrls': [
        'https://picsum.photos/150?random=4',
        'https://picsum.photos/150?random=5',
        'https://picsum.photos/150?random=6',
      ],
      'isNew': true,
    },
    {
      'store': 'toom Baumarkt',
      'latitude': 37.805834,
      'longitude': -122.416,
      'validUntil': '25.03.2025',
      'imageUrls': [
        'https://picsum.photos/150?random=7',
        'https://picsum.photos/150?random=8',
      ],
      'isNew': false,
    },
    {
      'store': 'Woolworth',
      'latitude': 37.815834,
      'longitude': -122.406,
      'validUntil': '30.03.2025',
      'imageUrls': [
        'https://picsum.photos/150?random=9',
        'https://picsum.photos/150?random=10',
      ],
      'isNew': false,
    },
  ];

  final List<Map<String, dynamic>> categories = const [
    {'label': 'Top Deals', 'icon': Icons.local_offer},
    {'label': 'Rezepte', 'icon': Icons.restaurant},
    {'label': 'kaufDA', 'icon': Icons.store},
    {'label': 'IKEA', 'icon': Icons.home},
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
    return distanceInMeters.toStringAsFixed(0); // In Metern, ohne Dezimalstellen
  }

  bool isCoordinates(String location) {
    return location.contains(', ');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5), // Heller Hintergrund
      body: SafeArea(
        bottom: true, // Sicherstellen, dass die untere Systemleiste berücksichtigt wird
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0), // Globale Padding-Anpassung
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Angebote für deinen Standort',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF757575), // Grau
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.location_on, color: Color(0xFF4CAF50)), // Grün
                    onPressed: widget.onLocationChange,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Suche nach Produkten, Händler & mehr',
                    hintStyle: const TextStyle(color: Color(0xFF757575)), // Grau
                    border: InputBorder.none,
                    prefixIcon: const Icon(Icons.search, color: Color(0xFF757575)),
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
              const SizedBox(height: 20),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: categories.map((category) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 15.0),
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: const Color(0xFF4CAF50).withOpacity(0.1), // Grün
                            child: Icon(category['icon'], color: const Color(0xFF4CAF50)),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            category['label'],
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF757575), // Grau
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 20),
              GridView.builder(
                shrinkWrap: true, // Wichtig, damit GridView in SingleChildScrollView passt
                physics: const NeverScrollableScrollPhysics(), // Scrolling wird von SingleChildScrollView übernommen
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                  childAspectRatio: 0.75,
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
                                  distance: distance,
                                ),
                            transitionsBuilder:
                                (context, animation, secondaryAnimation, child) {
                              return ScaleTransition(
                                scale: Tween<double>(begin: 0.9, end: 1.0).animate(
                                  CurvedAnimation(
                                      parent: animation, curve: Curves.easeOutCubic),
                                ),
                                child: child,
                              );
                            },
                          ),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
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
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                              child: Stack(
                                children: [
                                  Image.network(
                                    imageUrl,
                                    height: 120,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        height: 120,
                                        color: Colors.grey,
                                        child: const Center(
                                            child: Text('Bild nicht verfügbar')),
                                      );
                                    },
                                  ),
                                  if (_filteredProspects[index]['isNew'] == true)
                                    Positioned(
                                      top: 5,
                                      left: 5,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF44336), // Rot
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: const Text(
                                          'NEU',
                                          style: TextStyle(
                                              color: Colors.white, fontSize: 12),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _filteredProspects[index]['store'],
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineLarge
                                        ?.copyWith(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF212121), // Dunkelgrau
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Row(
                                    children: [
                                      const Icon(Icons.location_on,
                                          size: 14, color: Color(0xFF757575)), // Grau
                                      const SizedBox(width: 5),
                                      Text(
                                        '$distance m',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(color: const Color(0xFF757575)),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 5),
                                  Row(
                                    children: [
                                      const Icon(Icons.calendar_today,
                                          size: 14, color: Color(0xFF757575)), // Grau
                                      const SizedBox(width: 5),
                                      Text(
                                        '${_filteredProspects[index]['validUntil'].split('.').reversed.join('-').substring(0, 10)} gültig',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(color: const Color(0xFF757575)),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.favorite_border,
                                      color: Color(0xFFF44336)), // Rot
                                  onPressed: () {
                                    // Favoriten-Logik hier
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}