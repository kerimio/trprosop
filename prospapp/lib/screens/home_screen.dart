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
      'store': 'Woolworth',
      'latitude': 37.785834,
      'longitude': -122.436,
      'validUntil': '30.03.2025',
      'imageUrls': [
        'https://picsum.photos/150?random=1',
        'https://picsum.photos/150?random=2',
        'https://picsum.photos/150?random=3',
      ],
      'isNew': true,
    },
    {
      'store': 'toom Baumarkt',
      'latitude': 37.795834,
      'longitude': -122.426,
      'validUntil': '25.03.2025',
      'imageUrls': [
        'https://picsum.photos/150?random=4',
        'https://picsum.photos/150?random=5',
        'https://picsum.photos/150?random=6',
      ],
      'isNew': true,
    },
    {
      'store': 'REWE',
      'latitude': 37.805834,
      'longitude': -122.416,
      'validUntil': '20.03.2025',
      'imageUrls': [
        'https://picsum.photos/150?random=7',
        'https://picsum.photos/150?random=8',
      ],
      'isNew': false,
    },
    {
      'store': 'Lidl',
      'latitude': 37.815834,
      'longitude': -122.406,
      'validUntil': '15.03.2025',
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
    // Bildschirmgröße und SafeArea-Padding abrufen
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final safeAreaPadding = MediaQuery.of(context).padding;

    // Responsive Dimensionen berechnen
    final double padding = screenWidth < 360 ? 8.0 : 12.0;
    final double minFontSize = screenWidth < 360 ? 12.0 : 14.0;
    final double iconSizeHeart = screenWidth < 360 ? 14.0 : 16.0;
    final double prospectAspectRatio = screenHeight < 600 ? 0.6 : 0.55;
    final double gridSpacing = screenWidth < 360 ? 6.0 : 8.0;

    // Dynamische Höhe der SliverAppBar berechnen mit LayoutBuilder
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        top: true,
        bottom: true,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final double baseExpandedHeight = screenHeight < 600 ? 200.0 : 220.0; // Erhöhte Basis-Höhe
            final double expandedHeight = baseExpandedHeight + safeAreaPadding.top;

            return CustomScrollView(
              slivers: [
                // Obere Leiste (SliverAppBar)
                SliverAppBar(
                  backgroundColor: const Color(0xFFF5F5F5),
                  elevation: 0,
                  pinned: false,
                  floating: true,
                  snap: true,
                  expandedHeight: expandedHeight,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Padding(
                      padding: EdgeInsets.all(padding).copyWith(top: padding + safeAreaPadding.top),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Angebote für deinen Standort',
                                style: TextStyle(
                                  fontSize: minFontSize,
                                  color: const Color(0xFF757575),
                                ),
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.location_on,
                                  color: const Color(0xFF4CAF50),
                                  size: minFontSize * 1.5,
                                ),
                                onPressed: widget.onLocationChange,
                              ),
                            ],
                          ),
                          SizedBox(height: padding / 2),
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
                                hintStyle: TextStyle(
                                  color: const Color(0xFF757575),
                                  fontSize: minFontSize,
                                ),
                                border: InputBorder.none,
                                prefixIcon: Icon(
                                  Icons.search,
                                  color: const Color(0xFF757575),
                                  size: minFontSize * 1.5,
                                ),
                                contentPadding:
                                EdgeInsets.symmetric(horizontal: padding * 1.5, vertical: padding),
                              ),
                              onSubmitted: (value) async {
                                if (value.isNotEmpty) {
                                  final result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => const LocationInputScreen()),
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
                          SizedBox(height: padding / 2),
                          SizedBox(
                            height: minFontSize * 6, // Dynamische Höhe basierend auf Font-Größe
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: categories.map((category) {
                                  return Padding(
                                    padding: EdgeInsets.only(right: padding),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        CircleAvatar(
                                          radius: minFontSize * 1.5,
                                          backgroundColor:
                                          const Color(0xFF4CAF50).withOpacity(0.1),
                                          child: Icon(
                                            category['icon'],
                                            color: const Color(0xFF4CAF50),
                                            size: minFontSize * 1.5,
                                          ),
                                        ),
                                        SizedBox(height: padding / 2),
                                        Text(
                                          category['label'],
                                          style: TextStyle(
                                            fontSize: minFontSize - 2.0,
                                            color: const Color(0xFF757575),
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // GridView für Prospekte
                SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: padding, vertical: padding),
                  sliver: SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: gridSpacing,
                      mainAxisSpacing: gridSpacing,
                      childAspectRatio: prospectAspectRatio,
                    ),
                    delegate: SliverChildBuilderDelegate(
                          (context, index) {
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
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.favorite_border,
                                      color: const Color(0xFFF44336),
                                      size: iconSizeHeart,
                                    ),
                                    SizedBox(width: padding / 2),
                                    Expanded(
                                      child: Text(
                                        _filteredProspects[index]['store'],
                                        style: Theme.of(context)
                                            .textTheme
                                            .headlineLarge
                                            ?.copyWith(
                                          fontSize: minFontSize,
                                          fontWeight: FontWeight.bold,
                                          color: const Color(0xFF212121),
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: padding / 2),
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(padding),
                                    child: AspectRatio(
                                      aspectRatio: prospectAspectRatio,
                                      child: Image.network(
                                        imageUrl,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          return Container(
                                            color: Colors.grey,
                                            child: const Center(
                                                child: Text('Bild nicht verfügbar')),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(top: padding / 2),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          '${calculateDaysLeft(_filteredProspects[index]['validUntil'])} - $distance',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.copyWith(
                                            color: const Color(0xFF757575),
                                            fontSize: minFontSize - 2.0,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      if (_filteredProspects[index]['isNew'] == true)
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
                        );
                      },
                      childCount: _filteredProspects.length,
                    ),
                  ),
                ),
                // Spacer am unteren Rand, um den SafeArea-Bereich zu berücksichtigen
                SliverToBoxAdapter(
                  child: SizedBox(height: safeAreaPadding.bottom),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}