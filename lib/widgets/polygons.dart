import 'package:flutter/material.dart';

class Map extends StatelessWidget {
  final double width;
  final double height;
  final Color color;

  const Map({
    super.key,
    required this.width,
    required this.height,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Image(image: AssetImage('assets/images/probabilidades.svg'), width: width, height: height);
  }
}
