import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:telfaza/components/tappable_surface.dart';
import 'package:telfaza/components/black_gradient.dart';
import 'package:telfaza/models/movie.dart';
import 'package:telfaza/services/tmdb_api.dart';
import 'package:telfaza/screens/movie_screen.dart';

class LargeMovieCard extends StatelessWidget {
  final Movie movie;
  final Function onPressed;

  const LargeMovieCard({
    this.movie,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    final loading = movie == null;
    String year = '-';
    String _imageUrl = '';
    if (!loading) {
      year = movie.releaseDate.length >= 4
          ? movie.releaseDate.substring(0, 4)
          : year = movie.releaseDate;
      _imageUrl = api.getImageUrl(movie.backdropPath, 5);
    }

    return Padding(
      padding: EdgeInsets.all(8.0),
      child: SizedBox(
        height: size.height * 0.3,
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: CachedNetworkImage(
                fit: BoxFit.cover,
                imageUrl: _imageUrl,
              ),
            ),
            BlackGradient(bottom: true),
            Positioned(
              bottom: 0,
              right: 0,
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Icon(
                      Icons.star,
                      color: Colors.white70,
                      size: 20.0,
                    ),
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
            Positioned(
              bottom: 0.0,
              left: 0.0,
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: size.width * 0.6,
                      child: AutoSizeText(
                        movie.title,
                        maxLines: 2,
                        style: TextStyle(
                          fontSize: 22.0,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Text(year),
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
}
