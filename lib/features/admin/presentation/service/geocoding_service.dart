import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class GeocodingService {
  static Future<Map<String, double>?> ottieniCoordinate(
    String indirizzo,
  ) async {
    try {
      final uri = Uri.parse(
        'https://nominatim.openstreetmap.org/search?q=${Uri.encodeComponent(indirizzo)}&format=json&limit=1',
      );

      final response = await http.get(
        uri,
        headers: {
          'User-Agent': 'AppCampi/1.0 (info@appcampi.it)',
          'Accept': 'application/json',
        },
      );

      debugPrint("Geocoding status: ${response.statusCode}"); // AGGIUNGI
      debugPrint("Geocoding body: ${response.body}"); // AGGIUNGI

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List;
        if (data.isNotEmpty) {
          return {
            'latitudine': double.parse(data[0]['lat'].toString()),
            'longitudine': double.parse(data[0]['lon'].toString()),
          };
        }
      }
    } catch (e) {
      debugPrint("Errore Geocoding: $e");
    }
    return null;
  }
}
