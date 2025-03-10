import '../utils/constants.dart';

class DataService {
  List<Map<String, dynamic>> getProspects() {
    return List.from(prospects); // Kopie der Daten
  }

  List<Map<String, dynamic>> getCategories() {
    return List.from(categories); // Kopie der Daten
  }
}