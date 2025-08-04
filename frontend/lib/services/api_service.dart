import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://192.168.68.109:8000'; // 🔁 Replace with your local IP

  // ✅ Geocode API (optional)
  static Future<List<dynamic>> getGeocode(String location) async {
    final response = await http.get(Uri.parse('$baseUrl/geocode?location=$location'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to fetch geocode');
    }
  }

  // ✅ Route Polyline API (OpenRouteService-style)
  static Future<List<List<double>>> getRoutePolyline(String start, String end) async {
    final response = await http.get(Uri.parse('$baseUrl/route?start=$start&end=$end'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final coords = data['features'][0]['geometry']['coordinates'];

      // Convert from [lon, lat] to [lat, lon]
      return coords.map<List<double>>((coord) => [coord[1], coord[0]]).toList();
    } else {
      throw Exception('Failed to fetch route');
    }
  }
}
