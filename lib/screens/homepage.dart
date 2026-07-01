import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index; // Cambia solo il colore dell'icona selezionata
    });

    // Qui la tua amica potrà inserire il codice per cambiare effettivamente schermata
    // (es. if (index == 1) { Navigator.push(...) })
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Sfondo della pagina bianco
      appBar: AppBar(
        title: const Text('Home'),
        backgroundColor: const Color(0xFF0F8A8F),
        foregroundColor: Colors.white,
      ),
      
      // BODY COMPLETAMENTE VUOTO: SizedBox() è un widget invisibile che non occupa spazio,
      // lasciando trasparire solo il colore di sfondo bianco del Scaffold.
      body: const SizedBox(), 
      
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Grafici',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profilo',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFF0F8A8F),
        unselectedItemColor: Colors.grey.shade500,
        onTap: _onItemTapped,
      ),
    );
  }
}