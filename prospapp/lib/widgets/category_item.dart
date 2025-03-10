import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';

class CategoryItem extends StatelessWidget {
  final Map<String, dynamic> category;

  const CategoryItem({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final double padding = screenWidth < 360 ? 8.0 : 12.0;
    final double minFontSize = screenWidth < 360 ? 12.0 : 14.0;

    return Padding(
      padding: EdgeInsets.only(right: padding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: minFontSize * 1.5,
            backgroundColor: AppColors.primary.withOpacity(0.1),
            child: Icon(
              category['icon'],
              color: AppColors.primary,
              size: minFontSize * 1.5,
            ),
          ),
          SizedBox(height: padding / 2),
          Text(
            category['label'],
            style: AppTextStyles.prospectSubtitle(minFontSize - 2.0),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}