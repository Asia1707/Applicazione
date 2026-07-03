import 'package:flutter/material.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0FDF9),
      body: const Center(
        child: Text(
          'Qui andranno i grafici e le statistiche',
          style: TextStyle(fontSize: 18, color: Colors.black54),
        ),
      ),
    );
  }
}