import 'package:flutter/material.dart';
import '../services/api_service.dart';

class TestApiPage extends StatelessWidget {
  const TestApiPage({Key? key}) : super(key: key);

  void fetchRouteData() async {
    try {
      final route = await ApiService.getRoutePolyline('Hyderabad', 'Secunderabad');
      print('Route Points: $route');
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    fetchRouteData();

    return Scaffold(
      appBar: AppBar(title: const Text('Test API')),
      body: const Center(child: Text('Fetching route...')),
    );
  }
}
