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
      appBar: AppBar(
        title: Text(prospect['store']),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFFE0B2), Colors.white],
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      prospect['store'],
                      style: Theme.of(context)
                          .textTheme
                          .headlineLarge
                          ?.copyWith(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 16, color: Color(0xFFAB47BC)),
                        const SizedBox(width: 5),
                        Text(
                          'Entfernung: $distance km',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 16, color: Color(0xFFAB47BC)),
                        const SizedBox(width: 5),
                        Text(
                          'Gültig bis: ${prospect['validUntil']}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              imageUrls != null && imageUrls.isNotEmpty
                  ? ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: imageUrls.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Image.network(
                        imageUrls[index],
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 200,
                            color: Colors.grey,
                            child: const Center(child: Text('Bild nicht verfügbar')),
                          );
                        },
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
    );
  }
}