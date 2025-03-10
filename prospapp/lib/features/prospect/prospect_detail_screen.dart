import 'package:flutter/material.dart';

class ProspectDetailScreen extends StatelessWidget {
  final Map<String, dynamic> prospect;
  final String distance;

  const ProspectDetailScreen({
    super.key,
    required this.prospect,
    required this.distance, // Entfernung als Parameter hinzufügen
  });

  @override
  Widget build(BuildContext context) {
    // Sicherstellen, dass imageUrls existiert und eine Liste ist
    final imageUrls = prospect['imageUrls'] as List<dynamic>?;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5), // Heller Hintergrund wie im HomeScreen
      appBar: AppBar(
        title: Text(prospect['store']),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        bottom: true, // Sicherstellen, dass die untere Systemleiste berücksichtigt wird
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  prospect['store'],
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF212121), // Dunkelgrau wie im HomeScreen
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on,
                      size: 14,
                      color: Color(0xFF757575), // Grau wie im HomeScreen
                    ),
                    const SizedBox(width: 5),
                    Text(
                      'Entfernung: $distance m', // Anpassung an Metern wie im HomeScreen
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF757575),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      size: 14,
                      color: Color(0xFF757575), // Grau wie im HomeScreen
                    ),
                    const SizedBox(width: 5),
                    Text(
                      'Gültig bis: ${prospect['validUntil']}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF757575),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                imageUrls != null && imageUrls.isNotEmpty
                    ? ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: imageUrls.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white, // Weißer Hintergrund wie im HomeScreen
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: AspectRatio(
                                aspectRatio: 1.0, // Quadratisches Bild wie im HomeScreen
                                child: Image.network(
                                  imageUrls[index],
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      color: Colors.grey,
                                      child: const Center(child: Text('Bild nicht verfügbar')),
                                    );
                                  },
                                ),
                              ),
                            ),
                            if (prospect['isNew'] == true)
                              Positioned(
                                top: 5,
                                left: 5,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF44336), // Rot wie im HomeScreen
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Text(
                                    'NEU',
                                    style: TextStyle(color: Colors.white, fontSize: 12),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                )
                    : const Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Text(
                    'Keine Bilder verfügbar',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}