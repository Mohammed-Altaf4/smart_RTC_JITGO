import 'package:flutter/material.dart';

class BusMarker extends StatelessWidget {
  final String label;
  final Color color;
  final double size;

  const BusMarker({
    super.key,
    required this.label,
    this.color = Colors.blue,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.directions_bus,
          color: color,
          size: size,
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.black87,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
            ),
          ),
        )
      ],
    );
  }
}
