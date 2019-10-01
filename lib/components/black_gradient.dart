import 'package:flutter/material.dart';

class BlackGradient extends StatelessWidget {
  final Widget child;
  final bool bottom;
  final bool top;

  const BlackGradient({
    this.child,
    this.bottom = false,
    this.top = false,
  });

  @override
  Widget build(BuildContext context) {
    List<Color> colors;
    List<double> stops;
    if (bottom && top) {
      colors = [
        Colors.black87,
        Colors.transparent,
        Colors.transparent,
        Colors.black87
      ];
      stops = [0, 0.3, 0.6, 1];
    } else if (top) {
      colors = [Colors.black87, Colors.transparent];
      stops = [0, 0.2];
    } else {
      colors = [Colors.transparent, Colors.black87];
      stops = [0.8, 1];
    }
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: colors,
          stops: stops,
        ),
      ),
      child: child == null ? Container() : child,
    );
  }
}
