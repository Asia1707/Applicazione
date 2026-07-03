import 'package:flutter/material.dart';

class MoodScreen extends StatelessWidget {
  const MoodScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0FDF9),
      body: const Center(
        child: Text(
          'Qui andrà la sezione dedicata al Mood',
          style: TextStyle(fontSize: 18, color: Colors.black54),
        ),
      ),
    );
  }
}