import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class DailySleepData {
  final int day; 
  final int minutesAsleep;
  final int minutesAwake;
  final int minutesAfterWokeup;
  final bool hasConsumedAlcohol;
  final bool hasData; 
  final bool exists;  

  DailySleepData({
    required this.day,
    required this.minutesAsleep,
    required this.minutesAwake,
    required this.minutesAfterWokeup,
    required this.hasConsumedAlcohol,
    this.hasData = true,
    this.exists = true,
  });
}

class SleepChart extends StatelessWidget {
  final List<DailySleepData> sleepData;

  const SleepChart({super.key, required this.sleepData});

  @override
  Widget build(BuildContext context) {
    // Rimosso l'AspectRatio: ora il BarChart riempirà tutto il contenitore padre
    return BarChart(
      BarChartData(
        // spaceBetween distribuisce le colonne usando tutto lo spazio orizzontale
        alignment: BarChartAlignment.spaceBetween,
        maxY: 10, 
        barTouchData: BarTouchData(enabled: false),

        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28, 
              getTitlesWidget: (double value, TitleMeta meta) {
                final giornoCorrispondente = sleepData.firstWhere(
                  (d) => d.day == value.toInt(),
                  orElse: () => DailySleepData(
                    day: value.toInt(),
                    minutesAsleep: 0,
                    minutesAwake: 0,
                    minutesAfterWokeup: 0,
                    hasConsumedAlcohol: false,
                    hasData: false,
                    exists: false,
                  ),
                );

                if (!giornoCorrispondente.exists) {
                  return const SizedBox.shrink();
                }

                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  space: 4.0, 
                  child: Text(
                    giornoCorrispondente.day.toString(),
                    style: const TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 25, // Leggermente ridotto per dare più spazio al grafico
              interval: 2,
              getTitlesWidget: (double value, TitleMeta meta) {
                if (value <= 0) return const SizedBox.shrink();
                
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  space: 8.0, 
                  child: Text(
                    '${value.toInt()}h',
                    style: const TextStyle(color: Colors.grey, fontSize: 10),
                    textAlign: TextAlign.right,
                  ),
                );
              },
            ),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true, 
              reservedSize: 10, // Un piccolo margine destro per evitare che l'ultima barra tocchi il bordo
              getTitlesWidget: (double value, TitleMeta meta) {
                return const SizedBox.shrink(); 
              },
            ),
          ),
        ),

        gridData: const FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 2,
        ),
        borderData: FlBorderData(show: false),

        // CREAZIONE DELLE COLONNE
        barGroups: sleepData.map((data) {
          if (!data.hasData) {
            return BarChartGroupData(
              x: data.day,
              barRods: [BarChartRodData(toY: 0)],
            );
          }

          double asleepY = data.minutesAsleep / 60.0;
          double awakeY = (data.minutesAwake + data.minutesAfterWokeup) / 60.0;
          double totalY = asleepY + awakeY;

          Color darkColor = data.hasConsumedAlcohol
              ? Colors.deepOrange.shade400
              : const Color(0xFF13898C);
          Color lightColor = data.hasConsumedAlcohol
              ? Colors.orange.shade200
              : const Color(0xFF80CBC4);

          return BarChartGroupData(
            x: data.day,
            barRods: [
              BarChartRodData(
                toY: totalY,
                width: 24, // Leggermente ingrandite (ora 24) dato che abbiamo più spazio
                borderRadius: BorderRadius.circular(4),
                rodStackItems: [
                  BarChartRodStackItem(0, asleepY, darkColor),
                  BarChartRodStackItem(asleepY, totalY, lightColor),
                ],
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}