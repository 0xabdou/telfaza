import 'package:flutter/material.dart';

double getCardWidth(BuildContext context) {
  double width = MediaQuery.of(context).size.width;
  return (width - 4 * 4) / 3;
}
