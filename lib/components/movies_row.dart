import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:telfaza/bloc/movies_bloc.dart';
import 'package:telfaza/components/movie_card.dart';
import 'package:telfaza/models/movie.dart';
import 'package:telfaza/screens/more_screen.dart';
import 'package:telfaza/screens/slide_route.dart';
import 'package:telfaza/services/tmdb_api.dart';
import 'package:telfaza/style.dart';
import 'package:telfaza/utils.dart';

class MoviesRow extends StatelessWidget {
  final PageType type;
  final int _moviesPerPage = 20;

  const MoviesRow({this.type});

  @override
  Widget build(BuildContext context) {
    final MoviesBloc movieBloc = Provider.of<MoviesBloc>(context);

    String label;
    Stream<List<Movie>> stream;
    Sink<int> sink;
    switch (type) {
      case PageType.topRated:
        label = 'Top rated';
        stream = movieBloc.outTopRated;
        sink = movieBloc.inTopRatedIndex;
        break;
      case PageType.popular:
        label = 'Popular';
        stream = movieBloc.outPopular;
        sink = movieBloc.inPopularIndex;
        break;
      case PageType.nowPlaying:
        label = 'In theatres';
        stream = movieBloc.outNowPlaying;
        sink = movieBloc.inNowPlayingIndex;
        break;
    }

    return Padding(
      padding: EdgeInsets.only(bottom: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 19.0,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      SlideRoute(
                        page: MoreScreen(type: type),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(10.0),
                  splashColor: kSecondaryColor,
                  highlightColor: kSecondaryColor.withAlpha(0x55),
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'Show more',
                      style: TextStyle(
                        fontSize: 14.0,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: getCardWidth(context) / 0.6,
            child: StreamBuilder<List<Movie>>(
              stream: stream,
              builder: (context, snapshot) => ListView.builder(
                itemCount: snapshot.data == null ? 0 : _moviesPerPage,
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  return _buildMovieCard(snapshot.data, index, sink);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMovieCard(List<Movie> movies, int index, Sink<int> indexSink) {
    indexSink.add(index);

    final movie =
        (movies != null && index < movies.length) ? movies[index] : null;

    return MovieCard(
      movie: movie,
    );
  }
}
