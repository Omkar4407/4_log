import 'package:flutter/material.dart';

class MapSection extends StatelessWidget {
  const MapSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          color: Colors.grey.shade300,
          child: const Center(
            child: Text('Map goes here'),
          ),
        ),
        Positioned(
          top: 16,
          left: 16,
          right: 16,
          child: Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              children: const [
                Icon(Icons.search),
                SizedBox(width: 8),
                Text('Search'),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
