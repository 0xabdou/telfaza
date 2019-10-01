import 'package:flutter/material.dart';
import 'package:telfaza/style.dart';

class BottomSheetButton extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String label;
  final Function onTap;

  const BottomSheetButton({
    this.color,
    this.icon,
    this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: MaterialButton(
        onPressed: onTap,
        padding: EdgeInsets.all(20.0),
        color: color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
        ),
        child: FittedBox(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Icon(
                icon,
                size: 50,
              ),
              SizedBox(
                width: 10.0,
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: 30.0,
                  color: kPrimaryColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
