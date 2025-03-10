import 'package:flutter/material.dart';
List<Map<String, dynamic>> prospects = [
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

List<Map<String, dynamic>> categories = [
  {'label': 'Top Deals', 'icon': Icons.local_offer},
  {'label': 'Rezepte', 'icon': Icons.restaurant},
  {'label': 'kaufDA', 'icon': Icons.store},
  {'label': 'IKEA', 'icon': Icons.home},
];