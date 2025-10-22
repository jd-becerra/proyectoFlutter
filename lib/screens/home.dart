import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_flutter/provider.dart';
import 'package:proyecto_flutter/widgets/pie_chart.dart';
import 'package:proyecto_flutter/widgets/title.dart';
import 'package:proyecto_flutter/widgets/parking_graph.dart';

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
    final availableSpots = totalSpots - occupiedSpots;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 40,
        flexibleSpace: const AppTitle(text: 'Información del Estacionamiento'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
            children: [
            Card(
              child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(
                  'Estado Actual del Estacionamiento',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Table(
                    border: TableBorder(
                    horizontalInside: BorderSide(
                      width: 1,
                      color: Colors.grey.shade400,
                    ),
                    ),
                    columnWidths: const {
                    0: FlexColumnWidth(2),
                    1: FlexColumnWidth(1),
                    },
                    children: [
                    TableRow(
                      children: [
                      Text('Total de lugares:', textAlign: TextAlign.left, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      Text('$totalSpots', textAlign: TextAlign.right),
                      ],
                    ),
                    TableRow(
                      children: [
                      Text('Lugares ocupados:', textAlign: TextAlign.left, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      Text('$occupiedSpots', textAlign: TextAlign.right),
                      ],
                    ),
                    TableRow(
                      children: [
                      Text('Lugares disponibles:', textAlign: TextAlign.left, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      Text('$availableSpots', textAlign: TextAlign.right),
                      ],
                    ),
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
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 16, fontWeight: FontWeight.bold),
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
            const SizedBox(height: 20),
            Card(
              child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                Text(
                  'Mapa del Estacionamiento',
                  style: Theme.of(
                  context,
                  ).textTheme.bodyLarge?.copyWith(fontSize: 16, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                    builder: (_) => Scaffold(
                      appBar: AppBar(),
                      body: Center(
                      child: InteractiveViewer(
                        child: Image.asset('assets/images/mapa.jpeg'),
                      ),
                      ),
                    ),
                    ),
                  );
                  },
                  child: Image.asset('assets/images/mapa.jpeg'),
                ),
                const SizedBox(height: 12),
                Text(
                  '* Toca la imagen para ampliarla.',
                  style: Theme.of(
                  context,
                  ).textTheme.bodySmall?.copyWith(fontSize: 12),
                  textAlign: TextAlign.center,
                ),
                ],
              ),
              ),
            ),
            const SizedBox(height: 20),
            Card(
              child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                Text(
                  'Probabilidades de encontrar un lugar libre',
                  style: Theme.of(
                  context,
                  ).textTheme.bodyLarge?.copyWith(fontSize: 16, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                    builder: (_) => Scaffold(
                      appBar: AppBar(),
                      body: Center(
                      child: InteractiveViewer(
                        child: ParkingGraph(),
                      ),
                      ),
                    ),
                    ),
                  );
                  },
                  child: SizedBox(
                  height: 200,
                  child: ParkingGraph(),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '* Toca la imagen para ampliarla.',
                  style: Theme.of(
                  context,
                  ).textTheme.bodySmall?.copyWith(fontSize: 12),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  '** Las probabilidades se obtuvieron analizando la ubicación y afluencia histórica del estacionamiento.',
                  style: Theme.of(
                  context,
                  ).textTheme.bodySmall?.copyWith(fontSize: 12),
                  textAlign: TextAlign.center,
                ),
                
                ],
              ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
