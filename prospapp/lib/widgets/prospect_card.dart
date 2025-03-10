import 'package:flutter/material.dart';
import '../core/utils/helpers.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../features/prospect/prospect_detail_screen.dart';
import '../features/home/prospect_provider.dart';
import 'package:provider/provider.dart';

class ProspectCard extends StatelessWidget {
  final Map<String, dynamic> prospect;
  final String location;
  final int index;
  final bool isFavorite;
  final VoidCallback onFavoriteToggle;

  const ProspectCard({
    super.key,
    required this.prospect,
    required this.location,
    required this.index,
    required this.isFavorite,
    required this.onFavoriteToggle,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final double padding = screenWidth < 360 ? 8.0 : 12.0;
    final double minFontSize = screenWidth < 360 ? 12.0 : 14.0;
    final double prospectAspectRatio = MediaQuery.of(context).size.height < 600 ? 0.6 : 0.55;

    String distance = 'N/A';
    if (location.isNotEmpty && location.contains(', ')) {
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
    final imageUrl = imageUrls != null && imageUrls.isNotEmpty ? imageUrls[0] : 'https://via.placeholder.com/150';

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProspectDetailScreen(prospect: prospect, distance: distance),
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: AppColors.accentRed,
                  size: minFontSize,
                ),
                onPressed: onFavoriteToggle,
              ),
              SizedBox(width: padding / 2),
              Expanded(
                child: Text(
                  prospect['store'],
                  style: AppTextStyles.prospectTitle(minFontSize),
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
                      color: AppColors.grey,
                      child: const Center(child: Text('Bild nicht verfügbar')),
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
                    '${calculateDaysLeft(prospect['validUntil'])} - $distance',
                    style: AppTextStyles.prospectSubtitle(minFontSize - 2.0),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (prospect['isNew'] == true)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: padding / 2, vertical: padding / 4),
                    decoration: BoxDecoration(
                      color: AppColors.accentRed,
                      borderRadius: BorderRadius.circular(padding / 2),
                    ),
                    child: Text(
                      'NEU',
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: minFontSize - 2.0,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}