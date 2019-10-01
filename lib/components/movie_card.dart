import 'package:flutter/material.dart';
import 'package:telfaza/components/tappable_surface.dart';
import 'package:telfaza/components/black_gradient.dart';
import 'package:telfaza/models/movie.dart';
import 'package:telfaza/services/tmdb_api.dart';
import 'package:telfaza/screens/movie_screen.dart';
import 'package:telfaza/utils.dart';
import 'package:cached_network_image/cached_network_image.dart';

class MovieCard extends StatelessWidget {
  final Movie movie;
  final Function onPressed;
  final bool withTitle;

  const MovieCard({
    this.movie,
    this.onPressed,
    this.withTitle = false,
  });

  @override
  Widget build(BuildContext context) {
    final loading = movie == null;
    String year = '-';
    String title = '';
    if (!loading) {
      year = movie.releaseDate.length >= 4
          ? movie.releaseDate.substring(0, 4)
          : year = movie.releaseDate;
      title = movie.title;
    }
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.0),
      child: SizedBox(
        width: getCardWidth(context),
        height: getCardWidth(context) / 0.6,
        child: loading
            ? Container()
            : Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: CachedNetworkImage(
                      fit: BoxFit.cover,
                      imageUrl: api.getImageUrl(movie.posterPath, 3) ?? '',
                    ),
                  ),
                  if (withTitle)
                    BlackGradient(
                      bottom: true,
                      top: true,
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 4.0,
                          vertical: 4.0,
                        ),
                        child: _movieInfo(title, year),
                      ),
                    )
                  else
                    BlackGradient(
                      top: true,
                    ),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 8.0,
                        horizontal: 8.0,
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.star, color: Colors.white70, size: 16.0),
                          SizedBox(
                            width: 4.0,
                          ),
                          Text(
                            '${movie.voteAverage}',
                            style: TextStyle(
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  TappableSurface(
                    onPressed: onPressed ??
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MovieScreen(movie: movie),
                            ),
                          );
                        },
                  ),
                ],
              ),
      ),
    );
  }

  Widget _movieInfo(String title, String year) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          title,
          overflow: TextOverflow.fade,
          maxLines: 1,
          softWrap: false,
          textAlign: TextAlign.left,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 15.0,
          ),
        ),
        Text(year),
      ],
    );
  }
}
