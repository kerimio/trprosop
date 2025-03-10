import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import '../../core/utils/constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../widgets/prospect_card.dart';
import '../../widgets/category_item.dart';
import '../favorites/favorites_screen.dart';
import '../location/location_input_screen.dart';
import 'prospect_provider.dart';

class HomeScreen extends StatefulWidget {
  final String location;
  final VoidCallback onLocationChange;

  const HomeScreen({super.key, required this.location, required this.onLocationChange});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchController = TextEditingController();
  String _filter = 'distance';

  @override
  void initState() {
    super.initState();
    // Verzögere loadProspects, bis nach dem Build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProspectProvider>(context, listen: false).loadProspects();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterProspects(String query) {
    Provider.of<ProspectProvider>(context, listen: false).filterProspects(query);
  }

  void _changeFilter(String filter) {
    setState(() {
      _filter = filter;
    });
    Provider.of<ProspectProvider>(context, listen: false).setFilter(filter);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final double padding = screenWidth < 360 ? 8.0 : 12.0;
    final double minFontSize = screenWidth < 360 ? 12.0 : 14.0;
    final double gridSpacing = screenWidth < 360 ? 4.0 : 8.0;
    final double prospectAspectRatio = MediaQuery.of(context).size.height < 600 ? 0.6 : 0.55;

    final provider = Provider.of<ProspectProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Prospekte'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterDialog(),
          ),
        ],
      ),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(padding),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Suche nach Prospekten...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(padding),
                  ),
                ),
                onChanged: _filterProspects,
              ),
            ),
            Expanded(
              child: CustomScrollView(
                slivers: [
                  SliverPadding(
                    padding: EdgeInsets.symmetric(horizontal: padding),
                    sliver: SliverToBoxAdapter(
                      child: SizedBox(
                        height: minFontSize * 6,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: categories.map((category) {
                              return CategoryItem(category: category);
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
                  ),
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
                          return ProspectCard(
                            prospect: provider.filteredProspects[index],
                            location: provider.location,
                            index: index,
                            isFavorite: provider.favorites.contains(index),
                            onFavoriteToggle: () => provider.toggleFavorite(index),
                          );
                        },
                        childCount: provider.filteredProspects.length,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0, // Home ist der aktive Tab
        onTap: (index) {
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => FavoritesScreen(
                  favorites: provider.favorites,
                  filteredProspects: provider.filteredProspects,
                  location: provider.location,
                ),
              ),
            );
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

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Filter'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<String>(
                title: const Text('Entfernung'),
                value: 'distance',
                groupValue: _filter,
                onChanged: (value) {
                  Navigator.pop(context);
                  _changeFilter(value!);
                },
              ),
              RadioListTile<String>(
                title: const Text('Neueste'),
                value: 'newest',
                groupValue: _filter,
                onChanged: (value) {
                  Navigator.pop(context);
                  _changeFilter(value!);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}