// MODELLO SCORE CHARTS

import 'package:flutter/material.dart';

class ScoreChart extends StatelessWidget {
  final int score; // Punteggio da 0 a 100 da visualizzare

  const ScoreChart({super.key, required this.score});

  @override
  Widget build(BuildContext context) { 
    Color scoreColor;
    if (score >= 75) { // QUI PER CAMBIARE SOGLIA OTTIMA
      scoreColor = const Color(0xFF13898C);
    } else if (score >= 50) { // QUI PER CAMBIARE SOGLIA MEDIA
      scoreColor = Colors.orangeAccent;
    } else { // QUI PER CAMBIARE SOGLIA BASSA
      scoreColor = Colors.redAccent;
    }

    return Center(
      child: SizedBox(
        width: 200, // QUI PER CAMBIARE LARGHEZZA DEL CERCHIO
        height: 200, // QUI PER CAMBIARE ALTEZZA DEL CERCHIO
        child: TweenAnimationBuilder<double>( // animazione riempimento fino al punteggio
          tween: Tween<double>(begin: 0, end: score / 100.0), // fino alla percentuale corrispondente
          duration: const Duration(milliseconds: 1500), // durata dell'animazione
          curve: Curves.easeOutCubic, // velocità ed effetto dell'animazione
          builder: (context, value, child) { //value si aggiorna iterativamente
            return Stack(
              fit: StackFit.expand,

              children: [
                CircularProgressIndicator( // cerchio di sfondo
                  value: 1.0, // sempre pieno
                  strokeWidth: 18, // QUI PER CAMBIARE SPESSORE DEL CERCHIO DI SFONDO
                  color: Colors.grey.shade200, // QUI PER CAMBIARE COLORE DEL CERCHIO DI SFONDO
                ),

                CircularProgressIndicator( // cerchio colorato
                  value: value, // percentuale corrente dell'animazione 
                  backgroundColor: Colors.transparent, // lascia visibile il cerchio grigio sotto
                  strokeWidth: 18, // QUI PER CAMBIARE LO SPESSORE DEL CERCHIO DEL PUNTEGGIO
                  color: scoreColor, // assegna il colore in base allo score
                  strokeCap: StrokeCap.round, // angoli smussati degli estremi
                ),
                
                Center( // testo al centro del cerchio con il numero del punteggio
                  child: Column(
                    mainAxisSize: MainAxisSize.min, // centra verticalmente il testo
                    children: [
                      Text(
                        '${(value * 100).toInt()}', // valore corrente arrotondato a intero
                        style: TextStyle(
                          fontSize: 56, // QUI PER CAMBIARE LA DIMENSIONE DEL NUMERO CENTRALE
                          fontWeight: FontWeight.bold,
                          color: scoreColor, // stesso colore del cerchio
                          height: 1.0, // riduce lo spazio verticale extra del testo
                        ),
                      ),
                      const Text(
                        '/ 100',
                        style: TextStyle( 
                          fontSize: 16, // QUI PER CAMBIARE LA DIMENSIONE DEL TESTO
                          color: Colors.grey, // QUI PER CAMBIARE IL COLORE DEL TESTO
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