import 'package:flutter/material.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  final PageController _pageController = PageController();
  int _currentCard = 0;
  static const Color ral5018 = Color(0xFF13898C);

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Mantenuto il colore di sfondo del tuo file originale
      backgroundColor: const Color(0xFFF0FDF9),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF0FDF9),
        elevation: 0,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: ral5018,
                shape: BoxShape.circle,
              ),
              child: const Text('3', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(width: 10),
            const Text(
              'STATISTICHE',
              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, letterSpacing: 1.2),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            const Text(
              'Le tue statistiche',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: ral5018),
            ),
            const SizedBox(height: 8),
            const Text(
              'Scorri per esplorare i tuoi dati',
              style: TextStyle(fontSize: 16, color: Colors.black),
            ),
            const SizedBox(height: 30),
            
            // Area delle schede che scorrono di lato
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (int page) {
                  setState(() {
                    _currentCard = page; // Aggiorna l'indice per colorare il pallino corretto
                  });
                },
                children: const [
                  StatCard(title: 'Sonno'),
                  StatCard(title: 'Resting Heart Rate'),
                  StatCard(title: 'Stress'),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // I tre pallini indicatori sotto la scheda
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                3,
                (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  height: 8,
                  width: 8,
                  decoration: BoxDecoration(
                    color: _currentCard == index ? ral5018 : Colors.grey.shade300,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

// IL WIDGET PER LA SCHEDA DEL GRAFICO (RIUTILIZZABILE)
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
            color: Colors.grey.withValues(alpha: 0.15),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
          const SizedBox(height: 20),
          
          // Contenitore vuoto che farà da base per il grafico a barre futuro
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withValues(alpha: 0.15),
                    spreadRadius: 2,
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Center(
                child: Text('[ Spazio per il Grafico ]', style: TextStyle(color: Colors.grey)),
              ),
            ),
          ),
          
          const SizedBox(height: 20),
          const Text(
            'Hai dormito in media 52 min in più\nnei giorni senza alcol.',
            style: TextStyle(fontSize: 14, color: Colors.black87),
          ),
          const SizedBox(height: 15),
          OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF13898C),
              side: const BorderSide(color: Color(0xFF13898C)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Scopri di più'),
          ),
        ],
      ),
    );
  }
}
