import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class MapTrackingScreen extends StatefulWidget {
  final String destination;

  const MapTrackingScreen({super.key, required this.destination});

  @override
  State<MapTrackingScreen> createState() => _MapTrackingScreenState();
}

class _MapTrackingScreenState extends State<MapTrackingScreen> {
  LatLng? currentPosition;
  LatLng? destinationPosition;
  List<LatLng> routePoints = [];
  List<LatLng> nearbyStops = [];
  late final MapController mapController;
  StreamSubscription<Position>? positionStream;

  @override
  void initState() {
    super.initState();
    mapController = MapController();
    _startLocationTracking();
    _getDestinationCoordinates();
  }

  @override
  void dispose() {
    positionStream?.cancel();
    super.dispose();
  }

  void _startLocationTracking() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    ).listen((Position position) {
      setState(() {
        currentPosition = LatLng(position.latitude, position.longitude);
        _generateNearbyStops();
        if (destinationPosition != null) {
          _fetchRoute();
        }
      });
    });
  }

  Future<void> _getDestinationCoordinates() async {
    try {
      List<Location> locations =
      await locationFromAddress(widget.destination);
      destinationPosition =
          LatLng(locations[0].latitude, locations[0].longitude);
      if (currentPosition != null) {
        _fetchRoute();
      }
    } catch (e) {
      print("Error getting destination coordinates: $e");
    }
  }

  Future<void> _fetchRoute() async {
    final uri = Uri.parse(
        'https://router.project-osrm.org/route/v1/driving/${currentPosition!.longitude},${currentPosition!.latitude};${destinationPosition!.longitude},${destinationPosition!.latitude}?geometries=geojson');
    final response = await http.get(uri);
    final data = json.decode(response.body);
    final coordinates =
    data['routes'][0]['geometry']['coordinates'] as List<dynamic>;

    setState(() {
      routePoints =
          coordinates.map((c) => LatLng(c[1], c[0])).toList();
    });
  }

  void _generateNearbyStops() {
    if (currentPosition != null) {
      nearbyStops = [
        LatLng(currentPosition!.latitude + 0.002, currentPosition!.longitude),
        LatLng(currentPosition!.latitude, currentPosition!.longitude + 0.002),
        LatLng(currentPosition!.latitude - 0.002, currentPosition!.longitude),
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Smart RTC Live Tracker")),
      body: currentPosition == null
          ? const Center(child: CircularProgressIndicator())
          : FlutterMap(
        mapController: mapController,
        options: MapOptions(
          center: currentPosition,
          zoom: 15,
        ),
        children: [
          TileLayer(
            urlTemplate:
            "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
            subdomains: ['a', 'b', 'c'],
          ),
          MarkerLayer(
            markers: [
              Marker(
                point: currentPosition!,
                width: 40,
                height: 40,
                child: const Icon(Icons.my_location,
                    color: Colors.blue, size: 40),
              ),
              if (destinationPosition != null)
                Marker(
                  point: destinationPosition!,
                  width: 40,
                  height: 40,
                  child: const Icon(Icons.flag,
                      color: Colors.red, size: 40),
                ),
              // Nearby stops
              ...nearbyStops.map(
                    (stop) => Marker(
                  point: stop,
                  width: 30,
                  height: 30,
                  child: const Icon(Icons.directions_bus,
                      color: Colors.orange, size: 30),
                ),
              ),
            ],
          ),
          if (routePoints.isNotEmpty)
            PolylineLayer(
              polylineCulling: false,
              polylines: [
                Polyline(
                  points: routePoints,
                  color: Colors.green,
                  strokeWidth: 4.0,
                )
              ],
            )
        ],
      ),
    );
  }
}
