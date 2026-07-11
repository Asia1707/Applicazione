// MODELLO RHR

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class DailyRHRData {
  final int day; // Numero del giorno, coordinata X
  final double value; // RHR DEL giorno, coordinata Y
  final bool hasConsumedAlcohol; // TRUE se è stato consumato, dato dalla home
  final bool hasData; // TRUE se il dato esiste

  DailyRHRData({
    required this.day,
    required this.value,
    required this.hasConsumedAlcohol,
    this.hasData = true,
  });
}

class RHRChart extends StatelessWidget { // Widget del grafico 
  final List<DailyRHRData> rhrData; // Passo la lista di RHR

  const RHRChart({super.key, required this.rhrData});

  @override
  Widget build(BuildContext context) {
    final validData = rhrData.where((d) => d.hasData).toList(); //solo i giorni con un dato valido sono mostrati nel grafico

    final minGiorno = rhrData.isEmpty ? 0 : rhrData.first.day; //primo giorno del dataset
    final maxGiorno = rhrData.isEmpty ? 0 : rhrData.last.day; //ultimo giorno del dataset

    return LineChart(
      LineChartData(
        minX: minGiorno.toDouble(), //ASSE X
        maxX: maxGiorno.toDouble(),

        minY: 50, // ASSE Y
        maxY: 65,

        titlesData: FlTitlesData(
          show: true, // mostra le etichette sugli assi

          // ETICHETTA ASSE X
          bottomTitles: AxisTitles( 
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30, // QUI PER AUMENTARE LO SPAZIO DELLE ETICHETTE
              interval: 1, // un'etichetta per ogni giorno
              getTitlesWidget: (double value, TitleMeta meta) {
                final giorno = value.round();
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  space: 8.0, // QUI PER CAMBIARE LO SPAZIO TRA NUMERO E LINEA DELL'ASSE
                  child: Text(
                    giorno.toString(),
                    style: const TextStyle( // QUI PER CAMBIARE FONT E DIMENSIONE DELL'ASSE X
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                );
              },
            ),
          ),

          // ETICHETTA ASSE Y
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 25, // QUI PER CAMBIARE SPAZIO PER LE ETICHETTA A SINISTRA
              interval: 5, // QUI PER CAMBIARE INTERVALLO DEI NUMERI
              getTitlesWidget: (double value, TitleMeta meta) {
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  space: 8.0,
                  child: Text(
                    value.toInt().toString(),
                    style: const TextStyle(color: Colors.grey, fontSize: 10), //QUI PER CAMBIARE COLORE / DIMENSIONE DEL TESTO DEI VALORI RHR
                    textAlign: TextAlign.right,
                  ),
                );
              },
            ),
          ),

          // Nasconde le etichette sopra e a destra del grafico (non servono)
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),

        // GRIGLIA DI SFONDO
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false, // non voglio linee verticali
          horizontalInterval: 1, // QUI PER CAMBIARE INTERVALLO DELLE LINEE ORIZZONTALI
          getDrawingHorizontalLine: (value) => FlLine(
            color: Colors.grey.withValues(alpha: 0.2), // QUI PER CAMBIARE COLORE / TRASPARENZA DELLE LINEE
            strokeWidth: 1, // QUI PER CAMBIARE LO SPESSORE DELLE LINEE DI GRIGLIA
          ),
        ),

        borderData: FlBorderData(show: false), // Nasconde il bordo esterno del grafico


        // DATI DEL GRAFICO
        lineBarsData: [
          LineChartBarData(
            spots: validData.map((d) => FlSpot(d.day.toDouble(), d.value)).toList(), // lista di punti da disegnare sul grafico
            isCurved: false, // linea dritta tra i punti, non curva
            color: Colors.grey.shade400, // QUI PER CAMBIARE COLORE DELLA LINEA TRATTEGGIATA
            barWidth: 2, // QUI PER CAMBIARE LO SPESSORE DELLA LINEA
            dashArray: [5, 5], // QUI PER CAMBIARE IL TIPO DI TRATTEGGIO (lunghezza tratto/spazio)

            // Configurazione dei pallini sopra ogni punto della linea
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                final data = validData[index];

                Color dotColor = data.hasConsumedAlcohol //Se è stato consumato alcol
                    ? Colors.deepOrange.shade400 // QUI PER CAMBIARE COLORE GIORNI ALCOL
                    : const Color(0xFF13898C); // QUI PER CAMBIARE COLORE DEI GIORNI SENZA ALCOL

                return FlDotCirclePainter(
                  radius: 5.5, // QUI PER CAMBIARE GRANDEZZA DEL PALLINO
                  color: dotColor, 
                  strokeWidth: 2, // QUI PER CAMBIARE LO SPESSORE DEL BORDO ESTERNO DEL PALLINO
                  strokeColor: Colors.white, // QUI PER CAMBIARE IL COLORE DEL BORDO ESTERNO DEL PALLINO
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}