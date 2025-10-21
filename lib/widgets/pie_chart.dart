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

  final double radius = 50;
  final double centerSpaceRadius = 50;

  @override
  Widget build(BuildContext context) {
    return PieChart(
      PieChartData(
        sections: [
          PieChartSectionData(
            value: occupiedSpots.toDouble(),
            color: Colors.grey,
            title: 'Occupied',
            radius: radius,
            titleStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          PieChartSectionData(
            value: availableSpots.toDouble(),
            color: Colors.lightBlue,
            borderSide: BorderSide(style: BorderStyle.solid, color: Colors.grey, width: 6),
            title: 'Available',
            radius: radius, 
            titleStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
        sectionsSpace: 0,
        centerSpaceRadius: centerSpaceRadius,
      ),
    );
  }
}
