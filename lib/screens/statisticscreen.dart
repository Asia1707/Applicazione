import 'package:flutter/material.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  final PageController _pageController = PageController(); //controller per lo scorrimento
  int _currentPage = 0; //variabile per tenere traccia della pagina corrente

  static const Color ral5018 = Color(0xFF13898C); //RAL 5018

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
          
            const Text(  // Titolo Principale
              'Le tue statistiche',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: ral5018,
              ),
            ),
            const SizedBox(height: 8),
            // Sottotitolo
            const Text(
              'Scorri per esplorare i tuoi dati',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 30),
            
            // Sezione Scrollabile (PageView)
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (int page) {
                  setState(() {
                    _currentPage = page;
                  });
                },
                children: const [
                  // Passiamo i titoli delle 3 schede al nostro Widget riutilizzabile
                  StatCard(title: 'Sonno'),
                  StatCard(title: 'Resting Heart Rate'),
                  StatCard(title: 'Stress'),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Indicatori a pallini
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                3,
                (index) => buildDot(index),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
      
      // Barra di navigazione inferiore
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        elevation: 10,
        currentIndex: 1, // 1 significa che l'icona centrale è quella attiva
        selectedItemColor: ral5018,
        unselectedItemColor: Colors.grey.shade400,
        showSelectedLabels: false, // Nasconde le scritte
        showUnselectedLabels: false,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined, size: 30),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart, size: 30),
            label: 'Statistiche',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined, size: 30),
            label: 'Impostazioni',
          ),
        ],
      ),
    );
  }

  // Funzione per costruire i singoli pallini di scorrimento
  Widget buildDot(int index) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 8,
      width: _currentPage == index ? 8 : 8, // Puoi farli più larghi se attivi modificando qui
      decoration: BoxDecoration(
        color: _currentPage == index ? ral5018 : Colors.grey.shade300,
        shape: BoxShape.circle,
      ),
    );
  }
}

// ---------------------------------------------------------
// WIDGET RIUTILIZZABILE PER LA SCHEDA GRAFICO
// ---------------------------------------------------------
class StatCard extends StatelessWidget {
  final String title;

  const StatCard({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Intestazione della scheda
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
          const SizedBox(height: 20),
          
          // SPAZIO PER IL GRAFICO (Placeholder)
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade200, style: BorderStyle.dash),
              ),
              child: const Center(
                child: Text(
                  '[ Spazio per il Grafico ]',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Testo sotto il grafico
          const Text(
            'Hai dormito in media 52 min in più\nnei giorni senza alcol.',
            style: TextStyle(fontSize: 14, color: Colors.black87),
          ),
          const SizedBox(height: 15),
          
          // Pulsante "Scopri di più"
          OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF13898C),
              side: const BorderSide(color: Color(0xFF13898C)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Scopri di più'),
          ),
        ],
      ),
    );
  }
}