import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class DailyRHRData {
  final int day;
  final double value;
  final bool hasConsumedAlcohol;
  final bool hasData;
  final bool exists;

  DailyRHRData({
    required this.day,
    required this.value,
    required this.hasConsumedAlcohol,
    this.hasData = true,
    this.exists = true,
  });
}

class RHRChart extends StatelessWidget {
  final List<DailyRHRData> rhrData;

  const RHRChart({super.key, required this.rhrData});

  @override
  Widget build(BuildContext context) {
    final validData = rhrData.where((d) => d.hasData && d.exists).toList();

    return LineChart(
      LineChartData(
        // Rimosso minX/maxX forzato per evitare il bug del testo doppio
        minY: 50,
        maxY: 60,
        
        // Aggiungiamo un leggero spazio extra per non tagliare i pallini ai bordi
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30, // Aumentato leggermente
              interval: 1,
              getTitlesWidget: (double value, TitleMeta meta) {
                final giornoCorrispondente = rhrData.firstWhere(
                  (d) => d.day == value.toInt(),
                  orElse: () => DailyRHRData(
                    day: value.toInt(), value: 0, hasConsumedAlcohol: false, hasData: false, exists: false,
                  ),
                );

                if (!giornoCorrispondente.exists) return const SizedBox.shrink();

                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  space: 8.0, // Più spazio tra il numero e la linea
                  child: Text(
                    giornoCorrispondente.day.toString(),
                    style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 25,
              interval: 5,
              getTitlesWidget: (double value, TitleMeta meta) {
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  space: 8.0,
                  child: Text(
                    value.toInt().toString(),
                    style: const TextStyle(color: Colors.grey, fontSize: 10),
                    textAlign: TextAlign.right,
                  ),
                );
              },
            ),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),

        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 1,
          getDrawingHorizontalLine: (value) => FlLine(
            color: Colors.grey.withValues(alpha: 0.2),
            strokeWidth: 1,
          ),
        ),
        borderData: FlBorderData(show: false),

        lineBarsData: [
          LineChartBarData(
            spots: validData.map((d) => FlSpot(d.day.toDouble(), d.value)).toList(),
            isCurved: false,
            color: Colors.grey.shade400,
            barWidth: 2,
            dashArray: [5, 5],
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                final data = validData[index];
                Color dotColor = data.hasConsumedAlcohol
                    ? Colors.deepOrange.shade400
                    : const Color(0xFF13898C);

                return FlDotCirclePainter(
                  radius: 5.5,
                  color: dotColor,
                  strokeWidth: 2,
                  strokeColor: Colors.white,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}