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
      appBar: AppTitle(text: 'Estado del Estacionamiento'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ---------------------- ESTADO ACTUAL -------------------------
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      'Estado Actual del Estacionamiento',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
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
                            Text(
                              'Total de lugares:',
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            Text('$totalSpots', textAlign: TextAlign.right),
                          ],
                        ),
                        TableRow(
                          children: [
                            Text(
                              'Lugares ocupados:',
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            Text('$occupiedSpots', textAlign: TextAlign.right),
                          ],
                        ),
                        TableRow(
                          children: [
                            Text(
                              'Lugares disponibles:',
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
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

            // ---------------------- PAGEVIEW POR ZONAS -------------------------
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      'Lugares Disponibles por Zona',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    SizedBox(
                      height: 400,
                      child: PageView(
                        controller: PageController(viewportFraction: 0.88),
                        children: [
                          ZonaCard(
                            titulo:
                                "Estacionamiento externo y profesores Norte",
                            total: totalSpots,
                            ocupados: occupiedSpots,
                            disponibles: availableSpots,
                          ),
                          ZonaCard(
                            titulo: "Estacionamiento controlado Norte",
                            total: totalSpots,
                            ocupados: (occupiedSpots * 0.7).toInt(),
                            disponibles: (totalSpots * 0.3).toInt(),
                          ),
                          ZonaCard(
                            titulo: "Estacionamiento controlado poniente",
                            total: totalSpots,
                            ocupados: (occupiedSpots * 0.4).toInt(),
                            disponibles: (totalSpots * 0.6).toInt(),
                          ),
                          ZonaCard(
                            titulo: "Estacionamiento profesores Sur",
                            total: totalSpots,
                            ocupados: (occupiedSpots * 0.55).toInt(),
                            disponibles: (totalSpots * 0.45).toInt(),
                          ),
                          ZonaCard(
                            titulo: "Acceso peatonal sur",
                            total: totalSpots,
                            ocupados: (occupiedSpots * 0.25).toInt(),
                            disponibles: (totalSpots * 0.75).toInt(),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    Text(
                      "Desliza para ver otras zonas →",
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ---------------------- MAPA -------------------------
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      'Mapa del Estacionamiento',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
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

            // ---------------------- PROBABILIDADES -------------------------
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      'Probabilidades de encontrar un lugar libre',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
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
                                child: InteractiveViewer(child: ParkingGraph()),
                              ),
                            ),
                          ),
                        );
                      },
                      child: SizedBox(height: 200, child: ParkingGraph()),
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

// ============================================================================
//                               ZONA CARD
// ============================================================================

class ZonaCard extends StatelessWidget {
  final String titulo;
  final int total;
  final int ocupados;
  final int disponibles;

  const ZonaCard({
    super.key,
    required this.titulo,
    required this.total,
    required this.ocupados,
    required this.disponibles,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          children: [
            const SizedBox(height: 6),

            Text(
              titulo,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            Expanded(
              child: Center(
                child: SizedBox(
                  height: 170,
                  child: ParkingPieChart(
                    totalSpots: total,
                    occupiedSpots: ocupados,
                    availableSpots: disponibles,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 8),

            // ----- Leyenda -----
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.circle, color: Colors.lightBlue, size: 14),
                const SizedBox(width: 6),
                const Text("Disponibles"),

                const SizedBox(width: 26),

                Icon(Icons.circle, color: Colors.grey, size: 14),
                const SizedBox(width: 6),
                const Text("Ocupados"),
              ],
            ),

            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
