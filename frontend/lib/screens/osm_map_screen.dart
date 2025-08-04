import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart'; // For LatLng

class OsmMapScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("OpenStreetMap Example")),
      body: FlutterMap(
        options: MapOptions(
          center: LatLng(17.385044, 78.486671), // Example: Hyderabad
          zoom: 13.0,
        ),
        children: [
          // 🗺️ OpenStreetMap tiles
          TileLayer(
            urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
            subdomains: ['a', 'b', 'c'],
            userAgentPackageName: 'com.example.app',
          ),

          // 📍 Optional: Marker at source
          MarkerLayer(
            markers: [
              Marker(
                point: LatLng(17.385044, 78.486671),
                width: 40,
                height: 40,
                child: const Icon(Icons.location_on, color: Colors.green, size: 40),
              ),
              Marker(
                point: LatLng(17.391123, 78.479999),
                width: 40,
                height: 40,
                child: const Icon(Icons.flag, color: Colors.red, size: 40),
              ),
            ],
          ),

          // 🚏 Polyline between source and destination
          PolylineLayer(
            polylineCulling: false,
            polylines: [
              Polyline(
                points: [
                  LatLng(17.385044, 78.486671), // Source
                  LatLng(17.391123, 78.479999), // Destination
                ],
                color: Colors.red,
                strokeWidth: 4.0,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
