import 'package:flutter/material.dart';

class AstemixScoreChart extends StatelessWidget {
  final int score;

  const AstemixScoreChart({super.key, required this.score});

  @override
  Widget build(BuildContext context) {
    // Determina il colore in base all'Indice di Recupero
    Color scoreColor;
    if (score >= 75) {
      scoreColor = const Color(0xFF13898C); // Turchese (Ottimo)
    } else if (score >= 50) {
      scoreColor = Colors.orangeAccent; // Arancione (Discreto)
    } else {
      scoreColor = Colors.redAccent; // Rosso (Da migliorare)
    }

    return Center(
      child: SizedBox(
        width: 200,
        height: 200,
        // Animazione che fa salire il livello del cerchio partendo da 0
        child: TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0, end: score / 100.0),
          duration: const Duration(milliseconds: 1500),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            return Stack(
              fit: StackFit.expand,
              children: [
                // Cerchio di sfondo opaco
                CircularProgressIndicator(
                  value: 1.0,
                  strokeWidth: 18,
                  color: Colors.grey.shade200,
                ),
                // Cerchio del punteggio che si riempie
                CircularProgressIndicator(
                  value: value,
                  strokeWidth: 18,
                  backgroundColor: Colors.transparent,
                  color: scoreColor,
                  strokeCap: StrokeCap.round, // Angoli smussati per un design pulito
                ),
                // Numeri animati al centro
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${(value * 100).toInt()}', 
                        style: TextStyle(
                          fontSize: 56,
                          fontWeight: FontWeight.bold,
                          color: scoreColor,
                          height: 1.0,
                        ),
                      ),
                      const Text(
                        '/ 100',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}