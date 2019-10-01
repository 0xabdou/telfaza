import 'package:flutter/material.dart';
import 'package:telfaza/style.dart';

class RatingBar extends StatelessWidget {
  final double stars;

  const RatingBar({@required this.stars});

  @override
  Widget build(BuildContext context) {
    final int fullStars = (stars / 2).floor();
    bool halfStar = stars - fullStars >= 0.5;

    final List<Icon> starIcons = [];
    for (int i = 0; i < 5; i++) {
      if (i < fullStars) {
        starIcons.add(Icon(
          Icons.star,
          color: kSecondaryColor,
        ));
      } else if (halfStar) {
        starIcons.add(Icon(
          Icons.star_half,
          color: kSecondaryColor,
        ));
        halfStar = false;
      } else {
        starIcons.add(Icon(
          Icons.star_border,
          color: kSecondaryColor,
        ));
      }
    }
    return Row(
      children: starIcons,
    );
  }
}
