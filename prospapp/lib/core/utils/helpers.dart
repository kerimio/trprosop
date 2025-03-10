import 'package:geolocator/geolocator.dart';

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
  DateTime currentDate = DateTime(2025, 3, 9);
  DateTime expiryDate = DateTime.parse(validUntil.split('.').reversed.join('-'));
  int daysLeft = expiryDate.difference(currentDate).inDays;
  return '$daysLeft Tage gültig';
}