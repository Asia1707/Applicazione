// MODELLO SLEEP
 
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
 
class DailySleepData {
  final int day; // Numero del giorno, coordinata X
  final int minutesAsleep; // Minuti di sonno effettivo
  final int minutesAwake; // Minuti sveglio durante la notte 
  final int minutesAfterWokeup; // Minuti sveglio prima di alzarsi
  final int efficiency; // Percentuale di efficienza del sonno
  final bool hasConsumedAlcohol; // TRUE se è stato consumato alcol
  final bool hasData; // TRUE se il dato esiste
 
DailySleepData({
    required this.day,
    required this.minutesAsleep,
    required this.minutesAwake,
    required this.minutesAfterWokeup,
    required this.efficiency,
    required this.hasConsumedAlcohol,
    this.hasData = true,
  });
}
 
class SleepChart extends StatelessWidget { // Widget del grafico a barre
  final List<DailySleepData> sleepData; // Passo la lista dei dati del sonno
 
  const SleepChart({super.key, required this.sleepData});
 
  @override
  Widget build(BuildContext context) {
 
    int maxDay = sleepData.isNotEmpty ? sleepData.last.day : 1; // Giorno corrente per creare la lista
 
    // Costruisce sempre una finestra di 7 giorni per l'asse X: nella prima settimana mostra fissi i giorni 1-7, dopo scorre mostrando sempre gli ultimi 7 giorni fino a maxDay
    final int start = maxDay < 7 ? 1 : maxDay - 6;
    final List<int> xAxisDays = List<int>.generate(7, (i) => start + i);
 
return BarChart(
      BarChartData( // richiede una lista come asse x per rispettare gli spazi vuoti dei giorni senza dati
        alignment: BarChartAlignment.spaceBetween, // Spaziatura tra le barre
        maxY: 10, // QUI PER MODIFICARE ESTREMO ASSE Y
        barTouchData: BarTouchData(enabled: false), // Disabilita il tocco (non ci sono popup)
 
        titlesData: FlTitlesData(
          show: true, // mostra le etichette sugli assi
 
        // ETICHETTA ASSE X
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28, // QUI PER AUMENTARE LO SPAZIO DELLE ETICHETTE IN BASSO
              getTitlesWidget: (double value, TitleMeta meta) {
                int dayValue = value.toInt();
 
                if (!xAxisDays.contains(dayValue) || dayValue > maxDay || dayValue < 1) { // Non mostriamo i numeri se il giorno non rientra nella griglia 
                  return const SizedBox.shrink();
                }
 
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  space: 4.0, // QUI PER CAMBIARE LO SPAZIO TRA NUMERO E LINEA DELL'ASSE
                  child: Text(
                        dayValue.toString(),
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
              reservedSize: 25, // QUI PER CAMBIARE SPAZIO PER LE ETICHETTE A SINISTRA
              interval: 2, // QUI PER CAMBIARE INTERVALLO DEI NUMERI
              getTitlesWidget: (double value, TitleMeta meta) {
                if (value <= 0) return const SizedBox.shrink();
                
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  space: 8.0, // Spazio tra asse Y e testo
                  child: Text(
                    '${value.toInt()}h',
                    style: const TextStyle(color: Colors.grey, fontSize: 10), // QUI PER CAMBIARE COLORE / DIMENSIONE DEL TESTO ORE
                    textAlign: TextAlign.right,
                  ),
                );
              },
            ),
          ),
 
        // Nascondo le etichette sopra e a destra del grafico
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
 
        // GRIGLIA DI SFONDO 
        gridData: const FlGridData(
          show: true,
          drawVerticalLine: false, // non voglio linee verticali
          horizontalInterval: 2, // QUI PER CAMBIARE INTERVALLO DELLE LINEE ORIZZONTALI
        ),
 
        borderData: FlBorderData(show: false), // Nasconde il bordo esterno del grafico
 
       // DATI DEL GRAFICO (BARRE)
        barGroups: xAxisDays.map((dayX) {
          final data = sleepData.firstWhere(
            (d) => d.day == dayX,

            // Giorno senza dati nel dataset: creo un placeholder con valori tutti a zero
            orElse: () => DailySleepData(
              day: dayX,
              minutesAsleep: 0,
              minutesAwake: 0,
              minutesAfterWokeup: 0,
              efficiency: 0,
              hasConsumedAlcohol: false,
              hasData: false,
            ),
          );
 
        // Calcolo in ore per posizionare correttamente i dati sulle Y
          double asleepY = data.minutesAsleep / 60.0;
          double awakeY = (data.minutesAwake + data.minutesAfterWokeup) / 60.0;
          double totalY = asleepY + awakeY;
 
          // COLORI DELLE BARRE IMPILATE
          Color darkColor = data.hasConsumedAlcohol
              ? Colors.deepOrange.shade400 // QUI PER CAMBIARE COLORE SONNO PROFONDO (GIORNI ALCOL)
              : const Color(0xFF13898C); // QUI PER CAMBIARE COLORE SONNO PROFONDO (GIORNI SENZA ALCOL)
              
          Color lightColor = data.hasConsumedAlcohol
              ? Colors.orange.shade200 // QUI PER CAMBIARE COLORE VEGLIA (GIORNI ALCOL)
              : const Color(0xFF80CBC4); // QUI PER CAMBIARE COLORE VEGLIA (GIORNI SENZA ALCOL)
 
          return BarChartGroupData(
            x: dayX,
            barRods: [
              BarChartRodData(
                toY: totalY, // Altezza totale della barra (sonno + veglia). Se il giorno non ha dati, totalY è 0
                width: 24, // QUI PER CAMBIARE LA LARGHEZZA DELLA BARRA
                borderRadius: BorderRadius.circular(4), // QUI PER CAMBIARE L'ARROTONDAMENTO DEGLI ANGOLI IN CIMA
                rodStackItems: [
                  BarChartRodStackItem(0, asleepY, darkColor), // Base della barra
                  BarChartRodStackItem(asleepY, totalY, lightColor), // Cima della barra
                ],
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}
 
