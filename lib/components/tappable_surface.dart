import 'package:flutter/material.dart';
import 'package:telfaza/style.dart';

class TappableSurface extends StatelessWidget {
  final Function onPressed;
  final Widget child;

  const TappableSurface({
    this.onPressed,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(10),
        splashColor: kSecondaryColor.withAlpha(0x55),
        child: child ?? Container(),
      ),
    );
  }
}
