import 'package:flutter/material.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: const Center(
        child: Text(
          'Home',
          style: TextStyle(
            fontSize: 24, 
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}