import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '../services/route_service.dart';

class TrackBusScreen extends StatefulWidget {
  final LatLng busLocation;
  final LatLng destinationStop;
  final String busName;
  final List<String> routeStops;

  const TrackBusScreen({
    super.key,
    required this.busLocation,
    required this.destinationStop,
    required this.busName,
    required this.routeStops,
  });

  @override
  State<TrackBusScreen> createState() => _TrackBusScreenState();
}

class _TrackBusScreenState extends State<TrackBusScreen> {
  List<LatLng> routePoints = [];
  LatLng? userLatLng;
  StreamSubscription<Position>? positionStream;

  @override
  void initState() {
    super.initState();
    _loadRoute();
    _getUserLiveLocation();
  }

  @override
  void dispose() {
    positionStream?.cancel();
    super.dispose();
  }

  Future<void> _loadRoute() async {
    try {
      final points = await RouteService.getRoute(widget.busLocation, widget.destinationStop);
      setState(() {
        routePoints = points;
      });
    } catch (e) {
      print('Error loading route: $e');
    }
  }

  void _getUserLiveLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
    }

    positionStream = Geolocator.getPositionStream().listen((Position position) {
      setState(() {
        userLatLng = LatLng(position.latitude, position.longitude);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final center = widget.busLocation;

    return Scaffold(
      appBar: AppBar(title: Text('Tracking ${widget.busName}')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Icon(Icons.directions_bus, color: Colors.black),
                  const SizedBox(width: 12),
                  Text(
                    "Bus Name: ${widget.busName}",
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: SizedBox(
                height: 300,
                child: FlutterMap(
                  options: MapOptions(center: center, zoom: 13),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                      subdomains: ['a', 'b', 'c'],
                      userAgentPackageName: 'com.smart.rtc',
                    ),
                    if (routePoints.isNotEmpty)
                      PolylineLayer(
                        polylines: [
                          Polyline(
                            points: routePoints,
                            color: Colors.red,
                            strokeWidth: 4,
                          ),
                        ],
                      ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          width: 40,
                          height: 40,
                          point: widget.busLocation,
                          child: const Icon(Icons.directions_bus, color: Colors.red, size: 36),
                        ),
                        Marker(
                          width: 40,
                          height: 40,
                          point: widget.destinationStop,
                          child: const Icon(Icons.location_pin, color: Colors.green, size: 36),
                        ),
                        if (userLatLng != null)
                          Marker(
                            width: 40,
                            height: 40,
                            point: userLatLng!,
                            child: const Icon(Icons.person_pin_circle, color: Colors.blue, size: 36),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Route Stops:",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            ...widget.routeStops.map(
                  (stop) => ListTile(
                leading: const Icon(Icons.location_on, color: Colors.purple),
                title: Text(stop),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Ticket confirmed!")),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
              child: const Text("YOUR TICKET", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
