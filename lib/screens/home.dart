import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_flutter/provider.dart';
import 'package:proyecto_flutter/widgets/pie_chart.dart';
import 'package:proyecto_flutter/widgets/title.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final parkingData = provider.parkingData;

    if (parkingData.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    final totalSpots = parkingData['total_spots'] ?? 0;
    final occupiedSpots = parkingData['occupied_spots'] ?? 0;
    final registeredEntries = parkingData['registered_entries'] ?? 0;
    final registeredExits = parkingData['registered_exits'] ?? 0;
    final availableSpots = totalSpots - occupiedSpots;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 40,
        flexibleSpace: const AppTitle(text: 'Información del Estacionamiento'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Table(
                  columnWidths: const {
                    0: FlexColumnWidth(2),
                    1: FlexColumnWidth(1),
                  },
                  children: [
                    TableRow(
                      children: [
                        Text('Total de lugares:', textAlign: TextAlign.left),
                        Text('$totalSpots', textAlign: TextAlign.right),
                      ],
                    ),
                    TableRow(
                      children: [
                        Text('Lugares ocupados:', textAlign: TextAlign.left),
                        Text('$occupiedSpots', textAlign: TextAlign.right),
                      ],
                    ),
                    TableRow(
                      children: [
                        Text('Lugares disponibles:', textAlign: TextAlign.left),
                        Text('$availableSpots', textAlign: TextAlign.right),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Card(
              child: Column(
                children: [
                  Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Lugares Disponibles',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SizedBox(
                      height: 250,
                      width: double.infinity,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Let the PieChart take flexible width
                          Expanded(
                            flex: 2,
                            child: ParkingPieChart(
                              totalSpots: totalSpots,
                              occupiedSpots: occupiedSpots,
                              availableSpots: availableSpots,
                            ),
                          ),
                          const SizedBox(width: 20),
                          // Legend with flexible layout
                          Expanded(
                            flex: 1,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.circle,
                                      color: Colors.lightBlue,
                                      size: 12,
                                    ),
                                    const SizedBox(width: 8),
                                    Flexible(
                                      child: Text(
                                        'Ocupados',
                                        style: Theme.of(
                                          context,
                                        ).textTheme.bodySmall,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.circle,
                                      color: Colors.grey,
                                      size: 12,
                                    ),
                                    const SizedBox(width: 8),
                                    Flexible(
                                      child: Text(
                                        'Disponibles',
                                        style: Theme.of(
                                          context,
                                        ).textTheme.bodySmall,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
