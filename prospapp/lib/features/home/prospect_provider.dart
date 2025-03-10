import 'package:flutter/material.dart';
import '../../core/services/data_service.dart';
import 'package:geolocator/geolocator.dart';

class ProspectProvider with ChangeNotifier {
  List<Map<String, dynamic>> _prospects = [];
  List<Map<String, dynamic>> _filteredProspects = [];
  Set<int> _favorites = {};
  String _filter = 'distance';
  String _location = '';

  List<Map<String, dynamic>> get filteredProspects => _filteredProspects;
  Set<int> get favorites => _favorites;
  String get location => _location;

  final DataService _dataService = DataService();

  void loadProspects() {
    _prospects = _dataService.getProspects();
    _filteredProspects = List.from(_prospects);
    sortProspects();
    notifyListeners();
  }

  void sortProspects() {
    if (_filter == 'distance' && _location.isNotEmpty) {
      final List<String> coords = _location.split(', ');
      final double userLat = double.parse(coords[0]);
      final double userLon = double.parse(coords[1]);
      _filteredProspects.sort((a, b) {
        double distanceA = Geolocator.distanceBetween(userLat, userLon, a['latitude'], a['longitude']);
        double distanceB = Geolocator.distanceBetween(userLat, userLon, b['latitude'], b['longitude']);
        return distanceA.compareTo(distanceB);
      });
      notifyListeners();
    } else if (_filter == 'newest') {
      _filteredProspects.sort((a, b) {
        DateTime dateA = DateTime.parse(a['validUntil'].split('.').reversed.join('-'));
        DateTime dateB = DateTime.parse(b['validUntil'].split('.').reversed.join('-'));
        return dateB.compareTo(dateA);
      });
      notifyListeners();
    }
  }
  void setFilter(String filter) {
    _filter = filter;
    sortProspects();
  }
  void filterProspects(String query) {
    if (query.isEmpty) {
      _filteredProspects = List.from(_prospects);
    } else {
      _filteredProspects = _prospects
          .where((prospect) => prospect['store'].toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
    sortProspects();
  }

  void toggleFavorite(int index) {
    if (_favorites.contains(index)) {
      _favorites.remove(index);
    } else {
      _favorites.add(index);
    }
    notifyListeners();
  }

  void setLocation(String location) {
    _location = location;
    sortProspects();
  }
}