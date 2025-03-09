import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'prospect_gallery_screen.dart';

class LocationInputScreen extends StatefulWidget {
  const LocationInputScreen({super.key});

  @override
  _LocationInputScreenState createState() => _LocationInputScreenState();
}

class _LocationInputScreenState extends State<LocationInputScreen> {
  final TextEditingController _controller = TextEditingController();
  List<Map<String, dynamic>> _suggestions = [];
  final String _apiKey = 'MY_API_KEY'; // Dein Key

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _fetchSuggestions(String input) async {
    if (input.length < 3) {
      setState(() {
        _suggestions = [];
      });
      return;
    }

    print('Fetching suggestions for: $input');
    final response = await http.post(
      Uri.parse('https://places.googleapis.com/v1/places:autocomplete'),
      headers: {
        'Content-Type': 'application/json',
        'X-Goog-Api-Key': _apiKey,
        'X-Goog-FieldMask': 'suggestions.placePrediction.text,suggestions.placePrediction.placeId', // Entfernte Sternchen für Klarheit
      },
      body: jsonEncode({
        'input': input
      }),
    );

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print('Decoded data: $data');
      if (data.containsKey('suggestions')) {
        setState(() {
          _suggestions = (data['suggestions'] as List)
              .map((suggestion) => {
            'description': suggestion['placePrediction']['text']['text'], // Korrigierte Extraktion
            'placeId': suggestion['placePrediction']['placeId'],
          })
              .toList();
        });
      } else {
        print('No suggestions data found');
        setState(() {
          _suggestions = [];
        });
      }
    } else {
      print('Failed with status: ${response.statusCode}');
      setState(() {
        _suggestions = [];
      });
    }
  }

  Future<String> _getCoordinates(String placeId) async {
    final response = await http.get(
      Uri.parse('https://maps.googleapis.com/maps/api/geocode/json?place_id=$placeId&key=$_apiKey'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['status'] == 'OK') {
        final location = data['results'][0]['geometry']['location'];
        return '${location['lat']}, ${location['lng']}';
      }
    }
    throw Exception('Failed to get coordinates');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFFE0B2), Colors.white],
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    hintText: 'PLZ oder Stadt eingeben...',
                    border: InputBorder.none,
                    prefixIcon: const Icon(Icons.location_on, color: Color(0xFFAB47BC)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  ),
                  onChanged: (value) => _fetchSuggestions(value),
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _suggestions.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: const Icon(Icons.location_city, color: Color(0xFFAB47BC)),
                    title: Text(_suggestions[index]['description']),
                    onTap: () async {
                      try {
                        String coordinates = await _getCoordinates(_suggestions[index]['placeId']);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProspectGalleryScreen(location: coordinates),
                          ),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Fehler: $e')),
                        );
                      }
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}