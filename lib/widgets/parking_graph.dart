import 'package:flutter/material.dart';
import 'package:proyecto_flutter/widgets/polygons.dart';

class ParkingGraph extends StatelessWidget {
  const ParkingGraph({super.key});

  @override
  Widget build(BuildContext context) {
    final borderColor = Theme.of(context).dividerColor;

    return AspectRatio(
      aspectRatio: 16 / 9,
      child: LayoutBuilder(
        builder: (context, constraints) {

          return Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor),
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              children: [
                Positioned(
                  left: 10,
                  top: -20,
                  child: SectionA(
                    width: 300,
                    height: 100,
                    color: Colors.cyan,
                    p1: const Offset(0.0, 1.0),
                    p2: const Offset(1.0, 1.0),
                    p3: const Offset(0.5, 0.2),
                    cornerIndexToChop: 1,
                    ratioToPrev: 0.21,
                    ratioToNext: 0.45,
                  ),
                ),
                Positioned(
                  left: 10,
                  top: 65,
                  child: SizedBox(
                    width: 30,
                    height: 150,
                    child: Container(color: Colors.red),
                  ),
                ),
                Positioned(
                  left: 50,
                  bottom: 0,
                  child: SizedBox(
                    child: Container(width: 300, height: 100, color: Colors.grey),
                  ),
                ),
                Positioned(
                  right: 0,
                  top: 25,
                  child: SectionB(
                    base: 60,
                    height: 55,
                    color: Colors.green,
                    directionRight: true, // chops bottom-right corner
                    chopRatio: 0.2,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
