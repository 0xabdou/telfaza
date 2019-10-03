import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:telfaza/screens/movie_screen.dart';
import 'package:telfaza/style.dart';

import 'bloc/movie_search_bloc.dart';
import 'components/movie_card.dart';
import 'models/movie.dart';

class SearchMovie extends SearchDelegate<List<Movie>> {
  MovieSearchBloc bloc;
  final ScrollController _controller = ScrollController();
  double _lastScrollPosition = 0.0;
  bool _rememberPosition = false;
  String _lastQuery = '';
  Timer _queryTimer;
  Timer _scrollTimer;
  var first = true;

  SearchMovie(context) {
    _controller.addListener(() {
      _lastScrollPosition = _controller.offset;
    });
    bloc = Provider.of<MovieSearchBloc>(context);
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        onPressed: () {
          query = '';
          showSuggestions(context);
        },
        icon: Icon(Icons.clear),
      )
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () {
        close(context, null);
      },
      icon: Icon(Icons.arrow_back),
    );
  }

  @override
  void showResults(BuildContext context) {
    // We don't want to use the results page
    // but we want to hide the keyboard when the user hits search
    FocusScope.of(context).requestFocus(new FocusNode());
    // and immediately send the query
    if (_queryTimer != null) _queryTimer.cancel();
    _sendQuery();
  }

  @override
  Widget buildResults(BuildContext context) {
    // We won't use the results page
    return Container();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // show the previous query
    if (first) {
      query = '${bloc.currentQuery}';
      first = false;
    }
    // cancel the previous set timer
    if (_queryTimer != null) _queryTimer.cancel();
    // set a new timer to send the query 1 second after user finishes typing
    _queryTimer = Timer(Duration(milliseconds: 500), () => _sendQuery());

    return StreamBuilder<List<Movie>>(
      stream: bloc.outMovies,
      builder: (context, AsyncSnapshot<List<Movie>> snapshot) {
        final movies = snapshot.data;
        return GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 8.0,
              childAspectRatio: 0.65,
            ),
            controller: _controller,
            itemCount: snapshot.data != null ? movies.length + 1 : 0,
            itemBuilder: (context, index) {
              return _buildMovieCard(
                movies: movies,
                index: index,
                sink: bloc.inIndex,
                context: context,
              );
            });
      },
    );
  }

  Widget _buildMovieCard({
    List<Movie> movies,
    int index,
    Sink<int> sink,
    BuildContext context,
  }) {
    // if we must remember scroll position
    // wait until the last card is built, then scroll back
    if (_rememberPosition) {
      if (_scrollTimer != null) _scrollTimer.cancel();
      _scrollTimer = Timer(Duration(milliseconds: 1), () {
        _rememberPosition = false;
        _scrollBack();
      });
    }

    sink.add(index);

    if (movies == null || movies.length == 0) {
      return Container();
    }

    if (index >= movies.length)
      return MovieCard(
        movie: null,
      );

    return MovieCard(
      movie: movies[index],
      withTitle: true,
      onPressed: () {
        _rememberPosition = true;
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) {
            return MovieScreen(
              movie: movies[index],
            );
          }),
        );
      },
    );
  }

  void _sendQuery() {
    if (_lastQuery != query) {
      bloc.inQuery.add(query);
      _lastQuery = query;
      _lastScrollPosition = 0.0;
      _scrollBack();
    }
  }

  void _scrollBack() {
    _controller.jumpTo(_lastScrollPosition);
  }

  @override
  ThemeData appBarTheme(BuildContext context) {
    return appTheme;
  }
}
