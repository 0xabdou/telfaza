import 'package:flutter/material.dart';
import 'package:telfaza/components/bottom_sheet_button.dart';
import 'package:telfaza/components/rating_bar.dart';
import 'package:telfaza/style.dart';
import 'package:telfaza/models/movie.dart';
import 'package:auto_size_text/auto_size_text.dart';

const kBottomSheetHeightRatio = 0.75;

class CustomBottomSheet extends StatelessWidget {
  final Widget controller;
  final Movie movie;
  final Function onTapLeft;
  final Function onTapRight;

  const CustomBottomSheet({
    this.controller,
    this.movie,
    this.onTapLeft,
    this.onTapRight,
  });

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    final details = _getReadableDetails();

    return Container(
      width: screenWidth,
      height: screenHeight * kBottomSheetHeightRatio,
      decoration: BoxDecoration(
        color: kPrimaryColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(50.0),
          topRight: Radius.circular(50.0),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.0),
        child: Stack(
          children: [
            Column(
              children: [
                // Top line
                Container(
                  height: 5.0,
                  width: 60.0,
                  margin: EdgeInsets.all(32.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                    color: Colors.grey,
                  ),
                ),
                Padding(
                  // stats bar
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  child: Row(
                    children: [
                      MainInfoWidget(
                        label: details['voteStr'],
                        child: RatingBar(stars: details['vote']),
                      ),
                      verticalDivider(),
                      MainInfoWidget(
                        label: details['runtime'],
                        child: AutoSizeText(
                          'Duration',
                          maxLines: 1,
                          style: TextStyle(fontSize: 16.0),
                        ),
                      ),
                      verticalDivider(),
                      MainInfoWidget(
                        label: movie.releaseDate.substring(0, 4),
                        child: AutoSizeText(
                          'Release Year',
                          maxLines: 1,
                          style: TextStyle(fontSize: 16.0),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 20.0,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Expanded(
                      child: BottomSheetButton(
                        color: kSecondaryColor,
                        icon: Icons.play_circle_filled,
                        label: 'Watch',
                        onTap: onTapLeft,
                      ),
                    ),
                    Expanded(
                      child: BottomSheetButton(
                        color: kSecondaryColor,
                        icon: Icons.launch,
                        label: 'Website',
                        onTap: onTapRight,
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 0.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Overview',
                          style: kBottomTextStyle,
                        ),
                        SizedBox(
                          height: 10.0,
                        ),
                        Expanded(
                          child: SingleChildScrollView(
                            child: Padding(
                              padding: EdgeInsets.only(bottom: 8.0),
                              child: Text(
                                details['overview'],
                                style: TextStyle(fontSize: 18.0),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: screenHeight * 0.45,
              child: controller,
            ),
          ],
        ),
      ),
    );
  }

  Map<String, dynamic> _getReadableDetails() {
    final details = <String, dynamic>{};

    final double vote = movie.voteAverage;
    details['voteStr'] = vote == null ? '-' : vote.toStringAsFixed(1);
    details['vote'] = vote ?? 0.0;

    details['runtime'] =
        movie.runtime != null ? _formatRuntime(movie.runtime) : '-';

    final String date = movie.releaseDate;

    details['year'] =
        (date != null && date.length >= 4) ? date.substring(0, 4) : '-';

    details['overview'] = movie.overview ?? '';

    return details;
  }

  String _formatRuntime(int runtime) {
    int hours = (runtime / 60).floor();
    int minutes = runtime % 60;
    return '$hours:${minutes.toString().padLeft(2, '0')}';
  }

  Widget verticalDivider() {
    return Container(
      margin: EdgeInsets.all(12.0),
      height: 30,
      width: 2,
      color: kSecondaryColor,
    );
  }
}

class MainInfoWidget extends StatelessWidget {
  final String label;
  final Widget child;

  const MainInfoWidget({
    this.label,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    return Expanded(
      child: SizedBox(
        height: height * 0.09,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Expanded(
              child: Center(
                child: AutoSizeText(
                  label,
                  maxLines: 1,
                  style: kBottomTextStyle,
                ),
              ),
            ),
            FittedBox(
              child: child,
            ),
          ],
        ),
      ),
    );
  }
}
