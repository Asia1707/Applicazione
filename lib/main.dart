import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/login.dart'; 
import 'providers/user_provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider <UserProvider>(
      create: (context) => UserProvider(),
      child: const MyApp(),
    ),
  );
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Login(),
    );
  }
}