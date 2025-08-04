import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'track_bus_screen.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController sourceController = TextEditingController();
  final TextEditingController destinationController = TextEditingController();
  LatLng? currentLocation;

  List<Map<String, String>> allBuses = [
    {
      "name": "Bus A",
      "time": "1:30 PM - 2:00 PM",
      "route": "Gajuwaka Junction - Dwaraka Bus Station",
      "duration": "30 min",
      "distance": "30 m"
    },
    {
      "name": "Bus B",
      "time": "2:15 PM - 2:45 PM",
      "route": "MVP Colony - RTC Complex, Vizag",
      "duration": "25 min",
      "distance": "20 m"
    },
    {
      "name": "Bus C",
      "time": "3:00 PM - 3:30 PM",
      "route": "Gajuwaka - Simhachalam",
      "duration": "35 min",
      "distance": "40 m"
    },
    {
      "name": "Bus D",
      "time": "3:00 PM - 3:30 PM",
      "route": "Maddilapalem - RK Beach",
      "duration": "35 min",
      "distance": "60 m"
    },
    {
      "name": "Bus E",
      "time": "3:00 PM - 3:30 PM",
      "route": "Gajuwaka Depot & Stop  - Visakha Steel City Depot",
      "duration": "35 min",
      "distance": "30 m"
    },
    {
      "name": "Bus F",
      "time": "3:00 PM - 3:30 PM",
      "route": "Rushikonda  - Kailasagiri",
      "duration": "35 min",
      "distance": "30 m"
    },
  ];

  List<Map<String, String>> filteredBuses = [];

  @override
  void initState() {
    super.initState();
    _getUserLocation();
    filteredBuses = allBuses;
  }

  Future<void> _getUserLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        return;
      }
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    setState(() {
      currentLocation = LatLng(position.latitude, position.longitude);
    });
  }

  void _filterBuses() {
    String dest = destinationController.text.trim().toLowerCase();

    setState(() {
      if (dest.isEmpty) {
        filteredBuses = allBuses;
      } else {
        filteredBuses = allBuses.where((bus) {
          return bus["route"]!.toLowerCase().contains(dest);
        }).toList();
      }
    });
  }

  Future<LatLng?> convertToLatLng(String address) async {
    try {
      List<Location> locations = await locationFromAddress(address);
      if (locations.isNotEmpty) {
        return LatLng(locations[0].latitude, locations[0].longitude);
      }
    } catch (e) {
      print("Geocoding failed: $e");
    }
    return null;
  }

  void _navigateToProfile() {
    Navigator.pushNamed(context, '/profile');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Image.asset(
                    'assets/images/your_logo.png',
                    width: 100,
                  ),
                  IconButton(
                    icon: const Icon(Icons.account_circle, size: 36),
                    onPressed: _navigateToProfile,
                  ),
                ],
              ),
              // const SizedBox(height: 20),
              //const Center(
                //child: Text(
                  //"ROUTES",
                  //style: TextStyle(
                    //fontSize: 24,
                    //fontWeight: FontWeight.bold,
                    //color: Color(0xFF1A237E),
                  //),
               // ),
              //),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFB2DFDB),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: sourceController,
                  decoration: const InputDecoration(
                    icon: Icon(Icons.my_location, color: Colors.black54),
                    hintText: "My location",
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFB2DFDB),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: destinationController,
                  decoration: const InputDecoration(
                    icon: Icon(Icons.search, color: Colors.black54),
                    hintText: "Destination",
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (destinationController.text.isNotEmpty) {
                      _filterBuses();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Please enter a destination")),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[800],
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: const Text(
                    "SEARCH",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: SizedBox(
                  height: 200,
                  width: double.infinity,
                  child: currentLocation == null
                      ? const Center(child: CircularProgressIndicator())
                      : FlutterMap(
                    options: MapOptions(
                      center: currentLocation,
                      zoom: 15.0,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                        "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                        subdomains: ['a', 'b', 'c'],
                        userAgentPackageName: 'com.smart.rtc',
                      ),
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: currentLocation!,
                            width: 40,
                            height: 40,
                            child: const Icon(
                              Icons.my_location,
                              color: Colors.black,
                              size: 40,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Divider(thickness: 1),
              const SizedBox(height: 8),
              for (var bus in filteredBuses) _buildBusCard(bus),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBusCard(Map<String, String> bus) {
    final destination = (bus["route"]?.split("-").last ?? "").trim();
    final routeStops = bus["route"]?.split("-").map((e) => e.trim()).toList() ?? [];

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.directions_bus, size: 18),
                    const SizedBox(width: 6),
                    Text(bus["name"] ?? "", style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
                Text(bus["duration"] ?? "", style: const TextStyle(fontWeight: FontWeight.w500)),
              ],
            ),
            const SizedBox(height: 4),
            Text(bus["time"] ?? ""),
            Text(bus["route"] ?? ""),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(bus["distance"] ?? ""),
                ElevatedButton.icon(
                  onPressed: () async {
                    LatLng? destinationLatLng = await convertToLatLng(destination);

                    if (destinationLatLng != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => TrackBusScreen(
                            busLocation: LatLng(17.6883, 83.2186),
                            destinationStop: destinationLatLng,
                            busName: bus["name"] ?? "Bus",
                            routeStops: routeStops,
                          ),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Invalid destination address")),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[800],
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  icon: const Icon(Icons.location_searching, size: 16),
                  label: const Text("TRACK"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
