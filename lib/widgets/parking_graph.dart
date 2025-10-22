import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
            width: constraints.maxWidth,
            height: constraints.maxHeight,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor),
            ),
            clipBehavior: Clip.antiAlias,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: SvgPicture.asset(
                'assets/images/probabilidades.svg',
                fit: BoxFit.contain,
                width: constraints.maxWidth,
                height: constraints.maxHeight,
              ),
            ),
          );
        },
      ),
    );
  }
}
