import 'package:flutter/material.dart';

class AdditionalItems extends StatelessWidget {
  final IconData icon;
  final String title;
  final String degree;
  const AdditionalItems({
    super.key,
    required this.icon,
    required this.title,
    required this.degree,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          icon,
          size: 48,
        ),
        const SizedBox(
          height: 8,
        ),
        Text(
          title,
        ),
        const SizedBox(
          height: 8,
        ),
        Text(
          degree,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
