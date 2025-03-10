import 'package:flutter/material.dart'; // Für Icons, StatefulWidget, Scaffold, etc.
import 'package:geolocator/geolocator.dart'; // Für Geolocator
import 'package:provider/provider.dart'; // Für Provider
import '../../core/utils/constants.dart'; // Für prospects und categories
import '../../core/theme/app_colors.dart'; // Für AppColors
import '../../core/theme/app_text_styles.dart'; // Für AppTextStyles
import '../../widgets/prospect_card.dart'; // Für ProspectCard-Widget
import '../../widgets/category_item.dart'; // Für CategoryItem-Widget
import '../favorites/favorites_screen.dart'; // Für FavoritesScreen
import '../location/location_input_screen.dart'; // Für LocationInputScreen
import 'prospect_provider.dart'; // Für ProspectProvider

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
  int _selectedIndex = 0;

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
    Provider.of<ProspectProvider>(context, listen: false).loadProspects();
  }

  @override
  void dispose() {
    _controller.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final safeAreaPadding = MediaQuery.of(context).padding;

    final double padding = screenWidth < 360 ? 8.0 : 12.0;
    final double minFontSize = screenWidth < 360 ? 12.0 : 14.0;
    final double prospectAspectRatio = screenHeight < 600 ? 0.6 : 0.55;
    final double gridSpacing = screenWidth < 360 ? 6.0 : 8.0;

    return Consumer<ProspectProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          body: SafeArea(
            top: true,
            bottom: false,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final double baseExpandedHeight = screenHeight < 600 ? 200.0 : 220.0;
                final double expandedHeight = baseExpandedHeight + safeAreaPadding.top;

                return CustomScrollView(
                  slivers: [
                    SliverAppBar(
                      backgroundColor: AppColors.background,
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
                                    style: AppTextStyles.prospectSubtitle(minFontSize),
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      Icons.location_on,
                                      color: AppColors.primary,
                                      size: minFontSize * 1.5,
                                    ),
                                    onPressed: widget.onLocationChange,
                                  ),
                                ],
                              ),
                              SizedBox(height: padding / 2),
                              Container(
                                decoration: BoxDecoration(
                                  color: AppColors.white,
                                  borderRadius: BorderRadius.circular(30),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.grey.withOpacity(0.2),
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
                                      color: AppColors.textGrey,
                                      fontSize: minFontSize,
                                    ),
                                    border: InputBorder.none,
                                    prefixIcon: Icon(
                                      Icons.search,
                                      color: AppColors.textGrey,
                                      size: minFontSize * 1.5,
                                    ),
                                    contentPadding: EdgeInsets.symmetric(
                                        horizontal: padding * 1.5, vertical: padding),
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
                                        provider.setLocation(result);
                                        provider.filterProspects('');
                                      }
                                    }
                                  },
                                  onChanged: (value) => provider.filterProspects(value),
                                ),
                              ),
                              SizedBox(height: padding / 2),
                              SizedBox(
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
                            ],
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
                    SliverToBoxAdapter(
                      child: SizedBox(height: safeAreaPadding.bottom),
                    ),
                  ],
                );
              },
            ),
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: (index) {
              setState(() {
                _selectedIndex = index;
              });
              if (index == 0) {
                // Prospekte (bereits aktive Seite)
              } else if (index == 1) {
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
            selectedItemColor: AppColors.primary,
            unselectedItemColor: AppColors.textGrey,
            backgroundColor: AppColors.white,
            elevation: 5,
          ),
        );
      },
    );
  }
}