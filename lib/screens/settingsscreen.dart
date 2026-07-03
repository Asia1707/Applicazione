import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0FDF9),
      body: const Center(
        child: Text(
          'Qui andranno le impostazioni',
          style: TextStyle(fontSize: 18, color: Colors.black54),
        ),
      ),
    );
  }
}