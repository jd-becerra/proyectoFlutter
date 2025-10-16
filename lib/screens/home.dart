import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_flutter/provider.dart';
import 'package:proyecto_flutter/widgets/pie_chart.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    final parkingData = context.watch<AppProvider>().parkingData;

    if (parkingData.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    final totalSpots = parkingData['total_spots'] ?? 0;
    final occupiedSpots = parkingData['occupied_spots'] ?? 0;
    final registeredEntries = parkingData['registered_entries'] ?? 0;
    final registeredExits = parkingData['registered_exits'] ?? 0;
    final availableSpots = totalSpots - occupiedSpots;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Total Spots: $totalSpots',
            style: const TextStyle(fontSize: 18),
          ),
          Text(
            'Occupied Spots: $occupiedSpots',
            style: const TextStyle(fontSize: 18),
          ),
          Text(
            'Available Spots: $availableSpots',
            style: const TextStyle(fontSize: 18),
          ),
          Text(
            'Registered Entries: $registeredEntries',
            style: const TextStyle(fontSize: 18),
          ),
          Text(
            'Registered Exits: $registeredExits',
            style: const TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ParkingPieChart(
              totalSpots: totalSpots,
              occupiedSpots: occupiedSpots,
              availableSpots: availableSpots,
            ),
          ),
        ],
      ),
    );
  }
}
