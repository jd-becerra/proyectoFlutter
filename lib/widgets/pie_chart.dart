import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class ParkingPieChart extends StatelessWidget {
  final int totalSpots;
  final int occupiedSpots;
  final int availableSpots;
  const ParkingPieChart({
    super.key,
    required this.totalSpots,
    required this.occupiedSpots,
    required this.availableSpots,
  });

  double getRadiusSize(int spots) {
    double radius = 50 * (spots / totalSpots);
    return radius < 30 ? 30 : radius;
  }

  @override
  Widget build(BuildContext context) {
    return PieChart(
      PieChartData(
        sections: [
          PieChartSectionData(
            value: occupiedSpots.toDouble(),
            color: Colors.red,
            title: 'Occupied',
            radius: totalSpots == 0 ? 0 : getRadiusSize(occupiedSpots),
            titleStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          PieChartSectionData(
            value: availableSpots.toDouble(),
            color: Colors.green,
            title: 'Available',
            radius: totalSpots == 0 ? 0 : getRadiusSize(availableSpots),
            titleStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
        sectionsSpace: 2,
        centerSpaceRadius: 40,
      ),
    );
  }
}
